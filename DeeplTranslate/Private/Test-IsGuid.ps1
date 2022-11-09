<#PSScriptInfo

.VERSION 1.0.0

.GUID 742ed46a-8db5-4392-a925-6c8fd8d673c0

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
Contains a function to test if a given string is a valid GUID.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

#>


function Test-IsGuid {
    <#
    .SYNOPSIS
    Validates a given input string and checks if it is a valid GUID.
    
    .DESCRIPTION
    Validates a given input string and checks if it is a valid GUID.

    .PARAMETER InputObject
    String value to test.
    
    .EXAMPLE
    Test-Guid -InputObject "3363e9e1-00d8-45a1-9c0c-b93ee03f8c13"
    
    .INPUTS
    System.String

    .OUTPUTS
    System.Boolean

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Test-IsGuid.txt
    
    #>

    [Cmdletbinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [string[]]$InputObject
    )
    process {
        foreach ($InputObjectElement in $InputObject) {
            [guid]::TryParse($InputObjectElement, $([ref][guid]::Empty))
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
