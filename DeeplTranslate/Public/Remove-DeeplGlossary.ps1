<#PSScriptInfo

.VERSION 1.1.0

.GUID fcf269da-7b59-40ca-844d-ef4712844bd0

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

    1.0.1
    Fixed issue with empty Uri in verbose output.

    1.1.0
    Updated way to get DeepL Api Uri and Http Status codes.

#>


<#

.DESCRIPTION
    Contains a function to remove a glossary that exist for a DeepL account.
    More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

    To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
    https://github.com/admins-little-helper/DeeplTranslate

.LINK
    https://www.deepl.com

.LINK
    https://www.deepl.com/de/docs-api/introduction/

#>


function Remove-DeeplGlossary {
    <#
    .SYNOPSIS
        Removes a glossary that exist for a DeepL account.

    .DESCRIPTION
        The function 'Remove-DeeplGlossary' removes a glossary with a specific glossary id for a given DeepL account.

    .PARAMETER ApiKey
        API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .PARAMETER GlossaryId
        The glossary id for which you want to retrieve detail information.

    .EXAMPLE
        Remove-DeeplGlossary -Verbose -ApiKey <MyApiKey> -GlossaryId 7ba6e514-4022-4cdc-91d3-d5b4c9e3c731

        Successfully removed glossary with id '7ba6e514-4022-4cdc-91d3-d5b4c9e3c731'

        This example shows how to remove a glossary with id '7ba6e514-4022-4cdc-91d3-d5b4c9e3c731'

    .INPUTS
        Nothing

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Author:     Dieter Koch
        Email:      diko@admins-little-helper.de

    .LINK
        https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Remove-DeeplGlossary.txt

    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Guid[]]
        $GlossaryId
    )

    begin {
        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey
    }

    process {
        foreach ($GlossaryIdItem in $GlossaryId) {
            try {
                # Set the authorization header.
                $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

                # Set parameters for the Invoke-RestMethod cmdlet.
                $Params = @{
                    Method  = 'DELETE'
                    Uri     = "$BaseUri/glossaries/$GlossaryIdItem"
                    Headers = $Headers
                }

                # Try to retrieve the list of supported source or target languages.
                Write-Verbose -Message "Calling Uri: $($Params.Uri)"

                if ($PSCmdlet.ShouldProcess($GlossaryID, 'DELETE')) {
                    $Glossary = Invoke-RestMethod @Params
                    if ([string]::IsNullOrEmpty($Glossary)) {
                        Write-Information -MessageData "Successfully removed glossary with id '$GlossaryId'" -InformationAction Continue
                    }
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
