<#PSScriptInfo

.VERSION 1.2.1

.GUID be34df32-8b54-4d68-b0cc-0e328e646d33

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

    1.2.0
    Added 'UsagePercent' to output.

    1.2.1
    Fixed issue in showing 'UsagePercent'.

#>


<#

.DESCRIPTION
    Contains a function to retrieve usage information for a DeepL account.
    More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

    To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
    https://github.com/admins-little-helper/DeeplTranslate

.LINK
    https://www.deepl.com

.LINK
    https://www.deepl.com/de/docs-api/introduction/

#>


function Get-DeeplUsage {
    <#
    .SYNOPSIS
        Retrieves usage information for a DeepL account.

    .DESCRIPTION
        The 'Get-DeeplUsage' function retrieves usage information within the current billing period together with the corresponding account limits.
        In addition to the data returned from the DeepL Api the output contains the first 5 charactes for the ApiKey.
        This is to identify the account in case multiple values are specified for the 'ApiKey' parameter.

    .PARAMETER ApiKey
        API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .EXAMPLE
        Get-DeeplUsage -ApiKey "<MyApiKey>"

        character_count character_limit ApiKeyPart
        --------------- --------------- ----------
                491290          500000 abcde

        This example shows how to retrieve the usage information for a DeepL account.

    .EXAMPLE
        "<MyApiKey_A>", "<MyApiKey_B>" | Get-DeeplUsage

        character_count character_limit ApiKeyPart
        --------------- --------------- ----------
                491290          500000 aaaaa
                    0          500000 bbbbb

        This example shows how to retrieve usage information for multiple DeepL accounts by piping two ApiKeys to the function.

    .INPUTS
        System.String for parameter 'ApiKey'

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Author:     Dieter Koch
        Email:      diko@admins-little-helper.de

    .LINK
        https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplUsage.txt

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ApiKey
    )

    process {
        foreach ($ApiKeyElement in $ApiKey) {
            $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

            try {
                # Set the authorization header.
                $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKeyElement" }

                # Set parameters for the Invoke-RestMethod cmdlet.
                $Params = @{
                    Method  = 'GET'
                    Uri     = "$BaseUri/usage"
                    Headers = $Headers
                }

                # Try to retrieve the DeepL Api usage information.
                Write-Verbose -Message "Calling Uri: $($Params.Uri)"
                $Usage = Invoke-RestMethod @Params
                $Usage | Add-Member -Name 'UsagePercent' -MemberType NoteProperty -Value $($Usage.character_count / $Usage.character_limit * 100)
                $Usage | Add-Member -Name 'ApiKeyPart' -MemberType NoteProperty -Value $ApiKeyElement.Substring(0, 5)
                $Usage
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
