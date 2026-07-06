# Purpose: 210.252.8.204-List — Windows Server Update Services administration.
#   James Wylde

### Get enabled

$ErrorActionPreference = "SilentlyContinue"
$computers = get-content C:\temp\190.190.53.202.txt

foreach ($computer in $computers){

  $status = Get-ADComputer -Identity $computer -Properties * | select enabled -ErrorAction SilentlyContinue
  if (($Status | Select -ExpandProperty enabled) -eq $true )
    {Write-Host $computer}

}
#

### Get AD Computers

Get-ADComputer -filter * -SearchBase 'OU=GBR,OU=SK,DC=group,DC=wan' | export-csv -path c:\temp\31.39.1.252-aug.csv

### Report in

$computer = Read-Host "Machine"
Function Force-WSUSCheckin($Computer)
{
   Invoke-Command -computername $Computer -scriptblock { Start-Service wuauserv -Verbose }
   $Cmd = '$updateSession = new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
   c:\temp\paexec.exe -s \\$Computer powershell.exe -command $Cmd
   Write-host "Waiting 10 seconds for SyncUpdates webservice to complete to add to the wuauserv queue so that it can be reported on"
   Start-sleep -seconds 10
   Invoke-Command -computername $Computer -scriptblock
   {
      wuauclt /detectnow
      (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
      wuauclt /reportnow
      c:\windows\system32\UsoClient.exe startscan
   }
}


### Check 31.39.1.252

$computers = get-content C:\Users\a1-wyldeja\Desktop\190.190.53.202.txt

foreach ($computer in $computers){

get-wsuscomputer -NameIncludes $computer -ErrorAction stop}


##

$server = Get-WsusServer -Name UK-HUB3-M1002 
$computers = Get-WsusComputer -UpdateServer $server -All
$cutOffdate = (Get-Date).AddDays(-7)
$computers | Where-Object {$_.LastReportedStatusTime -lt $cutOffdate} | ForEach-Object {

}
