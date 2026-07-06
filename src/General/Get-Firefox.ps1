# Purpose: Get-Firefox — General-purpose PowerShell utilities.
function Get-iTunes{
    param
    (
        #[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$cn
    )
        $iTunes = "\\" + $cn + "\c$\Program Files (x86)\iTunes\iTunes.exe"
        if(Test-Path $iTunes) {
            $VersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($iTunes)
            write-host $cn "has iTunes version" $VersionInfo.FileVersionRaw "installed"
                    } else {
            write-host $cn "does not have an instance of iTunes installed"
        }
    } else {
        write-host $cn "offline"
 }