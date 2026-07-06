# Purpose: NETversionCheck — PowerShell automation.
#http://stackoverflow.com/questions/3487265/powershell-script-to-return-versions-of-net-framework-on-a-machine
#https://msdn.microsoft.com/en-us/library/hh925568
#https://msdn.microsoft.com/en-us/library/bb822049
#This still needs quite a bit of work and testing especially 
#against older servers with older versions of .net.
#also consider modifying to remove PSremoting requirement.
$SB  ={   
$Result =  Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version, Release, @{
  name="Product"
  expression={
      switch -regex ($_.Release) {
        "378389" { [Version]"4.5" }
        "378675|378758" { [Version]"4.5.1" }
        "379893" { [Version]"4.5.2" }
        "393295|393297" { [Version]"4.6" }
        "394254|394271" { [Version]"4.6.1" }
        "394802|394806" { [Version]"4.6.2" }
        {$_ -gt 394806} { "Undocumented 4.6.2 or higher"}
      }
    }
    }
$Result | Add-Member -MemberType NoteProperty -Name PSVersion -Value ($PSVersionTable.PSVersion.ToString())
$Result | Add-Member -MemberType NoteProperty -Name PSBuild -Value ($PSVersionTable.PSVersion)
$Result | Add-Member -MemberType NoteProperty -Name PSCLRVersion -Value ($PSVersionTable.PSVersion)
$Result | Add-Member -MemberType NoteProperty -Name OS -Value (Get-WmiObject -Class win32_operatingsystem).caption
$Result
}


$r2 = Invoke-Command -ComputerName 38.255.240.239,testsrv2,testsrv3,kms,dc2 -ScriptBlock $sb -ThrottleLimit 500
$r2 | where {$_.pschildname -eq 'full'} | ogv
$r2 | ogv 

#$r3 = $r | where pschildname -eq "full"
#$r3 | ogv
