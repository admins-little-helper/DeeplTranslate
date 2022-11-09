<#PSScriptInfo

.VERSION 1.0.0

.GUID 26811398-0439-4815-b931-4c1673a0373c

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
Contains a function to retrieve the DeepL API Uri based on a given ApiKey value.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

#>


function Get-DeeplApiUri {
    <#
    .SYNOPSIS
    Retrieves the DeepL API Uri based on a given ApiKey value.
    
    .DESCRIPTION
    Retrieves the DeepL API Uri based on a given ApiKey value.

    .PARAMETER ApiKey
    DeepL Api Key string value.
    
    .EXAMPLE
    Get-DeeplApiUri ApiKey "3363e9e1-00d8-45a1-9c0c-b93ee03f8c13"

    This example will return the DeepL Pro service URI because the ApiKey does not end with ':fx'.
    
    .EXAMPLE
    Get-DeeplApiUri ApiKey "3363e9e1-00d8-45a1-9c0c-b93ee03f8c13:fx"

    This example will return the DeepL Free service URI because the ApiKey ends with ':fx'.
    
    .INPUTS
    System.String

    .OUTPUTS
    System.String

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplApiUri.txt
    
    #>

    [Cmdletbinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $ApiKey
    )
    
    process {
        foreach ($ApiKeyElement in $ApiKey) {
            # Set the base URI to either the DeepL API Pro or DeepL API Free service depending on the ApiKey value specified.
            # DeepL API Free authentication keys can be identified easily by the suffix ":fx" (e.g., 279a2e9d-83b3-c416-7e2d-f721593e42a0:fx).
            # For more information refer to https://www.deepl.com/docs-api/api-access/authentication/.
            $BaseUri = if ($ApiKeyElement -match "(:fx)$") {
                Write-Verbose -Message "The ApiKey specified ends with ':fx'. Using DeepL Api Free service URI."
                'https://api-free.deepl.com/v2'
            }
            else {
                Write-Verbose -Message "The ApiKey specified does not end with ':fx'. Using DeepL Api Pro service URI."
                'https://api.deepl.com/v2'
            }

            $BaseUri
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
