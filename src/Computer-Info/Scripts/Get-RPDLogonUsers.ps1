# Purpose: Get-RPDLogonUsers — Computer hardware and system inventory.
function Get-RDPLogonUsers
{
    param(
    [parameter(
    Mandatory=$false,
    ValueFromPipeline=$True,
    Position = 0,
    HelpMessage="Enter a RDP server name")]
    $computerName = "localhost")
    process
    {
        $RDPLogons = Get-WmiObject Win32_logonSession -Filter "logontype=10 or logontype=2" -ComputerName $computerName #logontype 2 is interactive or admin RDP sessions
        $RDPUsers = $RDPLogons |
        ForEach-Object  {
                            gwmi -computername $computerName -query "ASSOCIATORS OF {Win32_LogonSession.LogonId=$($_.logonid)} WHERE resultClass=Win32_account" 
                        }
        $RDPUsers                   
    }
}

 Get-RDPLogonUsers

#gwmi -query "ASSOCIATORS OF {Win32_LogonSession.LogonId=382785} WHERE resultClass=Win32_account" 
