<#PSScriptInfo

.VERSION 1.1.0

.GUID 93cf5a1d-2793-4645-8937-36f24b2de164

.AUTHOR diko@admins-little-helper.de

.COMPANYNAME

.COPYRIGHT (c) 2022 All rights reserved.

.TAGS DeepL Translate Translation

.LICENSEURI https://github.com/admins-little-helper/DeeplTranslate/blob/main/LICENSE

.PROJECTURI https://github.com/admins-little-helper/DeeplTranslate

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
    1.0.0
    Initial release

    1.1.0
    Updated way to get DeepL Api Uri and Http Status codes.

#>


<#

.DESCRIPTION
    Contains a function to translate a file using the DeepL API.
    More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

    To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
    https://github.com/admins-little-helper/DeeplTranslate

.LINK
    https://www.deepl.com

.LINK
    https://www.deepl.com/de/docs-api/introduction/

#>


function Invoke-DeeplTranslateFile {
    <#
    .SYNOPSIS
        Translates a file using the DeepL API.

    .DESCRIPTION
        The 'Invoke-DeeplTranslateFile' function allows to translate a file using the DeepL API.
        Supported file types are .docx, .pptx, .pdf, .htm, .html, .txt.

    .PARAMETER InputFile
        The file path to the document to translate. Only these types are supported: .docx, .pptx, .pdf, .htm, .html, .txt.

    .PARAMETER OutputPath
        The folder path in which the output file should be saved. The output filename will be set to '<InputFilename>_<TargetLanguage>.<FileExtension>'.

    .PARAMETER TargetLanguage
        The language the text should be translated to.

    .PARAMETER OpenTranslatedFile
        If specified, the output file will be opened after download.
        In case there are more than 5 input files from pipeline ipnut, only the first 5 files will be opened.
        In case there are more than 5 input files specified via parameter, no file will be opened automatically.

    .PARAMETER Force
        If specified, existing output files will be overwritten.

    .PARAMETER SourceLanguage
        Language of the text to be translated. If no source language is specified, the DeepL Api tries to automatically detect the language.

    .PARAMETER Formality
        Sets whether the translated text should lean towards formal or informal language.

    .PARAMETER GlossaryId
        Specify the glossary to use for the translation.
        Important: This requires the SourceLanguage parameter to be set and the language pair of the glossary has to match the language pair of the request.

    .PARAMETER ApiKey
        API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .EXAMPLE
        Invoke-DeeplTranslateFile -InputFile C:\Temp\SourceDoc.docx -OutputPath C:\Temp\Output -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>"

        This example shows how to translate a DOCX document.

    .EXAMPLE
        Invoke-DeeplTranslateFile -InputFile C:\Temp\SourceDoc.docx -OutputPath C:\Temp\Output -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>" -OpenTranslatedFile

        This example shows how to translate a DOCX document and directly opens the output file once it has been successfully downloaded.

    .EXAMPLE
        Invoke-DeeplTranslateFile InputFile C:\Temp\SourceDoc.docx -OutputPath C:\Temp\Output -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>"

        This example shows how to translate multiple files.

    .EXAMPLE
        Invoke-DeeplTranslateFile -InputFile C:\Temp\SourceDoc.docx -OutputPath C:\Temp\Output -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>" -Force

        This example shows how to translate multiple files, overwriting any existing files in the output path.

    .INPUTS
        System.IO.FileInfo for parameter 'InputFile'

    .OUTPUTS
        System.IO.FileInfo for each output file generated.

    .NOTES
        Author:     Dieter Koch
        Email:      diko@admins-little-helper.de

    .LINK
        https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Invoke-DeeplTranslateFile.txt

    #>

    [CmdletBinding()]
    param (
        [ValidateScript({
                # Check if the given path is valid.
                if (-not (Test-Path -Path $_) ) {
                    throw "File or folder does not exist"
                }
                # Check if the given path is a file (not a folder).
                if (-not (Test-Path -Path $_ -PathType Leaf) ) {
                    throw "The Path argument must be a file. Folder paths are not allowed."
                }
                # Check if the extension of the given file matches the supported file extensions.
                if ($_ -notmatch "(\.docx|\.pptx|\.pdf|\.htm|\.html|\.txt)") {
                    throw "The file specified in the InputFile parameter must be one of these types: .docx, .pptx, .pdf, .htm, .html, .txt"
                }
                return $true
            })]
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string[]]
        $InputFile,

        [ValidateScript({
                # Check if the given path is valid.
                if (-not (Test-Path -Path $_) ) {
                    throw "Folder does not exist"
                }
                # Check if the given path is a directory.
                if (-not (Test-Path -Path $_ -PathType Container) ) {
                    throw "The Path argument must be a folder. File paths are not allowed."
                }
                return $true
            })]
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]
        $OutputPath,

        [Parameter(Mandatory = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false)]
        [switch]
        $OpenTranslatedFile,

        [ValidateSet("default", "more", "less", "prefer_more", "prefer_less")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Formality,

        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Guid[]]
        $GlossaryId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey
    )

    # Use dynamic parameters for source and target language to either choose the language from a predefined static list
    #  or retrieve the list of supported languages from the DeepL Api.
    DynamicParam {
        # Set the dynamic parameters name.
        $ParamSourceLang = 'SourceLanguage'
        $ParamTargetLang = 'TargetLanguage'

        # Create the dictionary.
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes.
        $ParamSourceAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParamTargetAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the parameters attributes.
        $ParamSourceAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParamSourceAttribute.Mandatory = $false
        $ParamTargetAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParamTargetAttribute.Mandatory = $true

        # Add the attributes to the attributes collections.
        $ParamSourceAttributeCollection.Add($ParamSourceAttribute)
        $ParamTargetAttributeCollection.Add($ParamTargetAttribute)

        # Generate and set the ValidateSet.
        if ([string]::IsNullOrEmpty($ApiKey)) {
            # Try to retrieve the list of supported source languages.
            $SourceLangList = Get-DeeplSupportedLanguage
            # If something was returned, we set the valid parameter values to the list of languages retrieved.
            if ($null -ne $SourceLangList) { $SourceLangArrSet = $SourceLangList.language }

            # Try to retrieve the list of supported target languages
            $TargetLangList = Get-DeeplSupportedLanguage -TargetLanguage
            # If something was returned, we set the valid parameter values to the list of languages retrieved.
            if ($null -ne $TargetLangList) { $TargetLangArrSet = $TargetLangList.language }
        }
        else {
            # Try to retrieve the list of supported source languages.
            $SourceLangList = Get-DeeplSupportedLanguage -ApiKey $ApiKey
            # If something was returned, we set the valid parameter values to the list of languages retrieved.
            if ($null -ne $SourceLangList) { $SourceLangArrSet = $SourceLangList.language }

            # Try to retrieve the list of supported target languages.
            $TargetLangList = Get-DeeplSupportedLanguage -ApiKey $ApiKey -TargetLanguage
            # If something was returned, we set the valid parameter values to the list of languages retrieved.
            if ($null -ne $TargetLangList) { $TargetLangArrSet = $TargetLangList.language }
        }

        $ValidateSetSourceLangAttribute = New-Object System.Management.Automation.ValidateSetAttribute($SourceLangArrSet)
        $ValidateSetTargetLangAttribute = New-Object System.Management.Automation.ValidateSetAttribute($TargetLangArrSet)

        # Add the ValidateSet to the attributes collection.
        $ParamSourceAttributeCollection.Add($ValidateSetSourceLangAttribute)
        $ParamTargetAttributeCollection.Add($ValidateSetTargetLangAttribute)

        # Create and return the dynamic parameter.
        $SourceLangRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamSourceLang, [string[]], $ParamSourceAttributeCollection)
        $TargetLangRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamTargetLang, [string[]], $ParamTargetAttributeCollection)
        $RuntimeParameterDictionary.Add($ParamSourceLang, $SourceLangRuntimeParameter)
        $RuntimeParameterDictionary.Add($ParamTargetLang, $TargetLangRuntimeParameter)
        return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable.
        if ($null -ne $PsBoundParameters[$ParamSourceLang]) {
            $SourceLanguage = $PsBoundParameters[$ParamSourceLang][0]
            Write-Verbose -Message "Setting source language to $SourceLanguage"
        }
        $TargetLanguage = $PsBoundParameters[$ParamTargetLang][0]
        Write-Verbose -Message "Setting source language to $TargetLanguage"

        # Build the body parameters as hashtable. Other properties are added later depending on the parameter values specified when the function is called.
        $Body = @{
            auth_key    = $ApiKey
            target_lang = $TargetLanguage
        }

        # Set optional API parameters in case parameter values have been specified in the function call.
        if ($SourceLanguage) { $Body.source_lang = $SourceLanguage }
        if ($Formality) { $Body.formality = $Formality }
        if ($GlossaryId) { $Body.glossary_id = $GlossaryId.Guid }

        # Set the content type to multipart to support the file content upload.
        $ContentType = "multipart/form-data; charset=utf-8"

        # Set the output encoding to UTF8 so that this function shows the same results for special characters in PowerShell 5.1 and in PowerShell 6.x or later.
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

        $ProcessCount = 0
    }

    process {
        $ProcessCount++
        Write-Verbose -Message "ProcessCount: $ProcessCount"

        if ($OpenTranslatedFile.IsPresent -and $InputFile.Count -gt 5) {
            Write-Warning -Message "Number of input files exceeds the limit of 5. No file will be opened."
        }

        foreach ($File in $InputFile) {
            # Generate the filename for the output file.
            $InputFileObj = Get-Item -Path $File
            [System.IO.FileInfo]$OutputFile = "$($OutputPath.FullName)\$($InputFileObj.BaseName)_$TargetLanguage$($InputFileObj.Extension)"

            Write-Verbose -Message $OutputFile.FullName

            # Check if the output file already exists.
            if (Test-Path -Path $OutputFile -PathType Leaf) {
                Write-Warning -Message "OutputFile file already exists!"

                if ($Force.IsPresent) {
                    Write-Warning -Message "Parameter 'Force' was specified. Will overwrite existing file!"
                }
                else {
                    Write-Error -Message "OutputFile file already exist! Specify a different filename/path or use the -Force parameter to overwrite the existing file."
                    break
                }
            }
            else {
                Write-Verbose -Message "OutputFile file does not yet exist. Will continue."
            }

            # Set the file parameter to the content of the InputDoc.
            $Body.file = Get-Item -Path $File
            # Set the filename parameter.
            $Body.filename = $File

            # Upload the document for translation.
            try {
                # Set the uthorization header.
                $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

                # Set parameters for the Invoke-RestMethod cmdlet.
                $UploadParams = @{
                    Method      = 'POST'
                    Uri         = "$BaseUri/document"
                    Headers     = $Headers
                    Form        = $Body
                    ContentType = $ContentType
                }

                Write-Verbose -Message "Calling Uri: $($UploadParams.Uri)"
                $UploadResponse = Invoke-RestMethod @UploadParams

                Write-Verbose -Message "Document ID: $($UploadResponse.document_id)"
                Write-Verbose -Message "Document Key: $($UploadResponse.document_key)"

                # Prepare a new body to check the status of the document translation.
                $BodyDocStatus = @{
                    auth_key     = $Body.auth_key
                    document_key = $UploadResponse.document_key
                }

                # Set a timeout to have a escape condition.
                $TimeOutOccured = $false
                $TimeOutAfterSeconds = 60
                $Timer = [System.Diagnostics.Stopwatch]::new()
                $Timer.Start()

                do {
                    # Check if the request already timed out.
                    if ($Timer.ElapsedMilliseconds / 1000 -gt $TimeOutAfterSeconds) {
                        $TimeOutOccured = $true
                    }
                    else {
                        # Set parameters for the Invoke-RestMethod cmdlet.
                        $StatusParams = @{
                            Method  = 'POST'
                            Uri     = "$BaseUri/document/$($UploadResponse.document_id)"
                            Headers = $Headers
                            Body    = $BodyDocStatus
                        }

                        Write-Verbose -Message "Calling Uri: $($StatusParams.uri)"
                        $StatusResponse = Invoke-RestMethod @StatusParams

                        # Check if the response contains a 'status' property.
                        if (($StatusResponse | Get-Member -MemberType NoteProperty | Select-Object -Property Name).Name -contains "status") {
                            Write-Verbose -Message "Job status: $($StatusResponse.status)"

                            switch ($StatusResponse.status) {
                                'translating' {
                                    Write-Verbose -Message "Estimated seconds remaining for document translation: $($StatusResponse.seconds_remaining)"
                                    Start-Sleep -Seconds 1
                                }
                                'queued' {
                                    Write-Verbose -Message "Waiting for translation"
                                    Start-Sleep -Seconds 1
                                }
                                'error' {
                                    if (($StatusResponse | Get-Member -MemberType NoteProperty | Select-Object -Property Name).Name -contains "message") {
                                        Write-Error -Message "Job status: $($StatusResponse.message)"
                                        break
                                    }
                                }
                                'done' {
                                    Write-Verbose -Message "Translation completed."
                                    #$StatusResponse
                                }
                            }
                        }
                    }
                } while ($StatusResponse.status -eq 'translating' -or $StatusResponse.status -eq 'queued' -or $TimeOutOccured)

                # when the document translation is done, try to download the resulting document.
                if ($StatusResponse.status -eq 'done') {
                    # Set parameters for the Invoke-RestMethod cmdlet.
                    $DocResponseParams = @{
                        Method  = 'POST'
                        Uri     = "$BaseUri/document/$($UploadResponse.document_id)/result"
                        Headers = $Headers
                        Body    = $BodyDocStatus
                        OutFile = $OutputFile
                    }

                    Write-Verbose -Message "Calling Uri: $($DocResponseParams.Uri))"
                    $DocResponse = Invoke-RestMethod @DocResponseParams
                    Write-Verbose -Message "Number of billed characters: $($StatusResponse.billed_characters)"

                    # In case the parameter 'OpenTranslatedFile' was specified, the resulting file will be openend.
                    #  However, this will only be done in case the total number of files is less than 5.
                    #  In case the input file was handed over via the 'InputFile' parameter, we can use the count of that array variable.
                    #  But in case the input file comes from the pipeline, the count will always be 1. So we then we use the $ProcessCount variable.
                    #  However, that will allow to open the first 5 files coming from the pipeline. But still better then possibly opening hundreds of files.
                    if ($OpenTranslatedFile.IsPresent -and $InputFile.Count -le 5 -and $ProcessCount -le 5) {
                        Start-Process -FilePath $OutputFile
                    }

                    if ($OpenTranslatedFile.IsPresent -and $ProcessCount -gt 5) {
                        Write-Warning -Message "Number of input files exceeds the limit of 5. No more files will be opened."
                    }
                }

                if ($DocResponse) {
                    $DocResponse
                }
                else {
                    Get-Item -Path $OutputFile
                }
            }
            catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                $ErrorMessage = Get-DeeplStatusCode -StatusCode $_.Exception.Response.StatusCode
                if ($null -ne $ErrorMessage) {
                    Write-Error -Message $ErrorMessage
                }
                else {
                    Write-Error -Message "Http Status Code: $_"
                }
            }
            catch {
                Write-Verbose -Message "An unknown error occured."
                $_
            }
        }
    }
}


#region EndOfScript
<#
################################################################################
################################################################################
#
#        ______           _          __    _____           _       _
#       |  ____|         | |        / _|  / ____|         (_)     | |
#       | |__   _ __   __| |   ___ | |_  | (___   ___ _ __ _ _ __ | |_
#       |  __| | '_ \ / _` |  / _ \|  _|  \___ \ / __| '__| | '_ \| __|
#       | |____| | | | (_| | | (_) | |    ____) | (__| |  | | |_) | |_
#       |______|_| |_|\__,_|  \___/|_|   |_____/ \___|_|  |_| .__/ \__|
#                                                           | |
#                                                           |_|
################################################################################
################################################################################
# created with help of http://patorjk.com/software/taag/
#>
#endregion
