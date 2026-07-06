# Purpose: versionALL — General-purpose PowerShell utilities.
# Get software executable file version - April 2010 Kerry Kreitinger
# script to get list of computers form AD, ping to see if online
# if copmputer is online get version of outlook.exe
# output file to c:\logs  make sure c:\logs dir exists before running

Param(
       $Logs = "c:\logs", 
       $List,
       $computers,
       [switch]$AD, 
       [switch]$Localhost,
       [switch]$clear,
       [switch]$Help
     )
Function Get-QADComputers
{
 $ds = New-Object DirectoryServices.DirectorySearcher
 $ds.Filter = "ObjectCategory=Computer"
 $ds.FindAll() | 
     ForEach-Object { $_.Properties['dnshostname']}
} #end Get-QAdComputers

Function Test-ComputerConnection
{
 ForEach($Computer in $Computers)
 {
  $Result = Get-WmiObject -Class win32_pingstatus -Filter "address='$computer'"
  If($Result.Statuscode -eq 1)
   {
     if($computer.length -ge 0) 
        { 
         $OUTLOOKVer = ( Get-command "C:\program files\microsoft office\office12\OUTLOOK.exe" ).FileVersionInfo.ProductVersion
             Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
                $Computer = ( Get-WmiObject Win32_ComputerSystem ).name
                    Out-File -filepath �C:\LOGS\OutlookVersion2.txt� -append
        }
   } #end if
   else { "Skipping $computer .. not accessible" }
 } #end Foreach
} #end Test-ComputerConnection


