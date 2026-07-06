# Purpose: SCCM-SoftwareInstallFromList — Configuration Manager collections and deployments.
<#
SYNOPSIS:
   SCCM application installer importing target machines from .txt
   James Wylde
VERSION:
   0.1
FUNCTIONALITY:
   Script uses Invoke-CIMMethod (in favour of Invoke-WMIObject - can be shared if required) to invoke and install applied SCCM packagges (OS/TaskSequencer in other script) after pinging and enabling WinRM through PAEXEC. Created for installs only, for adapation change '-MethodName' to Uninstall. Args currently to 'High Priority' and reboot is being supressed (not required for this app). Hashtable is currently set to filter on a RESULT of 0(ZERO) as success - documentation advises of other Evaluation State Value for success and so any other values will result in failure when this may not be true. 
   
   Before changing, please read documentation https://docs.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/sdk/ccm_application-client-wmi-class for detailing of Arguments, Methods and Results.
#>

#----------------------------------------------------------------------------------------#

$ErrorActionPreference = 'SilentlyContinue'

#----------------------------------------------------------------------------------------#

CLS

Start-Transcript -Path c:\temp\SAP760progress.txt -Append

$computers = Get-Content -Path c:\temp\sapcomputers.txt
try{
    foreach ($computer in $computers) {
        if(!(Test-Connection $computer -Count 1 -Quiet)) {
            "$computer                                                                           Failure"
        }

        else{

            C:\windows\paexec.exe paexec.exe \\$computer  -s winrm.cmd quickconfig -q

            $appName = 'SAP Logon For Windows_x86_7.60_ML'

            $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $computer | Where-Object {$_.Name -like $AppName})

            $ccmArgs = @{EnforcePreference = [UINT32] 0
            Id = "$($Application.id)"
            IsMachineTarget = $Application.IsMachineTarget
            IsRebootIfNeeded = $False
            Priority = 'High'
            Revision = "$($Application.Revision)" }

            $Instance = @(Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computer | Where-Object {$_.Name -like $AppName})
            Invoke-CimMethod -Namespace ROOT\ccm\ClientSDK -ClassName CCM_Application -ComputerName $computer -MethodName Install -Arguments $ccmArgs |
            Select-Object @{Name = 'Computer Name'; Expression = {$_.PSComputerName}},@{Name = 'Result'; Expression = { if($_.ReturnValue -eq 0) {'Success'} else {'Error'}}} 

        }
    
}
}
catch{}


#----------------------------------------------------------------------------------------#

# Formatting of Failure is temporary
# PAExec crashes around 50 runs - resumes on 'X' rather than 'Close application'




Invoke-Command -ComputerName 190.118.35.77 -ScriptBlock {

   $appName = 'ANALYSISFOROFFICE_xMA_2.8SP03Patch1_ML'
   
   $Application = (Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $computer | Where-Object {$_.Name -like $AppName})
   
   $ccmArgs = @{EnforcePreference = [UINT32] 0
   Id = "$($Application.id)"
   IsMachineTarget = $Application.IsMachineTarget
   IsRebootIfNeeded = $False
   Priority = 'High'
   Revision = "$($Application.Revision)" }
   
   $Instance = @(Get-CimInstance -ClassName CCM_Application -Namespace "root\ccm\clientSDK" -ComputerName $Computer | Where-Object {$_.Name -like $AppName})
   Invoke-CimMethod -Namespace ROOT\ccm\ClientSDK -ClassName CCM_Application -ComputerName $computer -MethodName Install -Arguments $ccmArgs |
   Select-Object @{Name = 'Computer Name'; Expression = {$_.PSComputerName}},@{Name = 'Result'; Expression = { if($_.ReturnValue -eq 0) {'Success'} else {'Error'}}} 
   
   }