# Purpose: DP16_Step01-ConfigureSCCM — General-purpose PowerShell utilities.
﻿# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$DomainDNSname = $env:USERDNSDOMAIN
$Domainname = $env:USERDOMAIN
$ServerName = $env:COMPUTERNAME

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Open the firewall ports on this DP
Write-Host "Opening firewall ports needed for a DP"
Write-Host "Opening TCP ports 135 and 445"
New-NetFirewallRule -DisplayName "SCCM 2016 DPs (TCP)" -Direction Inbound -Action Allow -LocalPort 135,445 -Protocol tcp
Write-Host ""
Write-Host "Opening UDP port 445"
New-NetFirewallRule -DisplayName "SCCM 2016 DPs (UDP)" -Direction Inbound -Action Allow -LocalPort 445 -Protocol udp
Write-Host "Done!"
Write-Host ""
Write-Host "Adding CM16 to the local Administrators group"
$groupname = 'Administrators'
$AdminGrp = [ADSI]("WinNT://$ServerName/$groupname,group")
$AdminGrp.psbase.Invoke("Add",([ADSI]"WinNT://$Domainname/CM16$").path)

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
