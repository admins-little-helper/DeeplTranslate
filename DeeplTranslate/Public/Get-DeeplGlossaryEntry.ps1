<#PSScriptInfo

.VERSION 1.0.0

.GUID 337d9180-539b-4d9a-bd33-7dacb540c496

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
Contains a function to retrieve a list of entries of a glossary for a DeepL account.
More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

.LINK
https://www.deepl.com

.LINK
https://www.deepl.com/de/docs-api/introduction/

#>


function Get-DeeplGlossaryEntry {
    <#
    .SYNOPSIS
    Retrieves a list of entries of a glossary.

    .DESCRIPTION
    The 'Get-DeeplGlossaryEntry' function retrieves a list of entries of a glossary in the format specified by the 'Format' parameter.

    .PARAMETER ApiKey
    API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .PARAMETER GlossaryId
    The glossary id for which you want to retrieve a list of entries.

    .PARAMETER Format
    The requested format of the returned glossary entries. Currently, supports only text/tab-separated-values.

    .EXAMPLE
    Get-DeeplGlossaryEntry -ApiKey "<MyApiKey>" -GlossaryId 46fd68a5-63cc-42b2-86f0-5b84bfd4bbd3

    GlossaryId                             GlossaryContent
    ----------                             ---------------
    {f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed} Hello    Guten Tag

    This example shows how to retrieve the entries for a glossary.

    .EXAMPLE
    (Get-DeeplGlossary -Verbose -ApiKey "<MyApiKey>").glossary_id | Get-DeeplGlossaryEntry -Verbose -ApiKey "<MyApiKey>"

    GlossaryId                             GlossaryContent
    ----------                             ---------------
    {f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed} Hello    Guten Tag
    {e6e08347-eeb1-4b09-87d0-7563dc8b9c3a} Bye      Tschüß…

    This example shows how to retrieve a list of glossaries and pipe the glossary id to get the glossary entries for each glossary.

    .INPUTS
    System.Guid for parameter 'GlossaryId'

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplGlossaryEntry.txt

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Guid[]]
        $GlossaryId,

        [ValidateSet("TSV")]
        [string]
        $Format
    )

    process {
        foreach ($GlossaryIdItem in $GlossaryId) {
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
                # Set the authorization header and format in which to retrieve data.
                $Headers = @{
                    Authorization = "DeepL-Auth-Key $ApiKey"
                    Accept        = switch ($Format) {
                        'TSV' {
                            'text/tab-separated-values'
                        }
                        default {
                            'text/tab-separated-values'
                        }
                    }
                }

                # Set parameters for the Invoke-RestMethod cmdlet.
                $Params = @{
                    Method  = 'GET'
                    Uri     = "$BaseUri/glossaries/$GlossaryIdItem/entries"
                    Headers = $Headers
                }
                
                # Try to retrieve the list of entries for the given GlossaryId.
                Write-Verbose -Message "Calling Uri: $Uri"
                $Glossary = Invoke-RestMethod @Params
                $Result = [PSCustomObject]@{
                    GlossaryId      = $GlossaryId
                    GlossaryContent = $Glossary
                }

                # Return the result.
                $Result
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
