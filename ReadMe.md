# DeeplTranslate

## About

This PowerShell module uses the DeepL Api service to translate text or files. It also allows to manage glossaries and retrieve usage information.
For more information about the DeepL service refert to <https://www.deepl.com/pro-api>.

## Functions in this module

* Get-DeeplGlossary
* Get-DeeplGlossaryDetail
* Get-DeeplGlossaryEntry
* Get-DeeplGlossarySupportedLanguagePair
* Get-DeeplSupportedLanguage
* Get-DeeplUsage
* Invoke-DeeplTranslateFile
* Invoke-DeeplTranslateText
* New-DeeplGlossary
* Remove-DeeplGlossary

## Invoke-DeeplTranslateFile

The 'Invoke-DeeplTranslateFile' function allows to translate a file using the DeepL API. Supported file types are .docx, .pptx, .pdf, .htm, .html, .txt.

Example:

``` PowerShell
Invoke-DeeplTranslateFile -InputFile C:\Temp\SourceDoc.docx -OutputPath C:\Temp\Output -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "<MyApiKey>"
```

## Invoke-DeeplTranslateText

The 'Invoke-DeeplTranslateText' function translates text using the DeepL API.

Example:

``` PowerShell
Invoke-DeeplTranslateText -TextToTranslate "PowerShell is cool!" -SourceLanguage "EN" -TargetLanguage "DE" -ApiKey "MyApiKey"
```

``` PowerShell
   SourceText              : PowerShell is cool!
   TargetText              : PowerShell ist cool!
   DetectedSourceLanguage  : EN
   SpecifiedSourceLanguage : EN
   SpecifiedTargetLanguage : DE
   OriginalResponse        : @{translations=System.Object[]}
```

## Get-DeeplGlossary

The 'Get-DeeplGlossary' function retrieves all glossaries and their meta-information, but not the glossary entries.

Example:

``` PowerShell
Get-DeeplGlossary -ApiKey "<MyApiKey>"
```

``` PowerShell
    glossary_id   : f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed
    name          : My Glossary
    ready         : True
    source_lang   : en
    target_lang   : de
    creation_time : 31.10.2022 21:39:37
    entry_count   : 1
```

## Get-DeeplGlossaryDetail

The 'Get-DeeplGlossaryDetail' function retrieves a glossary and its meta-information, but not the glossary entries.

Example:

``` PowerShell
Get-DeeplGlossaryDetail -ApiKey "<MyApiKey>" -GlossaryId 46fd68a5-63cc-42b2-86f0-5b84bfd4bbd3
```

``` PowerShell
    glossary_id   : 46fd68a5-63cc-42b2-86f0-5b84bfd4bbd3
    name          : My Glossary
    ready         : True
    source_lang   : en
    target_lang   : de
    creation_time : 29.10.2022 21:06:35
    entry_count   : 1
```

## Get-DeeplGlossaryEntry

The 'Get-DeeplGlossaryEntry' function retrieves a list of entries of a glossary in the format specified by the 'Format' parameter.

Example:

``` PowerShell
Get-DeeplGlossaryEntry -ApiKey "<MyApiKey>" -GlossaryId 46fd68a5-63cc-42b2-86f0-5b84bfd4bbd3
```

``` PowerShell
    GlossaryId                             GlossaryContent
    ----------                             ---------------
    {f9a2a12f-9dec-4ca0-b9bd-cb3d9c645aed} Hello    Guten Tag
```

## Get-DeeplGlossarySupportedLanguagePair

The 'Get-DeeplGlossarySupportedLanguagePair' function retrieves a list of supported language pairs that can be used in a glossary.

Example:

``` PowerShell
Get-DeeplGlossarySupportedLanguagePair -ApiKey "<MyApiKey>"
```

``` PowerShell
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
```

## Get-DeeplSupportedLanguage

The 'Get-DeeplSupportedLanguage' function retrieves the supported source and target langueges of the DeepL Api.

Example:

``` PowerShell
Get-DeeplSupportedLanguage -ApiKey "<MyApiKey>"
```

``` PowerShell
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
```

## Get-DeeplUsage

The 'Get-DeeplUsage' function retrieves usage information within the current billing period together with the corresponding account limits.

Example:

``` PowerShell
Get-DeeplUsage -ApiKey "<MyApiKey>"
```

``` PowerShell
    character_count character_limit ApiKeyPart
    --------------- --------------- ----------
             491290          500000 abcde
```

## New-DeeplGlossary

The 'New-DeeplGlossary' function creates a new glossary for a DeepL account with the source and target language entries.

Example:

``` PowerShell
New-DeeplGlossary -Verbose -ApiKey <MyApiKey> -Name "MyGlossary" -Entry "Hello`tGuten Tag" -EntryFormat TSV -LanguagePair en..de 
```

``` PowerShell
    glossary_id   : 57dda93f-597f-494f-88e2-c1771de8a530
    name          : MyGlossary
    ready         : True
    source_lang   : en
    target_lang   : de
    creation_time : 01.11.2022 18:19:54
    entry_count   : 1
```

## Remove-DeeplGlossary

The function 'Remove-DeeplGlossary' removes a glossary with a specific glossary id for a given DeepL account.

Example:

``` PowerShell
Remove-DeeplGlossary -Verbose -ApiKey <MyApiKey> -GlossaryId 7ba6e514-4022-4cdc-91d3-d5b4c9e3c731
```

``` PowerShell
    Successfully removed glossary with id '7ba6e514-4022-4cdc-91d3-d5b4c9e3c731'
```
