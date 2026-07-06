# Purpose: Start-NMAPSCANonSubnet — Security auditing and compliance checks.
Function Start-NMAPSCANonSubnet {
# Powershell NMAP-NSE-MS17-010.v1.ps1
# This script will call nmap nse script to detect MS17-010 and then filter 
# the result to show a list of Host that are vulnerable to the samba vulnerability.
# Version: 1.00
# Changelog:  Currently a functionnal script that does the job without any of the 
#             colorful extras that you guys like. 
###
#
# USAGE: 
# 1. Update $subnets in the var section with all your internal subnet;
# 2. Create any relevant folder or edit the folder path below;
# 3. Install Nmap
# 4. Run the ps1 file with an unpriviledge user or schedule it to run via Taskschd
#
###
# Start of Var declaration
###
# This var should contain list of subnet, one per line. Use CIDR format.
$subnets = @(
"35.200.171.182/24"
);
###
# End of Var declaration
###
###
# Start of the Loop for the nmap scan for each subnet & store result in a file with date/time
###
foreach ($subnet in $subnets)
{
	$pos = $subnet.IndexOf("/")
	$IP = $subnet.Substring(0, $pos)
	$MASK = $subnet.Substring($pos+1)
    $filename = $IP
    $nmapfile = "C:\SCRIPTS\Results-smb-vuln-ms17-010\" + (Get-Date -Format "yyyy-MM-dd_HHmm")+ "_" +  $filename + ".txt"
    & 'C:\Program Files (x86)\nmap\nmap.exe' -p445 --open --script smb-vuln-ms17-010 -oN $nmapfile -v $subnet
}

###
# End of the loop for the nmap scan
###
# We scan through the Result folder and display a unique list of all vulnerable Host.
Select-String -path C:\SCRIPTS\Results-smb-vuln-ms17-010\*.txt -pattern "State: VULNERABLE" -Context 10,0 | out-string -stream | Select-String -pattern report |out-string -stream | %{"$($_.Split(' ')[6])"} | select -uniq
}