# Purpose: Get-ServerPatchReport — Windows Update and patch management.
<#===========================================================================================================================
Script Name: GetServerUpdates.ps1
Description: Reports on the last date a patch was installed on servers.
      Inputs: List of server names fed from text file, one server name per line.
     Outputs: Report showing Server name, date and time patched, and how many days ago the server was patched.
       Notes: 
     Example: .\GetServerUpdates.ps1
=============================================================================================================================
Edit these with your preferences in the section following this one:
   $DateStamp      = the format of dates shown in the report.
   $FileDateStamp  = Appends yyyyMMdd to the Report File.
   $ServerList     = File with the list of servernames for which to provide patch statistics; one per line.
   $ReportFileName = The outputted HTML filename and location
   $ReportTitle    = Name of the report that is shown in the generated HTML file and in email subject.
   $EmailTo        = Who should receive the report via email
   $EmailCc        = Who should receive the report via email Cc:
   $EmailFrom      = Sender email address
   $EmailSubject   = Subject for the email
   $SMTPServer     = SMTP server name
   $BGColorTbl     = Background color for tables.
   $BGColorGood    = Background color for "Good" results. #4CBB17 is green.
   $BGColorWarn    = Background color for "Warning" results. #FFFC33 is yellow.
   $BGColorCrit    = Background color for "Critical" results. #155.49.20.214 is red.
   $Warning        = # of days since last update to indicate Warning (Yellow) in report. Must be less than $Critical amount.
   $Critical       = # of days since last update to indicate Critical (RED) in report. Must be more than $Warning amount.    
=============================================================================================================================#>
$DateStamp = (Get-Date -Format D)
$FileDateStamp = Get-Date -Format yyyyMMdd
$ServerList = Get-Content "C:\PatchReport\Server.txt"
$ScriptPath = Get-Location
$ReportFileName = "$ScriptPath\ServerPatchReport-$FileDateStamp.html"
$ReportTitle = "Server Patch Report"
$EmailCc = ""
$EmailSubject = "Server Patch Report for $DateStamp"
$SMTPServer = "smtp.example.com"
$BGColorTbl = "#EAECEE"
$BGColorGood = "#4CBB17"
$BGColorWarn = "#FFFC33"
$BGColorCrit = "#155.49.20.214"
$Warning = 30
$Critical = 90

<#==================================================
Do not edit below this section
==================================================#>
Clear


<#==================================================
Begin MAIN
==================================================#>
# Create output file and nullify display output
New-Item -ItemType file $ReportFileName -Force > $null


