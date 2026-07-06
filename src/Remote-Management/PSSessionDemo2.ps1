# Purpose: PSSessionDemo2 — PowerShell automation.
#PsConfigurationFile Cmdlets require Powershell Version 3
Set-PSSessionConfiguration -Name "microsoft.powershell" -ShowSecurityDescriptorUI
Unregister-PSSessionConfiguration -Name "GetOnly"
$visableCmdlets = "Get-*","Measure-*","select-*","Format-*","where-object","Foreach-object", "enter-*", "exit-*","out-*"
$visableCmdlets = "Close-SmbOpenFile", "get-SmbOpenFile"
New-PSSessionConfigurationFile -VisibleCmdlets $visableCmdlets -Path "c:\temp\GetSessions2.pssc"
$RunAsCred = Get-Credential
Register-PSSessionConfiguration -Name "CloseSMBFiles" -Path "c:\temp\GetSessions2.pssc" -RunAsCredential $RunAsCred -ShowSecurityDescriptorUI
#PSH Version 2 method http://blogs.msdn.com/b/powershell/archive/2008/12/24/configuring-powershell-for-remoting-part-1.aspx
Register-PSSessionConfiguration -name "UseStartup" -StartupScript "c:\temp\PSSessionStatupScript.ps1"

<#
    The following Disables the default remoting session:
    Disable-PSSessionConfiguration -Name Microsoft.PowerShell
    Consider just changing the permissions to the default configuration.en
    Undo:
    Get-PSSessionConfiguration "microsoft.powershell"  |Enable-PSSessionConfiguration

    To restore the original property values of a default session
    configuration, use the Unregister-PSSessionConfiguration to
    delete the session configuration and then use the
    Enable-PSRemoting cmdlet to recreate it.
#>

#Run the following from a remote computer
$computername = "PshDemo"
Invoke-Command -ScriptBlock {Get-Process notepad | Stop-Process} -ConfigurationName Getonly -ComputerName $computername
Invoke-Command -ScriptBlock {Get-SmbOpenFile | Close-SmbOpenFile} -ConfigurationName CloseSMBFiles -ComputerName $computername
Enter-PSSession -ComputerName $computername -ConfigurationName Getonly
#Use the automaticvariable to avoid havnig to specific configuration name every time.
#$PSSessionConfigurationName = "getonly"


<#
Change Security
#use GUI
Set-PSSessionConfiguration -ShowSecurityDescriptorUI -name "getonly"
#Grab SDDL for reuse
$SDDL = (Get-PSSessionConfiguration getonly).SecurityDescriptorSddl
Set-PSSessionConfiguration -SecurityDescriptorSddl $sddl -Name "getonly"
#>