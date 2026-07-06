# Purpose: PSScriptMethod — General-purpose PowerShell utilities.
$filePath = ".\EtsDemo.txt"
if (-not (Test-Path $filePath))
{Set-Content -Value "Demo Text" -Path $filePath -Force}
$file = Get-ChildItem $filePath

$file | Add-Member -MemberType ScriptMethod -Name EnableAttribute -value {
 
param(
[ValidateSet("ReadOnly","Hidden","System","Directory","Archive","Device",
"Normal","Temporary","SparseFile","ReparsePoint","Compressed","Offline",
"NotContentIndexed","Encrypted"
)]
$attrib
) 
    if (-not ($this.attributes -band [system.io.fileattributes]::$attrib)) {
    $this.attributes = $this.attributes -bxor [system.io.fileattributes]::$attrib
    "Setting $attrib attribute on $($this.fullname)"
    }
    else
    {
    "$attrib attribute already enabled on $($this.fullname)"
    }
}

$file.EnableAttribute("ReadOnly")

$file | Remove-Item -Force -Confirm