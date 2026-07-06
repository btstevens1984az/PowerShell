# Purpose: BackupEventLogs — System monitoring and alerting.
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
