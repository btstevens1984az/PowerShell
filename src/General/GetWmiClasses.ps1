# Purpose: GetWmiClasses — General-purpose PowerShell utilities.
Function GetWmiClasses(
                       $Computername = 'localhost',
                       $NameSpace = 'root\cimv2',
                       $Class = 'disk'
                      )
{
 Get-WmiObject �List �computername $computername �namespace $namespace |
 Where-Object { $_.name �match $class-AND $_.name �notmatch '^cim' }
}
