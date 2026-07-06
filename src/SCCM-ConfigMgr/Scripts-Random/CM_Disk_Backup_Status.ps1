# Purpose: CM Disk Backup Status — Configuration Manager collections and deployments.
$ErrorActionPreference = "Continue"; 

###Get Date###
$cdate = get-date
$dt = $cdate
$cdate = $cdate.adddays($days) | get-date -format "ddd MMM dd"
$dt = $dt.adddays($days) | get-date -format "yyyy-MM-dd"
$filter = ("*" + $cdate + "*")
$ares = @()
$orfname = $dt + "-" + $orfname

 
# Set your warning and critical thresholds 
$percentWarning = 40; 
$percentCritical = 20; 

$reportName = @()
#$reportPath = "<output path location>";#
$reportPath = "c:\temp\CM12_Dsk_Bkp\Bkp_Dsk_$dt\";
$folder = New-Item -Path $reportPath -ItemType Directory -Force
$reportName = $dt + "-" + "CM_Disk_Backup.html"; 
#$reportName = "Disk&BackupRpt.html"; 
#$diskReport = $reportPath + $reportName 
$diskReport = $reportPath + $reportName

$redColor = "#155.49.20.214" 
$orangeColor = "#FBB917" 
$whiteColor = "#FFFFFF" 

$computers = "Servername","Servername"

$days = -1
$fpath = "\<installation folder>$\Program Files\Microsoft Configuration Manager\Logs\" # Change to path of SCCM log files
$flog =  "smsbkup.log" # Name of log to check
$orfname = "DiskSpaceRpt.html" # Name of Report HTML document
$loutdir = $reportPath # Change to location to store smsbkup.log fragments
$routdir = $loutdir # Change to location to store reports



If (Test-Path $diskReport) { Remove-Item $diskReport } 
 
