<#PSScriptInfo

.VERSION 1.1.0

.GUID 24ec36da-f272-484c-a80a-2006aedcc016

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
Contains a function to retrieve all glossaries and their meta-information, but not the glossary entries for a DeepL account.
More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

.LINK
https://www.deepl.com

.LINK
https://www.deepl.com/de/docs-api/introduction/

 #>


function Get-DeeplGlossary {
    <#
    .SYNOPSIS
    Retrieves all glossaries and their meta-information, but not the glossary entries.

    .DESCRIPTION
    The 'Get-DeeplGlossary' function retrieves all glossaries and their meta-information, but not the glossary entries.

    .PARAMETER ApiKey
    API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .EXAMPLE
    Get-DeeplGlossary -ApiKey "<MyApiKey>"

    glossary_id   : f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed
    name          : My Glossary
    ready         : True
    source_lang   : en
    target_lang   : de
    creation_time : 31.10.2022 21:39:37
    entry_count   : 1

    This example shows how to retrieve a list of all glossaries of a DeepL account.

    .EXAMPLE
    Get-DeeplGlossary -ApiKey "<MyApiKey>" | ft

    glossary_id                          name        ready source_lang target_lang creation_time       entry_count
    -----------                          ----        ----- ----------- ----------- -------------       -----------
    f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed My Glossary  True en          de          31.10.2022 21:39:37           1
    f9077ca0-66ab-4a16-afaf-1ce332feab50 My Glossary  True en          de          31.10.2022 21:43:56           1

    This example shows how to retrieve a list of glossaries and format the output as table.

    .INPUTS
    Nothing

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplGlossary.txt

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey
    )

    $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

    try {
        # Set the authorization header.
        $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

        # Set parameters for the Invoke-RestMethod cmdlet.
        $Params = @{
            Method  = 'GET'
            Uri     = "$BaseUri/glossaries"
            Headers = $Headers                    
        }
                
        # Try to retrieve the list of glossaries.
        Write-Verbose -Message "Calling Uri: $($Params.Uri)"
        $Glossary = Invoke-RestMethod @Params
                
        # Return the result
        $Result = $Glossary.glossaries
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
