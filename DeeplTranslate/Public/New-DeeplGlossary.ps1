<#PSScriptInfo

.VERSION 1.1.0

.GUID 5fe267cf-012b-4a61-ba2d-91b6428b7f50

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

    1.0.1
    Fixed issue with empty Uri in verbose output.
    
    1.1.0
    Updated way to get DeepL Api Uri and Http Status codes.
    
#>


<#

.DESCRIPTION
Contains a function to create a new glossary for a DeepL account.
More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

.LINK
https://www.deepl.com

.LINK
https://www.deepl.com/de/docs-api/introduction/

#>


function New-DeeplGlossary {
    <#
    .SYNOPSIS
    Creates a new glossary for a DeepL account.

    .DESCRIPTION
    The 'New-DeeplGlossary' function creates a new glossary for a DeepL account with the source and target language entries.

    .PARAMETER ApiKey
    API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .PARAMETER Name
    Name to be associated with the glossary.

    .PARAMETER LanguagePair
    The language pair (source and target) in which the text in the glossary is specified.

    .PARAMETER Entry
    The entry of the glossary. The entry has to be specified in the format provided by the EntryFormat parameter.

    .PARAMETER EntryFormat
    Possible values: 'CSV' or 'TSV'. Default is 'TSV'. The format in which the glossary entry is provided.
    Refer to https://www.deepl.com/docs-api/glossaries/formats/ for more information about the correct input format.

    .EXAMPLE
    New-DeeplGlossary -Verbose -ApiKey <MyApiKey> -Name "MyGlossary" -Entry "Hello`tGuten Tag" -EntryFormat TSV -LanguagePair en..de 

    glossary_id   : 57dda93f-597f-494f-88e2-c1771de8a530
    name          : MyGlossary
    ready         : True
    source_lang   : en
    target_lang   : de
    creation_time : 01.11.2022 18:19:54
    entry_count   : 1

    This example shows how to create a new glossary with name "MyGlossary" with language pair English/German.

    .INPUTS
    Nothing

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/New-DeeplGlossary.txt

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [string]
        $Entry,

        [ValidateSet("CSV", "TSV")]
        [string]
        $EntryFormat = "TSV"
    )

    # Use dynamic parameters for source and target language to either choose the language from a predefined static list
    #  or retrieve the list of supported languages from the DeepL Api.
    DynamicParam {
        # Set the dynamic parameters name.
        $ParamLanguagePair = 'LanguagePair'
        
        # Create the dictionary.
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes.
        $ParamLanguagePairAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        
        # Create and set the parameters attributes.
        $ParamLanguagePairAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParamLanguagePairAttribute.Mandatory = $true

        # Add the attributes to the attributes collections.
        $ParamLanguagePairAttributeCollection.Add($ParamLanguagePairAttribute)

        # Generate and set the ValidateSet.
        if ([string]::IsNullOrEmpty($ApiKey)) {
            # Try to retrieve the list of supported source languages.
            $GlossaryLanguagePairs = Get-DeeplGlossarySupportedLanguagePair
        }
        else {
            # Try to retrieve the list of supported source languages.
            $GlossaryLanguagePairs = Get-DeeplGlossarySupportedLanguagePair -ApiKey $ApiKey
        }
       
        # If something was returned, we set the valid parameter values to the list of languages retrieved.
        if ($null -ne $GlossaryLanguagePairs) {
            $GlossaryLanguagePairs = $GlossaryLanguagePairs
        }

        # Create an empty hashtable.
        $LanguagePairHT = @{}

        # Fill the hash table with data from the array containing all supported language pairs.
        foreach ($item in $GlossaryLanguagePairs) {
            $LanguagePairHT["$($item.source_lang)..$($item.target_lang)"] = $item
        }

        # Finally create an array containing only the language pair names that will be used for the validateset values of the 'LanguagePair' parameter.
        $LanguagePairArrSet = foreach ($item in $($LanguagePairHT.GetEnumerator())) { $item.Name }

        $ValidateSetLanguagePairAttribute = New-Object System.Management.Automation.ValidateSetAttribute($LanguagePairArrSet)

        # Add the ValidateSet to the attributes collection.
        $ParamLanguagePairAttributeCollection.Add($ValidateSetLanguagePairAttribute)

        # Create and return the dynamic parameter.
        $LanguagePairRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParamLanguagePair, [string[]], $ParamLanguagePairAttributeCollection)
        $RuntimeParameterDictionary.Add($ParamLanguagePair, $LanguagePairRuntimeParameter)
        return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable.
        if ($null -ne $PsBoundParameters[$ParamLanguagePair]) {
            $LanguagePair = $PsBoundParameters[$ParamLanguagePair][0]
            Write-Verbose -Message "supported language pair: '$LanguagePair'"
        }
    }

    process {
        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

        try {
            # Set the content type to url encoded form data.
            $ContentType = "application/x-www-form-urlencoded; charset=utf-8"

            # Set the authorization header.
            $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

            # Set body parameters.
            $Body = @{
                name           = $Name
                source_lang    = $LanguagePairHT."$LanguagePair".source_lang
                target_lang    = $LanguagePairHT."$LanguagePair".target_lang
                entries        = $Entry
                entries_format = $EntryFormat
            }

            # Set parameters for the Invoke-RestMethod cmdlet.
            $Params = @{
                Method      = 'POST'
                Uri         = "$BaseUri/glossaries"
                ContentType = $ContentType
                Headers     = $Headers
                Body        = $Body
            }
                
            # Try to retrieve the list of glossaries.
            Write-Verbose -Message "Calling Uri: $($Params.Uri)"
            $Glossary = Invoke-RestMethod @Params
            $Glossary
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
