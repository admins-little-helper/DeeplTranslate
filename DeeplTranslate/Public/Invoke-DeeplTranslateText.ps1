<#PSScriptInfo

.VERSION 1.1.1

.GUID 30f094cf-7b81-41b8-9820-cc161ea5a8ee

.AUTHOR diko@admins-little-helper.de

.COMPANYNAME

.COPYRIGHT (c) 2022-2024 All rights reserved.

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

    1.1.1
    Removed line to change console encoding because it was not necessary.
    Corrected a typo in the codepage number when detecting the default code page.

#>


<#

.DESCRIPTION
    Contains a function to translate text using the DeepL API.
    More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

    To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
    https://github.com/admins-little-helper/DeeplTranslate

.LINK
    https://www.deepl.com

.LINK
    https://www.deepl.com/de/docs-api/introduction/

#>


function Invoke-DeeplTranslateText {
    <#
    .SYNOPSIS
        Translates text using the DeepL API.

    .DESCRIPTION
        The 'Invoke-DeeplTranslateText' function translates text using the DeepL API. To use the DeepL API, either a free or pro account is required.

    .PARAMETER TextToTranslate
        Text to be translated. Only UTF8-encoded plain text is supported. Supports pipeline input.

    .PARAMETER TargetLanguage
        The language the text should be translated to.

    .PARAMETER SourceLanguage
        Language of the text to be translated. If no source language is specified, the DeepL Api tries to automatically detect the language.

    .PARAMETER SplitSentences
        Sets whether the translation engine should first split the input into sentences. This is enabled by default ('On').

    .PARAMETER PreserveFormatting
        Sets whether the translation engine should respect the original formatting, even if it would usually correct some aspects. This is disabled by default ('Off').

    .PARAMETER Formality
        Sets whether the translated text should lean towards formal or informal language.

    .PARAMETER GlossaryId
        Specify the glossary to use for the translation.
        Important: This requires the SourceLanguage parameter to be set and the language pair of the glossary has to match the language pair of the request.

    .PARAMETER ApiKey
        API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .EXAMPLE
        Invoke-DeeplTranslateText -TextToTranslate "PowerShell is cool!" -TargetLanguage "DE" -ApiKey "<MyApiKey>"

        This example shows how to translate a text into German.

    .EXAMPLE
        Invoke-DeeplTranslateText -TextToTranslate "PowerShell is cool!" -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>"

        SourceText              : PowerShell is cool!
        TargetText              : PowerShell ist cool!
        DetectedSourceLanguage  : EN
        SpecifiedSourceLanguage : EN
        SpecifiedTargetLanguage : DE
        OriginalResponse        : @{translations=System.Object[]}

        This example shows how to translate a text into German by also specifying the source language as beeing English.

    .INPUTS
        String for parameter 'TextToTranslate'

    .OUTPUTS
        PSCustomObject

    .NOTES
        Author:     Dieter Koch
        Email:      diko@admins-little-helper.de

    .LINK
        https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Invoke-DeeplTranslateText.txt

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [string[]]
        $TextToTranslate,

        [ValidateSet("Off", "On", "nonewlines")]
        [string]
        $SplitSentences,

        [ValidateSet("Off", "On")]
        [string]
        $PreserveFormatting,

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

    # Use dynamic parameters for source and target language to either choose the language from a predefined static list.
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

            # Try to retrieve the list of supported target languages.
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

        # Define values for the SplitSentences options
        $SplitSentencesOptions = @{
            Off        = '0'
            On         = '1'
            nonewlines = 'nonewlines'
        }

        # Define values for the PreserveFormatting options
        $PreserveFormattingOptions = @{
            Off = '0'
            On  = '1'
        }

        # Set optional API parameters in case parameter values have been specified in the function call.
        if ($SourceLanguage) { $Body.source_lang = $SourceLanguage }
        if ($Formality) { $Body.formality = $Formality }
        if ($GlossaryId) { $Body.glossary_id = $GlossaryId.Guid }
        if ($SplitSentences) { $Body.split_sentences = $SplitSentencesOptions.$SplitSentences }
        if ($PreserveFormatting) { $Body.preserve_formatting = $PreserveFormattingOptions.$PreserveFormatting }

        # Set the content type to url encoded form data.
        $ContentType = "application/x-www-form-urlencoded; charset=utf-8"

        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey
    }

    process {
        foreach ($Text in $TextToTranslate) {
            # Set the text paramter to the paramter value of $Text.
            $Body.text = $Text

            # Translating text.
            try {
                # Set the authorization header.
                $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

                # Set parameters for the Invoke-RestMethod cmdlet.
                $Params = @{
                    Method      = 'POST'
                    Uri         = "$BaseUri/translate"
                    ContentType = $ContentType
                    Headers     = $Headers
                    Body        = $Body
                }

                Write-Verbose -Message "Calling Uri: $($Params.Uri)"
                $Response = Invoke-RestMethod @Params

                # Construct the result as PSCustomObject.
                $Result = [PSCustomObject]@{
                    OriginalResponse        = $Response
                    SourceText              = $Text
                    # Get the translated text depending on the default encoding set. The default coding differs in PowerShell 5.1 and PowerShell 6.0+.
                    TargetText              = switch (([Text.Encoding]::Default).CodePage) {
                        1252 {
                            [Text.Encoding]::UTF8.GetString([Text.Encoding]::GetEncoding(28591).GetBytes($Response.translations.text))
                        }
                        65001 {
                            $Response.translations.text
                        }
                        default {
                            $Response.translations.text
                        }
                    }
                    DetectedSourceLanguage  = $Response.translations.detected_source_language
                    SpecifiedSourceLanguage = $SourceLanguage
                    SpecifiedTargetLanguage = $TargetLanguage
                }
                $Result.PSTypeNames.Clear()
                $Result.PSTypeNames.Add("DeeplTranslate.Text")

                $Result
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
