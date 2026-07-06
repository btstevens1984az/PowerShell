# Purpose: DR — General-purpose PowerShell utilities.
# get disk space info and email it to Admins or NS1s
$freeSpaceFileName = "FreeSpace.htm"
$serverlist = "servers.txt"
$warning = 90
$critical = 75
New-Item -ItemType file $freeSpaceFileName -Force
# Getting the freespace info using WMI
#Get-WmiObject win32_logicaldisk  | format-table DeviceID, VolumeName,status,Size,FreeSpace | Out-File FreeSpace.txt
# Function to write the HTML Header to the file
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('yyyy/MM/dd')
Add-Content $fileName "&lt;html&gt;"
Add-Content $fileName "&lt;head&gt;"
Add-Content $fileName "&lt;meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'&gt;"
Add-Content $fileName '&lt;title&gt;EVOLUTION.COM DiskSpace Report&lt;/title&gt;'
add-content $fileName '&lt;STYLE&gt;'
add-content $fileName  "&lt;!--"
add-content $fileName  "td {"
add-content $fileName  "font-family: Tahoma;"
add-content $fileName  "font-size: 11px;"
add-content $fileName  "border-top: 1px solid #999999;"
add-content $fileName  "border-right: 1px solid #999999;"
add-content $fileName  "border-bottom: 1px solid #999999;"
add-content $fileName  "border-left: 1px solid #999999;"
add-content $fileName  "padding-top: 0px;"
add-content $fileName  "padding-right: 0px;"
add-content $fileName  "padding-bottom: 0px;"
add-content $fileName  "padding-left: 0px;"
add-content $fileName  "}"
add-content $fileName  "body {"
add-content $fileName  "margin-left: 5px;"
add-content $fileName  "margin-top: 5px;"
add-content $fileName  "margin-right: 0px;"
add-content $fileName  "margin-bottom: 10px;"
add-content $fileName  ""
add-content $fileName  "table {"
add-content $fileName  "border: thin solid #000000;"
add-content $fileName  "}"
add-content $fileName  "--&gt;"
add-content $fileName  "&lt;/style&gt;"
Add-Content $fileName "&lt;/head&gt;"
Add-Content $fileName "&lt;body&gt;"
add-content $fileName  "&lt;table width='100%'&gt;"
add-content $fileName  "&lt;tr bgcolor='#CCCCCC'&gt;"
add-content $fileName  "&lt;td colspan='7' height='25' align='center'&gt;"
add-content $fileName  "&lt;font face='tahoma' color='#003399' size='4'&gt;&lt;strong&gt;ORGANIZATION DiskSpace Report - $date&lt;/strong&gt;&lt;/font&gt;"
add-content $fileName  "&lt;/td&gt;"
add-content $fileName  "&lt;/tr&gt;"
add-content $fileName  "&lt;/table&gt;" } # Function to write the HTML Header to the file Function writeTableHeader
{
param($fileName) Add-Content $fileName "&lt;tr bgcolor=#CCCCCC&gt;"
Add-Content $fileName "&lt;td width='10%' align='center'&gt;Drive&lt;/td&gt;"
Add-Content $fileName "&lt;td width='50%' align='center'&gt;Drive Label&lt;/td&gt;"
Add-Content $fileName "&lt;td width='10%' align='center'&gt;Total Capacity(GB)&lt;/td&gt;"
Add-Content $fileName "&lt;td width='10%' align='center'&gt;Used Capacity(GB)&lt;/td&gt;"
Add-Content $fileName "&lt;td width='10%' align='center'&gt;Free Space(GB)&lt;/td&gt;"
Add-Content $fileName "&lt;td width='10%' align='center'&gt;Freespace %&lt;/td&gt;"
Add-Content $fileName "&lt;/tr&gt;"
}

Function writeHtmlFooter
{
param($fileName)

Add-Content $fileName "&lt;/body&gt;"
Add-Content $fileName "&lt;/html&gt;"
}

Function writeDiskInfo
{
param($fileName,$devId,$volName,$frSpace,$totSpace)
$totSpace=[math]::Round(($totSpace/1073741824),2)
$frSpace=[Math]::Round(($frSpace/1073741824),2)
$usedSpace = $totSpace - $frspace
$usedSpace=[Math]::Round($usedSpace,2)
$freePercent = ($frspace/$totSpace)*100
$freePercent = [Math]::Round($freePercent,2)
        if ($freePercent -gt $warning)
        {
                Add-Content $fileName "&lt;tr&gt;"

                Add-Content $fileName "&lt;td&gt;$devid&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$volName&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$totSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$usedSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$frSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$freePercent&lt;/td&gt;"
                Add-Content $fileName "&lt;/tr&gt;"
        }
        elseif ($freePercent -le $critical)
        {
                Add-Content $fileName "&lt;tr&gt;"
                Add-Content $fileName "&lt;td&gt;$devid&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$volName&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$totSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$usedSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$frSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td bgcolor='#155.49.20.214' align=center&gt;$freePercent&lt;/td&gt;"
                #&lt;td bgcolor='#155.49.20.214' align=center&gt;
                Add-Content $fileName "&lt;/tr&gt;"
        }
        else
        {
                Add-Content $fileName "&lt;tr&gt;"
                Add-Content $fileName "&lt;td&gt;$devid&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$volName&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$totSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$usedSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td&gt;$frSpace&lt;/td&gt;"
                Add-Content $fileName "&lt;td bgcolor='#FBB917' align=center&gt;$freePercent&lt;/td&gt;"
                # #FBB917
                Add-Content $fileName "&lt;/tr&gt;"
        }
}
Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp= New-Object net.Mail.smtpclient($smtphost)
$msg = New-Object net.Mail.MailMessage($From,$To,$subject,$body)
$msg.isBodyhtml = $true
$smtp.send($msg)
}

writeHtmlHeader $freeSpaceFileName

foreach ($server in Get-Content $serverlist)
{
    Add-Content $freeSpaceFileName "&lt;table width='100%'&gt;&lt;tbody&gt;"
    Add-Content $freeSpaceFileName "&lt;tr bgcolor='#CCCCCC'&gt;"
    Add-Content $freeSpaceFileName "&lt;td width='100%' align='center' colSpan=6&gt;&lt;font face='tahoma' color='#003399' size='2'&gt;&lt;strong&gt; $server &lt;/strong&gt;&lt;/font&gt;&lt;/td&gt;"
    Add-Content $freeSpaceFileName "&lt;/tr&gt;"

    writeTableHeader $freeSpaceFileName

        $dp = Get-WmiObject win32_logicaldisk
            foreach ($item in $dp)
            {
                Write-Host  $item.DeviceID  $item.VolumeName $item.FreeSpace $item.Size
                writeDiskInfo $freeSpaceFileName $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size

            }
}
writeHtmlFooter $freeSpaceFileName
$date = ( get-date ).ToString('yyyy/MM/dd')
sendEmail kkreitin@example.com kkreitin@example.com "Disk Space Report - $Date" localhost $freeSpaceFileName
