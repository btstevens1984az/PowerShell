# Purpose: BackUpAndClearEventLogs — System monitoring and alerting.
Param(
       $LogsArchive = "c:\logarchive", 
       $List,
       $computers,
       [switch]$AD, 
       [switch]$Localhost,
       [switch]$clear,
       [switch]$Help
     )
Function Get-ADComputers
{
 $ds = New-Object DirectoryServices.DirectorySearcher
 $ds.Filter = "ObjectCategory=Computer"
 $ds.FindAll() | 
     ForEach-Object { $_.Properties['dnshostname']}
} #end Get-AdComputers

Function Test-ComputerConnection
{
 ForEach($Computer in $Computers)
 {
  $Result = Get-WmiObject -Class win32_pingstatus -Filter "address='$computer'"
  If($Result.Statuscode -eq 0)
   {
     if($computer.length -ge 1) 
        { 
         Write-Host "+ Processing $Computer"
         Get-BackUpFolder 
        }
   } #end if
   else { "Skipping $computer .. not accessible" }
 } #end Foreach
} #end Test-ComputerConnection



Function Get-BackUpFolder
{
 $Folder = "{1}-Logs-{0:MMddyymm}" -f [DateTime]::now,$computer
  New-Item "$LogsArchive\$folder" -type Directory -force  | out-Null
  If(!(Test-Path "\\$computer\c$\LogFolder\$folder"))
    {
      New-Item "\\$computer\c$\LogFolder\$folder" -type Directory -force | out-Null
    } #end if
 Backup-EventLogs($Folder)
} #end Get-BackUpFolder

Function Backup-EventLogs
{
 $Eventlogs = Get-WmiObject -Class Win32_NTEventLogFile -ComputerName $computer
 Foreach($log in $EventLogs)
        {
            $path = "\\{0}\c$\LogFolder\$folder\{1}.evt" -f $Computer,$log.LogFileName
            $ErrBackup = ($log.BackupEventLog($path)).ReturnValue
            if($clear)
               {
                if($ErrBackup -eq 0)
                  {
                   $errClear = ($log.ClearEventLog()).ReturnValue
                  } #end if
                else
                  { 
                    "Unable to clear event log because backup failed" 
                    "Backup Error was " + $ErrBackup
                  } #end else
               } #end if clear
            Copy-EventLogsToArchive -path $path -Folder $Folder
        } #end foreach log
} #end Backup-EventLogs

Function Copy-EventLogsToArchive($path, $folder)
{
 Copy-Item -path $path -dest "$LogsArchive\$folder" -force
} # end Copy-EventLogsToArchive

Function Get-HelpText
{
 $helpText= `
@"
 DESCRIPTION:
 NAME: BackUpAndClearEventLogs.ps1
 This script will backup, archive, and clear the event logs on 
 both local and remote computers. It will accept a computer name,
 query AD, or read a text file for the list of computers. 

 PARAMETERS: 
 -LogsArchive local or remote collection of all computers event logs
 -List path to a list of computer names to process
 -Computers one or more computer names typed in
 -AD switch that causes script to query AD for all computer accounts
 -Localhost switch that runs script against local computer only
 -Clear switch that causes script to empty the event log if the back succeeds
 -Help displays this help topic

 SYNTAX:
 BackUpAndClearEventLogs.ps1 -LocalHost 

 Backs up all event logs on local computer. Archives them to C:\logarchive.

 BackUpAndClearEventLogs.ps1 -AD -Clear

 Searches AD for all computers. Connects to these computers, and backs up all event 
 logs. Archives all event logs to C:\logarchive. It then clears all event logs 
 if the backup operation was successful. 

 BackUpAndClearEventLogs.ps1 -List C:\fso\ListOfComputers.txt

 Reads the ListOfComputers.txt file to obtain a list of computer. Connects to these 
 computers, and backs up all event logs. Archives all event logs to C:\logarchive. 

 BackUpAndClearEventLogs.ps1 -Computers "Berlin,Vista" -LogsArchive "\\157.217.58.110\C$\fso\Logs"

 Connects to a remote computers named Berlin and Vista, and backs up    all event 
 logs. Archives all event logs from all computers to the path c:\fso\Logs directory on 
   a remote computer named Berlin. 

BackUpAndClearEventLogs.ps1 -help

Prints the help topic for the script
"@ #end helpText
  $helpText
}

# *** Entry Point To Script ***

If($AD) { $Computers = Get-ADComputers; Test-ComputerConnection; exit }
If($List) { $Computers = Get-Content -path $list; Test-ComputerConnection; exit }
If($LocalHost) { $computers = $env:computerName; Test-ComputerConnection; exit }
If($Computers) 
  { 
   if($Computers.Contains(",")) {$Computers = $Computers.Split(",")} 
   Test-ComputerConnection; exit 
  }
If($help) { Get-HelpText; exit }
"Missing parameters" ; Get-HelpText
