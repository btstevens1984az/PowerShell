# Purpose: CreateRefwithForwardSlash — General-purpose PowerShell utilities.
$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey("LocalMachine","default")
$testkey = $reg.OpenSubKey("SOFTWARE\Test",$true)
$testkey.CreateSubKey('RC4 128/128')