$titleDate = (Get-Date ).ToString('yyyy/MM/dd') + " - " + (Get-Date).DayOfWeek
$header = " 
                <html> 
                <head> 
                <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'> 
                <title>DiskSpace Report</title> 
                <STYLE TYPE='text/css'> 
                <!-- 
                td { 
                font-family: Tahoma; 
                font-size: 11px; 
                border-top: 1px solid #999999; 
                border-right: 1px solid #999999; 
                border-bottom: 1px solid #999999; 
                border-left: 1px solid #999999; 
                padding-top: 0px; 
                padding-right: 0px; 
                padding-bottom: 0px; 
                padding-left: 0px; 
                } 
                body { 
                margin-left: 5px; 
                margin-top: 5px; 
                margin-right: 0px; 
                margin-bottom: 10px; 
                table { 
                border: thin solid #000000; 
                } 
                --> 
                </style> 
                </head> 
                <body> 
                <table width='100%'> 
                <tr bgcolor='#CCCCCC'> 
                <td colspan='7' height='25' align='center'> 
                <font face='tahoma' color='#003399' size='4'><strong>SG-SDS Managed Primary Servers DiskSpace Report - $titledate</strong></font> 
                </td> 
                </tr> 
                </table> 
                " 
Add-Content $diskReport $header 

$tableHeader = " 
                <table width='100%'><tbody> 
                <tr bgcolor=#CCCCCC> 
                <td width='10%' align='center'>Server</td> 
                <td width='5%' align='center'>Drive</td> 
                <td width='15%' align='center'>Drive Label</td> 
                <td width='10%' align='center'>Total Capacity(GB)</td> 
                <td width='10%' align='center'>Used Capacity(GB)</td> 
                <td width='10%' align='center'>Free Space(GB)</td> 
                <td width='5%' align='center'>Freespace %</td> 
                </tr> 
                " 
Add-Content $diskReport $tableHeader 
  
foreach($computer in $computers) 

{  
                $disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter "DriveType = 3" 
                $computer = $computer.toupper() 
                foreach($disk in $disks) 
                {         
                                $deviceID = $disk.DeviceID; 
                                $volName = $disk.VolumeName; 
                                [float]$size = [Math]::Round($disk.Size, 2); 
                                [float]$freespace = [Math]::Round($disk.FreeSpace, 2);  
                                $percentFree = [Math]::Round(($freespace / $size) * 100, 2); 
                                $sizeGB = [Math]::Round($size / 1073741824, 2); 
                                $freeSpaceGB = [Math]::Round($freespace / 1073741824, 2); 
                                $usedSpaceGB = [Math]::Round($sizeGB - $freeSpaceGB, 2);
                                $color = $whiteColor; 
 
                                if($percentFree -lt $percentWarning)       
                                { 
                                                $color = $orangeColor  

                                                if($percentFree -lt $percentCritical) 
                                                { 
                                                                $color = $redColor 
                                                }         
                                } 
                                $dataRow = " 
                                <tr> 
                                <td width='10%'>$computer</td> 
                                <td width='5%' align='center'>$deviceID</td> 
                                <td width='15%' >$volName</td> 
                                <td width='10%' align='center'>$sizeGB</td> 
                                <td width='10%' align='center'>$usedSpaceGB</td> 
                                <td width='10%' align='center'>$freeSpaceGB</td> 
                                <td width='5%' bgcolor=`'$color`' align='center'>$percentFree</td> 
                                </tr> 
                                " 
                                Add-Content $diskReport $dataRow; 
                                #Write-Host -ForegroundColor DarkYellow "$computer $deviceID percentage free space = $percentFree"; 
                                 
                } 
} 

$tableDescription = " 
                </table><br><table width='20%'> 
                <tr bgcolor='White'> 
                <td width='10%' align='center' bgcolor='#FBB917'>Warning less than 40% free space</td> 
                <td width='10%' align='center' bgcolor='#155.49.20.214'>Critical less than 20% free space</td> 
                </tr> 
                " 
Add-Content $diskReport $tableDescription 
$header = "
<table width='100%'> 
                <tr bgcolor='#CCCCCC'> 
                <td colspan='7' height='25' align='center'> 
                <font face='tahoma' color='#003399' size='4'><strong>SG-SDS Managed Servers Backup Satus Report - $titledate</strong></font> 
                </td> 
                </tr> 
                </table>"

Add-Content $diskReport $header 

$tableHeader = " 
                <table width='100%'><tbody> 
                <tr bgcolor=#CCCCCC> 
                <td width='15%' align='center'>Server</td> 
                <td width='15%' align='center'>Status</td> 
                <td width='15%' align='center'>Date</td> 
                </tr> 
                " 
Add-Content $diskReport $tableHeader 

foreach ($computer in $computers) 
{
    $ores = "" | select Server, Status, Date
    
        $ores.Server = $computer
        $ores.Date = $dt
    $connstr = "\\" + $computer + $fpath + $flog
    try {
        #$content = Get-ChildItem $connstr -Recurse -ErrorAction "Stop" | where {$_ -like $filter}
        
        $ofname = $loutdir + $dt + "-" + $computer + "-smsbkup.log"
        $content = Get-Content -Path $connstr
        # | where {$_ -like "*Backup task completed successfully*"}

        $content | out-file $ofname

        $row = $content | where {$_ -like "*Backup task completed successfully*"}

        if ($row) 
        { 
            $ores.Status = "Successful"
        } else { 
            $ores.Status = "Failed"
        }
      
    } catch {
    $error
        $ores.Status = "Unable to retrieve log"
        continue
    } finally {
        $ares += $ores
    }

    $status = $ores.Status
    $dataRow = " 
                                <tr> 
                                <td width='15%'>$computer</td> 
                                <td width='15%' align='center'>$dt</td> 
                                <td width='15%' >$status</td> 
                                </tr> 
                                " 
                                Add-Content $diskReport $dataRow; 

}
Add-Content $diskReport "</table>"

Add-Content $diskReport "</body></html>"

### RESULTS OUTPUT ###

<#$a = "<style>"
#$a = $a + "BODY{background-color:aquamarine;}"
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 2px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 2px;padding: 0px;border-style: solid;border-color: black;background-color:Beige}"
$a = $a + "</style>"
$b = "<H2>SCCM Server Backup Status " + $dt + "</H2>"
$ares | Select-Object Server, Status, Date | 
ConvertTo-HTML -head $a -body $b | 
#ConvertTo-HTML -body $b | 
#Out-File ( $routdir + $orfname) -Append
Out-File $diskReport -Append#>


