# Purpose: Start-GPUpdateRemotely — Routine computer maintenance and cleanup.
#Incase Psremoting isn't an option
#Limited to only targeting an OU, for reuse consider 
#only taking a computer name and accepting pipeline input
Function Start-GPUpdateRemotely
{
  [cmdletbinding()]
  param([parameter(mandatory=$true)]$SrchBase)
  $computers = Get-ADComputer –filter * -Searchbase $SrchBase 
  $computers | 
  ForEach-Object{
    $ComputerName = $_.name
    Write-verbose "Running GPupdate on $ComputerName" 
    #Invoke-Command -ComputerName $_.name {gpupdate /force }
    $result = Invoke-WmiMethod -ComputerName $ComputerName -Path win32_process -Name create -ArgumentList "gpupdate /target:Computer /force /wait:0" 
    If ($result.returnValue -eq 0)
    {Write-verbose "Running GPupdate on $ComputerName successfully" }
    Else
    {Write-verbose "Running GPupdate on $ComputerName failed"}
    $result =$null
    $ComputerName = $null
  }
} 

Start-GPUpdateRemote -SrchBase "OU=Domain Controllers,DC=kaylos,DC=lab" -Verbose