# Purpose: Get-NameSpace — General-purpose PowerShell utilities.
Function Get-NameSpace {
  param (
    [Parameter(Mandatory=$false)]
    [string[]]$computername
  )

$ComputerName = "saclhum28" 
$Domain = "example.com"
$Credential = Get-Credential
$ColItems = Get-WmiObject -Class Win32_Process -Authority "ntlmdomain:$Domain" `
-Credential $Credential -Locale "MS_409" -Namespace "root\cimv2"  -ComputerName $Computer

foreach ($ObjItem in $colItems) 
    {
    write-host "Process Name:" $ObjItem.name
    }
}