# Purpose: CreateArchiveLogs — General-purpose PowerShell utilities.
$Computernames = "dc2","Dc4"
$today = Get-Date -f MM.dd.yyyy-hh.mm.ss
$logFiles = Get-WmiObject Win32_NTEventLogFile -ComputerName $Computernames
Foreach ($logfile in $logFiles)
{
    #backup
    $archivefolder = $logfile.name | split-path -Parent
    $ArchiceFileName = "Archive-$($logfile.__server)-$($logfile.LogFileName)$today.evtx"
    $result = $logfile.BackupEventLog("$archivefolder\$ArchiceFileName")
    
}
