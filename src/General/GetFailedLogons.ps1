# Purpose: GetFailedLogons — General-purpose PowerShell utilities.
Function Get-FailedLogon
{
[cmdletbinding()]
    param($computerName = "localhost")
    Get-EventLog -LogName Security -EntryType FailureAudit -InstanceId 4625 -ComputerName $computerName  |
    Add-Member -MemberType ScriptProperty -Name SubjectAccountName -Value {$this.ReplacementStrings[1]} -PassThru |
    Add-Member -MemberType ScriptProperty -Name TargetAccountName -Value {$this.ReplacementStrings[5]} -PassThru |
    Add-Member -MemberType ScriptProperty -Name SubjectDomain -Value {$this.ReplacementStrings[2]} -PassThru |
    Add-Member -MemberType ScriptProperty -Name TargetDomain -Value {$this.ReplacementStrings[6]} -PassThru  |
    Add-Member -MemberType ScriptProperty -Name FailureCode -Value {$this.ReplacementStrings[9]} -PassThru  |
    Add-Member -MemberType ScriptProperty -Name FailureReason -Value {
                    switch ($this.failureCode)
                    {
                    "0xC0000064" {"user name does not exist"}
                    "0xC000006A" {"user name is correct but the password is wrong"}
                    "0xC0000234" {"user is currently locked out"}
                    "0xC0000072" {"account is currently disabled"}
                    "0xC000006F" {"user tried to logon outside his day of week or time of day restrictions"}
                    "0xC0000071" {"expired password"}
                    "0xC0000193" {"account expiration"}
                    "0xC0000133" {"clocks between DC and other computer too far out of sync"}
                    "0xC0000224" {"user is required to change password at next logon"}
                    "0xC0000070" {"workstation restriction, or Authentication Policy Silo violation (look for event ID 4820 on domain controller)"}
                    "0xc000015b" {"The user has not been granted the requested logon type (aka logon right) at this machine"}
                    default {"unknown reason"}

                    }
                    
                    } -PassThru |
    Where-Object TargetAccountName -ne "-"
}

$logs = Get-FailedLogon
$logs | select * | ogv
#$r = $logs[0].Message | Select-String -Pattern "Account Name"

Function Get-FailedLogon
{
[cmdletbinding()]
    param($computerName = "localhost")
    $SubjectAccountName = @{
                            name = "SubjectAccountName"
                            expression= {$_.ReplacementStrings[1]}
                           }
    $SubjectDomain = @{
                        name = "SubjectDomain"
                        expression = {$_.ReplacementStrings[2]}
                      }
    $TargetAccountName = @{
                            name = "TargetAccountName"
                            expression = {$_.ReplacementStrings[5]}
                            }
    $TargetDomain = @{
                        name = "TargetDomain"
                        expression = {$_.ReplacementStrings[6]}
                        }
    Get-EventLog -LogName Security -EntryType FailureAudit -InstanceId 4625 -ComputerName $computerName  |
    Select-Object -Property $TargetAccountName,$TargetDomain,$SubjectAccountName,$SubjectDomain,* |
    Where-Object TargetAccountName -ne "-"
}

