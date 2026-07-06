# Purpose: Get-Chrome — General-purpose PowerShell utilities.
function Get-Chrome{
    param
    (
        #[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$cn
    )
        $chrome = "\\" + $cn + "\c$\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        if(Test-Path $chrome) {
            $VersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($chrome)
            write-host $cn  "has Chrome version" $VersionInfo.FileVersionRaw "installed"
        } else {
            write-host $cn "does not have an instance of Chrome installed"
        }
    } else {
        write-host $cn "offline"
 }