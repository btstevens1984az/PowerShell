# Purpose: 6-2 2 EnumConvertDomainRole — Certification notes and learning materials.
$computers = "dc4","testsrv2","dc2"

Enum DomainRoleDesc
{
    StandaloneWorkstation   # = 0
    MemberWorkstation       # = 1
    StandaloneServer        # = 2
    MemberServer            # = 3
    BackupDomainController  # = 4
    PrimaryDomainController # = 5
}

$compInfo = Get-CimInstance -ComputerName $computers -ClassName Win32_computersystem
$compInfo | Add-Member -MemberType ScriptProperty -Name DomainRoleDesc -Value {[DomainRoleDesc]$this.domainrole}

$compinfo | Select-Object -Property PScomputername,domainRole,DomainRoleDesc




<#
#Previous technique to accomplish the same task.
#Con: more cumbersome to reuse
#Pro: can use spaces and other special characters in the name/description
$compInfo | Add-Member -MemberType ScriptProperty -Name DomainRoleDesc2 -Value {
    switch ($this.domainrole)
    {
        0{"Standalone Workstation"}
        1{"Member Workstation"}
        2{"Standalone Server"}
        3{"Member Server"}
        4{"Backup Domain Controller"}
        5{"Primary Domain Controller"}
    }
}
#>