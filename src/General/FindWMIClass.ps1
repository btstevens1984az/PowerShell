# Purpose: FindWMIClass — General-purpose PowerShell utilities.
Function findWMIClass
{
	param([string]$Strsearch="Win32",[string]$strcomputer=".",[string]$namespace="root\cimv2")
	gwmi -namespace "$namespace" -ComputerName "$strcomputer" -list | ?{"$_.__CLASS" -match $strSearch}
}

findWMIClass "Cim" "localhost" "root\wmi"