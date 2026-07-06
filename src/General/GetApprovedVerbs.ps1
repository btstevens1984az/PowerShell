# Purpose: GetApprovedVerbs — General-purpose PowerShell utilities.
#http://msdn.microsoft.com/en-us/library/windows/desktop/ms714428(v=vs.85).aspx
function Get-ApprovedVerbs
{
[System.Management.Automation.VerbsCommon] | Get-Member -Static -MemberType property | select -ExpandProperty name
[System.Management.Automation.VerbsCommunications] | Get-Member -Static -MemberType property | select -ExpandProperty name
[System.Management.Automation.VerbsData] | Get-Member -Static -MemberType property | select -ExpandProperty name
[System.Management.Automation.VerbsDiagnostic] | Get-Member -Static -MemberType property| select -ExpandProperty name
[System.Management.Automation.VerbsLifeCycle] | Get-Member -Static -MemberType property| select -ExpandProperty name
[System.Management.Automation.VerbsSecurity] | Get-Member -Static -MemberType property| select -ExpandProperty name
[System.Management.Automation.VerbsOther] | Get-Member -Static -MemberType property| select -ExpandProperty name
}

$ApprovedVerbs =Get-ApprovedVerbs

$cmds = Get-Command -CommandType cmdlet,function | where {$_.verb}
$cmds | Where-Object {$reservedVerbs -notcontains $_.verb}