<#==================================================
Write the HTML Header to the report file
==================================================#>
Add-Content $ReportFileName "<html>"
Add-Content $ReportFileName "<head>"
Add-Content $ReportFileName "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
Add-Content $ReportFileName "<title>$ReportTitle</title>"
Add-Content $ReportFileName '<STYLE TYPE="text/css">'
Add-Content $ReportFileName "td {"
Add-Content $ReportFileName "font-family: Cambria;"
Add-Content $ReportFileName "font-size: 11px;"
Add-Content $ReportFileName "border-top: 1px solid #999999;"
Add-Content $ReportFileName "border-right: 1px solid #999999;"
Add-Content $ReportFileName "border-bottom: 1px solid #999999;"
Add-Content $ReportFileName "border-left: 1px solid #999999;"
Add-Content $ReportFileName "padding-top: 0px;"
Add-Content $ReportFileName "padding-right: 0px;"
Add-Content $ReportFileName "padding-bottom: 0px;"
Add-Content $ReportFileName "padding-left: 0px;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "body {"
Add-Content $ReportFileName "margin-left: 5px;"
Add-Content $ReportFileName "margin-top: 5px;"
Add-Content $ReportFileName "margin-right: 5px;"
Add-Content $ReportFileName "margin-bottom: 10px;"
Add-Content $ReportFileName "table {"
Add-Content $ReportFileName "border: thin solid #000000;"
Add-Content $ReportFileName "}"
Add-Content $ReportFileName "</style>"
Add-Content $ReportFileName "</head>"
Add-Content $ReportFileName "<body>"
Add-Content $ReportFileName "<table width='75%' align=`"center`">"
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td colspan='3' height='25' align='center'>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='4'><strong>$ReportTitle<br></strong></font>"
Add-Content $ReportFileName "<font face='Cambria' color='#003399' size='2'>$DateStamp</font><br><br>"

# Add color descriptions
Add-content $ReportFileName "<table width='75%' align=`"center`">"  
Add-Content $ReportFileName "<tr>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorGood align='center'><strong>Patched < $Warning Days</strong></td>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorWarn align='center'><strong>Patched $Warning - $Critical Days</strong></td>"  
Add-Content $ReportFileName "<td width='30%' bgcolor=$BGColorCrit align='center'><strong>Patched > $Critical Days</strong></td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "</table>"

# Add Column Headers
Add-Content $ReportFileName "</td>"
Add-Content $ReportFileName "</tr>"
Add-Content $ReportFileName "<tr bgcolor=$BGColorTbl>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Server Name</strong></td>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Last Patch Date & Time</strong></td>"
Add-Content $ReportFileName "<td width='20%' align='center'><strong>Days Since Last Patch</strong></td>"
Add-Content $ReportFileName "</tr>"


<#==================================================
Function to write the HTML footer
==================================================#>
Function writeHtmlFooter
{
       param($FileName)
       Add-Content $FileName "</table>"
       Add-content $FileName "<table width='75%' align=`"center`">"  
       Add-Content $FileName "<tr bgcolor=$BGColorTbl>"  
       Add-Content $FileName "<td width='75%' align='center'><strong>Total Servers: $ServerCount</strong></td>"
       Add-Content $FileName "</tr>"
       Add-Content $FileName "</table>"
       Add-Content $FileName "</body>"
       Add-Content $FileName "</html>"
}

<#==================================================
Function to write server update information to the
HTML report file
==================================================#>
Function writeUpdateData 
{
       param($FileName,$Server,$InstalledOn)
       Add-Content $FileName "<tr>"
       Add-Content $FileName "<td align='center'>$Server</td>"
       Add-Content $FileName "<td align='center'>$InstalledOn</td>"

# Color BG depending on $Warning and $Critical days set in script
    If ($InstalledOn -eq "Error collecting data") 
    { 
        $DaySpanDays = "Error"
    }
    Else
    {
        $System = (Get-Date -Format "MM/dd/yyyy hh:mm:ss")
        $DaySpan = New-TimeSpan -Start $InstalledOn -End $System
        $DaySpanDays = $DaySpan.Days
    }
       If ($InstalledOn -eq "Error collecting data" -or $DaySpan.Days -gt $Critical)
       {
       # Red for Critical or Error retrieving data
              Add-Content $FileName "<td bgcolor=$BGColorCrit align='center'>$DaySpanDays</td>"
              Add-Content $FileName "</tr>"
       }
       ElseIf ($DaySpan.Days -le $Warning)
       {
           # Green for Good
              Add-Content $FileName "<td bgcolor=$BGColorGood align=center>$DaySpanDays</td>"
              Add-Content $FileName "</tr>"
       }
       Else
       {
           # Yellow for Warning
              Add-Content $FileName "<td bgcolor=$BGColorWarn align=center>$DaySpanDays</td>"
              Add-Content $FileName "</tr>"
       }

       Add-Content $FileName "</tr>"
}


<#==================================================
Query servers for their update history
Try registry first, if error Get-Hotfix
==================================================#>
Write-Host "Querying servers for installed updates..." -foreground "Yellow"
$ServerCount = 0
ForEach ($Server in $ServerList)
{
    Try
    {
        Write-host "Checking $Server..."
       $ServerCount++
        $key = "SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install"
        $keytype = [Microsoft.Win32.RegistryHive]::LocalMachine 
        $RemoteBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($keytype,$Server)
        $regKey = $RemoteBase.OpenSubKey($key)
        $KeyValue = ""
        $KeyValue = $regkey.GetValue("LastSuccessTime")
        $InstalledOn = ""
        $InstalledOn = Get-Date $KeyValue -Format 'MM/dd/yyyy hh:mm:ss'
    }

    Catch 
    {
        $ServerLastUpdate = (Get-HotFix -ComputerName $Server | Sort-Object -Descending -Property InstalledOn -ErrorAction SilentlyContinue | Select-Object -First 1)
              $InstalledOn = $ServerLastUpdate.InstalledOn
    }

   If ($InstalledOn -eq "")
   {
       $InstalledOn = "Error collecting data"
   }

    writeUpdateData $ReportFileName $Server $InstalledOn
}

Write-Host "Finishing report..." -ForegroundColor "Yellow"
writeHtmlFooter $ReportFileName


<#==================================================
Send email
==================================================#>
Write-Host "Sending email..."
$BodyReport = Get-Content "$ReportFileName" -Raw
$StopEmailLoop=$false
[int]$RetryCount=0
Do 
{
    Try 
    {
           Send-MailMessage -To $EmailTo `
              -Subject      $EmailSubject `
              -From         $EmailFrom `
              -SmtpServer   $SMTPServer `
              -BodyAsHtml   -Body $BodyReport `
              -ErrorAction Stop;
              $StopEmailLoop = $true
    }
       Catch 
    {
        If ($RetryCount -gt 5)
        {
                  Write-Host "Cannot send email. The script will exit."
                     $StopEmailLoop = $true
        }
              Else 
        {
                  Write-Host "Cannot send email. Will try again in 15 seconds..."
                     Start-Sleep -Seconds 15
                     $RetryCount = $RetryCount+1
        }
    }
}
While ($StopEmailLoop -eq $false) 

