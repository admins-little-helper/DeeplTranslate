<#PSScriptInfo

.VERSION 1.1.0

.GUID 7dc3619d-1192-40d8-92d1-dc85de4f29a1

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
Contains a function to retrieve a list of supported language pairs that can be used in a glossary for a DeepL account.
More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.


.LINK
https://github.com/admins-little-helper/DeeplTranslate

.LINK
https://www.deepl.com

.LINK
https://www.deepl.com/de/docs-api/introduction/
    
#>


function Get-DeeplGlossarySupportedLanguagePair {
    <#
    .SYNOPSIS
    Retrieves a list of supported language pairs that can be used in a glossary.

    .DESCRIPTION
    The 'Get-DeeplGlossarySupportedLanguagePair' function retrieves a list of supported language pairs that can be used in a glossary.

    .PARAMETER ApiKey
    API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .EXAMPLE
    Get-DeeplGlossarySupportedLanguagePair -ApiKey "<MyApiKey>"

    source_lang target_lang
    ----------- -----------
    de          en
    de          fr
    en          de
    en          es
    en          fr
    en          ja
    en          it
    en          pl
    en          nl
    es          en
    fr          de
    fr          en
    ja          en
    it          en
    pl          en
    nl          en

    This example shows how to retrieve a list supported languages for glossaries.

    .INPUTS
    Nothing

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplGlossarySupportedLanguagePair.txt

    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey
    )

    # Set a default list of supported language pairs to have something that this function will return in case
    # the Api call to retrieve the list of supported glossary language pairs fails with an error.
    # This is list is valid as of 2022-10-30.
    $GlossaryLanguagePairs = [PSCustomObject]@{
        supported_languages = @(
            [PSCustomObject]@{
                "source_lang" = "de"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "de"
                "target_lang" = "fr"
            }
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "de"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "es"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "fr"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "ja"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "it"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "pl"
            },
            [PSCustomObject]@{
                "source_lang" = "en"
                "target_lang" = "nl"
            },
            [PSCustomObject]@{
                "source_lang" = "es"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "fr"
                "target_lang" = "de"
            },
            [PSCustomObject]@{
                "source_lang" = "fr"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "ja"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "it"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "pl"
                "target_lang" = "en"
            },
            [PSCustomObject]@{
                "source_lang" = "nl"
                "target_lang" = "en"
            }
        )
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        # Return the list of statically defined language pairs, in case no ApiKey was specified.
        Write-Verbose -Message "Returning statically defined list of supported language pairs because no ApiKey was specified to query the DeepL Api service."
    }
    else {
        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

        try {
            # Set the authorization header.
            $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

            # Set parameters for the Invoke-RestMethod cmdlet.
            $Params = @{
                Method  = 'GET'
                Uri     = "$BaseUri/glossary-language-pairs"
                Headers = $Headers                    
            }
                
            # Try to retrieve the list of supported languages that can be used for a glossary.
            Write-Verbose -Message "Calling Uri: $($Params.Uri)"
            $GlossaryLanguagePairs = Invoke-RestMethod @Params
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
            Write-Error -ErrorRecord $_
        }
    }
        
    # Return the list of language pairs, that either was retrieved from the DeepL Api, or in case of error created statically in this script.
    $GlossaryLanguagePairs.supported_languages
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
