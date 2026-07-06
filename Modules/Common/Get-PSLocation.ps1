# Purpose: Get-PSLocation — Reusable PowerShell function libraries.
Function Get-PSLocation {
    [cmdletbinding()]
    Param()
   
    if ($isLinux) {
        $ThisHome = $Env:HOME
    }
    else {
        #must be running Windows
        $ThisHome = Join-Path -Path $env:UserProfile -ChildPath Documents
    }

    [PSCustomObject]@{
        Temp = [system.io.path]::GetTempPath()
        Home = $ThisHome
        Desktop = [system.environment]::GetFolderPath("Desktop")
        PowerShell = Split-Path $profile
    }

} #close Get-PSLocation