<#PSScriptInfo

.VERSION 1.0.0

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
        # Set the base URI to either the DeepL API Pro or DeepL API Free service depending on the ApiKey value specified.
        # DeepL API Free authentication keys can be identified easily by the suffix ":fx" (e.g., 279a2e9d-83b3-c416-7e2d-f721593e42a0:fx).
        # For more information refer to https://www.deepl.com/docs-api/api-access/authentication/.
        $BaseUri = if ($ApiKey -match "(:fx)$") {
            Write-Verbose -Message "The ApiKey specified ends with ':fx'. Using DeepL Api Free service URI."
            'https://api-free.deepl.com/v2'
        }
        else {
            Write-Verbose -Message "The ApiKey specified does not end with ':fx'. Using DeepL Api Pro service URI."
            'https://api.deepl.com/v2'
        }

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
            Write-Verbose -Message "Calling Uri: $Uri"
            $GlossaryLanguagePairs = Invoke-RestMethod @Params
        }
        catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            switch ( $_.Exception.Response.StatusCode ) {
                400 {
                    Write-Error -Message "Bad Request."
                }
                401 {
                    Write-Error -Message "Unauthorized."
                }
                403 {
                    Write-Error -Message "Authorization failed. Please supply a valid ApiKey."
                }
                404 {
                    Write-Error -Message "Not found."
                }
                413 {
                    Write-Error -Message "Payload too large."
                }
                414 {
                    Write-Error -Message "URI too long."
                }
                429 {
                    Write-Error -Message "Too many requests. Please wait and resend your request."
                }
                429 {
                    Write-Error -Message "Quota exceeded."
                }
                500 {
                    Write-Error -Message "Internal Server error."
                }
                503 {
                    Write-Error -Message "Resource currently unavailable. Try again later."
                }
                504 {
                    Write-Error -Message "Service unavailable."
                }
                529 {
                    Write-Error -Message "Too many requests. Please wait and resend your request."
                }
                default {
                    $_
                }
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
