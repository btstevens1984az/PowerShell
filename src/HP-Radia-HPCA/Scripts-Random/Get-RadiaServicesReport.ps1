# Purpose: Get-RadiaServicesReport — HP Radia client automation and satellite servers.
Function Get-RadiaServicesReport{

############################################################################# 
#       Reviewer: Brandon Stevens       
#       Date: 01/17/2017 
#       Description: Radia Services Monitor 
############################################################################# 

############################Define Server & Services Variable ############### 

<#
******************* Monitor Service With PowerShell HTML Email Report *********************
#>


####******************* Modify Your stuff ****************** ######
$today=(Get-Date -format dd-MM-yyyy) # In Date Month Year fomat
$reportpath="\\186.189.182.154\share"
$ReportTitle="service Status $today"
$computers='43.37.221.116','95.33.115.5','83.121.94.202','138.57.82.1','91.237.1.244','161.170.74.154','52.95.109.93','222.189.216.69','129.234.15.198','167.226.103.71','218.17.155.199','95.207.23.1','78.5.248.223','120.16.48.123','58.179.182.33','250.171.29.116','17.126.52.225','83.58.67.63','18.182.210.178','52.51.182.113','147.253.123.154','7.101.149.86','202.32.8.222','69.22.90.253','82.131.237.99','240.78.121.218','114.148.18.125','119.223.48.126','134.127.11.250','214.193.3.93','248.85.59.40','157.254.160.104','254.154.30.117','142.187.97.113','195.47.238.174','SAC3-FSS-001','173.96.84.218','142.232.49.251','148.226.19.225','10.217.34.201','107.171.117.60','237.97.63.121','133.69.151.116','122.249.122.63','194.166.199.252','104.2.42.171','194.86.225.58','155.47.37.242','207.64.52.71','192.128.187.99','3.64.65.166'
$services='RCA','RCA-Apache','RCA-Cache','RCA-DB','RCA-DCS','RCA-DS','RCA-MCAST','RCA-MDM','RCA-MMS','RCA-MS','RCA-OSM','RCA-PM','RCA-PS','RCA-PXE','RCA-TFTP','RCA-Wildfly'
<#

$Scomputers can also be if you have list of computers in csv or text
Such as get-content c:\computers.txt or import-csv c:\computers.csv
or Get-ADComputer -Filter {OperatingSystem -Like “*server*”} |select -exp name 

#>



####******************* set email parameters with Relay ****************** ######

$smtpserver="smtp.example.com"

####******************* WITHOUT SMTP Relay ****************** ######

<#
$emailSmtpServer = "mail.contoso.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "admin@contoso.com"
$emailSmtpPass = "password"
 
$emailFrom = "alerts@contoso.com"
$emailTo = "alerts@contoso.com"
$emailcc="manager@contoso.com"

#>
####******************* HTML STYLES ****************** ######

$Style = @"
<style>
BODY{font-family:Calibri;font-size:12pt;}
TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;color:black;background-color:#0BC68D;text-align:center;}
TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;text-align:center;}
</style>
"@



#######*********** ATTEMP TO Start the services when found not runnig,if they are very important to be running.
#This can be excluded ****************#########

#foreach($computer in $computers) { 
#Foreach($service in $services) {
#Get-Service $Service -ComputerName $computer  | where {$_.Status -eq 'Stopped'}  | foreach { $_.start()  }
#}}


#-----------Wait for sometime To set things up--------------#

Start-Sleep -Seconds 60

$array = @()            
foreach($computer in $computers) { 
Foreach($service in $services) {         
 $svc = Get-Service $service -ComputerName $computer -ea "0"            
 $obj = New-Object psobject -Property @{  
  ComputerName = $computer          
  DisplayName=$svc.displayname   
  Name = $svc.name            
  Status = $svc.status
    }  
     $array += $obj                 
}   
}                   
$array | Select Computername,displayname,name,status | ConvertTo-Html -property 'ComputerName','Displayname','Name','Status' -head $Style -body "<h1> $ReportTitle </h1>" | foreach {if($_ -like "*<td>Running</td>*"){$_ -replace "<tr>", "<tr bgcolor=#089437>"} elseif($_ -like "*<td>Stopped</td>*" -or "*<td>Stopping</td>*" -or "*<td>Pending</td>*" -or "*<td>Starting</td>*"){$_ -replace "<tr>", "<tr bgcolor=#C60B1C>"}  else{$_}} |out-file $reportpath


$body = [System.IO.File]::ReadAllText('$reportpath')
Send-MailMessage -To $to -From $from -Subject "Daily Service Report" -Body $body -BodyAsHtml -SmtpServer $smtpserver

<## WITHOUT SMTP

 $emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
$emailMessage.cc.add($emailcc)
$emailMessage.Subject = "Service Monitor Status" 
$emailMessage.IsBodyHtml = $true
$emailMessage.Body = Get-Content $reportpath
 $SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $False #True in most cases check
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
$SMTPClient.Send( $emailMessage ) 
######>
}