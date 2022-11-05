
#Get public and private function definition files.
$PublicScripts = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$PrivateScripts = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
foreach ($ScriptToImport in @($PublicScripts + $PrivateScripts)) {
    try {
        Write-Verbose -Message "Importing script $($ScriptToImport.FullName)"
        . $ScriptToImport.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($ScriptToImport.FullName): $_"
    }
}

Export-ModuleMember -Function $PublicScripts.Basename -Alias *
