# Purpose: FixDNSRegistration — Network diagnostics, DNS, DHCP, and connectivity.
$servers = get-content .\computers.txt
Get-DnsClient -CimSession $servers |
    Select-object  PsComputerName,Interface*,Register* |
    Where-Object {$_.InterfaceAlias -like "backup*"} |
     Out-GridView -PassThru | 
     ForEach-Object {
        Set-DnsClient -InterfaceAlias $_.InterfaceAlias -CimSession $_.PScomputerName -RegisterThisConnectionsAddress $false -Verbose
        }