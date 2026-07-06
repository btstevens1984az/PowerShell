# Purpose: SCCM-ProvisioningMode — Configuration Manager collections and deployments.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false

HKLM\SOFTWARE\Microsoft\CCM\CcmExec ProvisioningMode False


###


sc config smstsmgr demand= winmgmt/ccmexec
sc config smstsmgr start= demand
net start smstsmgr