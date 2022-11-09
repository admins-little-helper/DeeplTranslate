<#PSScriptInfo

.VERSION 1.1.0

.GUID c58c97a3-6664-4b38-af19-f12aca4715cc

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
  
    1.0.2
    Fixed issue with tab completion in case an ApiKey with an invalid format is specified.

    1.1.0
    Updated way to get DeepL Api Uri and Http Status codes.
    
#>


<#

.DESCRIPTION
Contains a function to retrieve the supported source and target langueges for the DeepL Api.
More information about the DeepL API can be found here: https://www.deepl.com/de/docs-api/introduction/.

To use this PowerShell function, a DeepL ApiKey is needed which requires an account. To register for an account, go to www.deepl.com.

.LINK
https://github.com/admins-little-helper/DeeplTranslate

.LINK
https://www.deepl.com

.LINK
https://www.deepl.com/de/docs-api/introduction/

#>


function Get-DeeplSupportedLanguage {
    <#
    .SYNOPSIS
    Retrieves the supported source and target langueges for the DeepL Api.

    .DESCRIPTION
    The 'Get-DeeplSupportedLanguage' function retrieves the supported source and target langueges of the DeepL Api.

    .PARAMETER ApiKey
    API authentication key. You need an authentication key to access the DeepL API. Refer to the DeepL API documentation for more information.

    .PARAMETER TargetLanguage
    If specified or set to $true, the functions returns the list of supported target languages.
    If ommitted or set to $false the functions returns the list of supported source languages.

    .EXAMPLE
    Get-DeeplSupportedLanguage -ApiKey "<MyApiKey>"

    language name
    -------- ----
    BG       Bulgarian
    CS       Czech
    DA       Danish
    DE       German
    EL       Greek
    EN       English
    ES       Spanish
    ET       Estonian
    FI       Finnish
    FR       French
    HU       Hungarian
    ID       Indonesian
    IT       Italian
    JA       Japanese
    LT       Lithuanian
    LV       Latvian
    NL       Dutch
    PL       Polish
    PT       Portuguese
    RO       Romanian
    RU       Russian
    SK       Slovak
    SL       Slovenian
    SV       Swedish
    TR       Turkish
    UK       Ukrainian
    ZH       Chinese

    This example shows how to retrieve a list of supported source languages.

    .EXAMPLE
    Get-DeeplSupportedLanguage -ApiKey "<MyApiKey>" -TargetLanguage

    language name                   supports_formality
    -------- ----                   ------------------
    BG       Bulgarian                           False
    CS       Czech                               False
    DA       Danish                              False
    DE       German                               True
    EL       Greek                               False
    EN-GB    English (British)                   False
    EN-US    English (American)                  False
    ES       Spanish                              True
    ET       Estonian                            False
    FI       Finnish                             False
    FR       French                               True
    HU       Hungarian                           False
    ID       Indonesian                          False
    IT       Italian                              True
    JA       Japanese                            False
    LT       Lithuanian                          False
    LV       Latvian                             False
    NL       Dutch                                True
    PL       Polish                               True
    PT-BR    Portuguese (Brazilian)               True
    PT-PT    Portuguese (European)                True
    RO       Romanian                            False
    RU       Russian                              True
    SK       Slovak                              False
    SL       Slovenian                           False
    SV       Swedish                             False
    TR       Turkish                             False
    UK       Ukrainian                           False
    ZH       Chinese (simplified)                False

    This example shows how to retrieve a list of supported target languages.

    .EXAMPLE
    Get-DeeplSupportedLanguage -ApiKey "<MyApiKey>" -TargetLanguage -Verbose

    VERBOSE: Provided ApiKey ends with ':fx'. Using DeepL Api Free service URI.
    VERBOSE: Parameter 'TargetLanguage' specified. Retrieving list of supported target languages.
    VERBOSE: Sending request.
    VERBOSE: GET with 0-byte payload
    VERBOSE: received 1871-byte response of content type application/json
    VERBOSE: Content encoding: utf-8

    language name                   supports_formality
    -------- ----                   ------------------
    BG       Bulgarian                           False
    CS       Czech                               False
    DA       Danish                              False
    DE       German                               True
    EL       Greek                               False
    EN-GB    English (British)                   False
    EN-US    English (American)                  False
    ES       Spanish                              True
    ET       Estonian                            False
    FI       Finnish                             False
    FR       French                               True
    HU       Hungarian                           False
    ID       Indonesian                          False
    IT       Italian                              True
    JA       Japanese                            False
    LT       Lithuanian                          False
    LV       Latvian                             False
    NL       Dutch                                True
    PL       Polish                               True
    PT-BR    Portuguese (Brazilian)               True
    PT-PT    Portuguese (European)                True
    RO       Romanian                            False
    RU       Russian                              True
    SK       Slovak                              False
    SL       Slovenian                           False
    SV       Swedish                             False
    TR       Turkish                             False
    UK       Ukrainian                           False
    ZH       Chinese (simplified)                False

    This example shows how to retrieve a list of supported target languages and showing verbose output.

    .EXAMPLE
    "<MyApiKey>" | Get-DeeplSupportedLanguage
    
    language name
    -------- ----
    BG       Bulgarian
    CS       Czech
    DA       Danish
    DE       German
    EL       Greek
    EN       English
    ES       Spanish
    ET       Estonian
    FI       Finnish
    FR       French
    HU       Hungarian
    ID       Indonesian
    IT       Italian
    JA       Japanese
    LT       Lithuanian
    LV       Latvian
    NL       Dutch
    PL       Polish
    PT       Portuguese
    RO       Romanian
    RU       Russian
    SK       Slovak
    SL       Slovenian
    SV       Swedish
    TR       Turkish
    UK       Ukrainian
    ZH       Chinese

    This example shows how to retrieve a list of supported source languages by piping the ApiKey.

    .INPUTS
    Nothing

    .OUTPUTS
    System.Management.Automation.PSCustomObject

    .NOTES
    Author:     Dieter Koch
    Email:      diko@admins-little-helper.de

    .LINK
    https://github.com/admins-little-helper/DeeplTranslate/blob/main/Help/Get-DeeplSupportedLanguage.txt

    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [switch]
        $TargetLanguage
    )
    
    # Set a default list of supported source languages to have something that this function will return in case
    # the Api call to retrieve the list of supported languages fails with an error.
    # This is list is valid as of 2022-10-30.
    $SupportedSourceLanguage = @(
        [PSCustomObject]@{
            "language" = "BG"
            "name"     = "Bulgarian"
        }
        [PSCustomObject]@{
            "language" = "CS"
            "name"     = "Czech"
        }
        [PSCustomObject]@{
            "language" = "DA"
            "name"     = "Danish"
        }
        [PSCustomObject]@{
            "language" = "DE"
            "name"     = "German"
        }
        [PSCustomObject]@{
            "language" = "EL"
            "name"     = "Greek"
        }
        [PSCustomObject]@{
            "language" = "EN"
            "name"     = "English"
        }
        [PSCustomObject]@{
            "language" = "ES"
            "name"     = "Spanish"
        }
        [PSCustomObject]@{
            "language" = "ET"
            "name"     = "Estonian"
        }
        [PSCustomObject]@{
            "language" = "FI"
            "name"     = "Finnish"
        }
        [PSCustomObject]@{
            "language" = "FR"
            "name"     = "French"
        }
        [PSCustomObject]@{
            "language" = "HU"
            "name"     = "Hungarian"
        }
        [PSCustomObject]@{
            "language" = "ID"
            "name"     = "Indonesian"
        }
        [PSCustomObject]@{
            "language" = "IT"
            "name"     = "Italian"
        }
        [PSCustomObject]@{
            "language" = "JA"
            "name"     = "Japanese"
        }
        [PSCustomObject]@{
            "language" = "LT"
            "name"     = "Lithuanian"
        }
        [PSCustomObject]@{
            "language" = "LV"
            "name"     = "Latvian"
        }
        [PSCustomObject]@{
            "language" = "NL"
            "name"     = "Dutch"
        }
        [PSCustomObject]@{
            "language" = "PL"
            "name"     = "Polish"
        }
        [PSCustomObject]@{
            "language" = "PT"
            "name"     = "Portuguese"
        }
        [PSCustomObject]@{
            "language" = "RO"
            "name"     = "Romanian"
        }
        [PSCustomObject]@{
            "language" = "RU"
            "name"     = "Russian"
        }
        [PSCustomObject]@{
            "language" = "SK"
            "name"     = "Slovak"
        }
        [PSCustomObject]@{
            "language" = "SL"
            "name"     = "Slovenian"
        }
        [PSCustomObject]@{
            "language" = "SV"
            "name"     = "Swedish"
        }
        [PSCustomObject]@{
            "language" = "TR"
            "name"     = "Turkish"
        }
        [PSCustomObject]@{
            "language" = "UK"
            "name"     = "Ukrainian"
        }
        [PSCustomObject]@{
            "language" = "ZH"
            "name"     = "Chinese"
        }
    )
    
    # Set a default list of supported target languages to have something that this function will return in case
    # the Api call to retrieve the list of supported languages fails with an error.
    # This is list is valid as of 2022-10-30.
    $SupportedTargetLanguage = @(
        [PSCustomObject]@{
            "language"           = "BG"
            "name"               = "Bulgarian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "CS"
            "name"               = "Czech"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "DA"
            "name"               = "Danish"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "DE"
            "name"               = "German"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "EL"
            "name"               = "Greek"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "EN-GB"
            "name"               = "English (British)"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "EN-US"
            "name"               = "English (American)"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "ES"
            "name"               = "Spanish"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "ET"
            "name"               = "Estonian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "FI"
            "name"               = "Finnish"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "FR"
            "name"               = "French"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "HU"
            "name"               = "Hungarian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "ID"
            "name"               = "Indonesian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "IT"
            "name"               = "Italian"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "JA"
            "name"               = "Japanese"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "LT"
            "name"               = "Lithuanian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "LV"
            "name"               = "Latvian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "NL"
            "name"               = "Dutch"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "PL"
            "name"               = "Polish"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "PT-BR"
            "name"               = "Portuguese (Brazilian)"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "PT-PT"
            "name"               = "Portuguese (European)"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "RO"
            "name"               = "Romanian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "RU"
            "name"               = "Russian"
            "supports_formality" = $true
        }
        [PSCustomObject]@{
            "language"           = "SK"
            "name"               = "Slovak"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "SL"
            "name"               = "Slovenian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "SV"
            "name"               = "Swedish"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "TR"
            "name"               = "Turkish"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "UK"
            "name"               = "Ukrainian"
            "supports_formality" = $false
        }
        [PSCustomObject]@{
            "language"           = "ZH"
            "name"               = "Chinese (simplified)"
            "supports_formality" = $false
        }
    )

    # Test if an ApiKey was specified and if it's a valid GUID (without a trailing ':fx' 'DeepL API free' marker)
    if ([string]::IsNullOrEmpty($ApiKey) -or (-not (Test-IsGuid($ApiKey -replace "(:fx)$", "")))) {
        # Return the list of statically defined language pairs, in case no ApiKey was specified.
        Write-Verbose -Message "Returning statically defined list of supported languages because no or an invalid ApiKey was specified to query the DeepL Api service."

        if ($TargetLanguage.IsPresent) {
            $SupportedLanguages = $SupportedTargetLanguage
        }
        else {
            $SupportedLanguages = $SupportedSourceLanguage
        }

        $SupportedLanguages
    }
    else {
        $BaseUri = Get-DeeplApiUri -ApiKey $ApiKey

        if ($TargetLanguage.IsPresent) {
            # Set the type parameter to value 'target' to retrieve a list of supported target languages.
            Write-Verbose -Message "Parameter 'TargetLanguage' specified. Retrieving list of supported target languages."
            $Uri = "$BaseUri/languages?type=target"
        }
        else {
            # Set the type parameter to value 'source' to retrieve a list of supported source languages.
            # The parameter 'type' is optional. If omitted, it will return a list of supported source languages. But we specifically set it here.
            Write-Verbose -Message "Retrieving list of supported source languages."
            $Uri = "$BaseUri/languages"
        }

        try {
            # Set the authorization header.
            $Headers = @{ Authorization = "DeepL-Auth-Key $ApiKey" }

            # Set parameters for the Invoke-RestMethod cmdlet.
            $Params = @{
                Method  = 'GET'
                Uri     = $Uri
                Headers = $Headers                    
            }

            # Try to retrieve the list of supported source or target languages.
            Write-Verbose -Message "Calling Uri: $($Params.Uri)"
            $SupportedLanguages = Invoke-RestMethod @Params
            $SupportedLanguages
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
