# Purpose: IntuneMDMWelcomeMail — Microsoft Intune endpoint management.
<#	
    ===========================================================================
    Created with: 	ISE
    Created on:   	11/4/2019 1:46 PM
    Filename:     	IntuneMDMWelcomeMail.ps1
    ===========================================================================
    .DESCRIPTION
    This scritp will send Welcome Email to Intune MDM users
#>
param (
  [string]$smtpserver = $(Read-Host "Enter SMTP Server"),
  [string]$from = $(Read-Host "Enter From Address"),
  [string]$erroremail = $(Read-Host "Enter Address for Alerts and Errors"),
  [string]$userId = $(Read-Host "Enter Service Account to be used"),
  $countofchanges = $(Read-Host "Enter Count of changes to process before it breaks")
)
function Write-Log
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [array]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [string]$Ext,
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [string]$folder,
    
    [Parameter(ParameterSetName = 'Create',Position = 0)][switch]$Create,
    
    [Parameter(Mandatory = $true,ParameterSetName = 'Message')]
    [String]$Message,
    [Parameter(Mandatory = $true,ParameterSetName = 'Message')]
    [String]$path,
    [Parameter(Mandatory = $false,ParameterSetName = 'Message')]
    [ValidateSet('Information','Warning','Error')]
    [string]$Severity = 'Information',
    
    [Parameter(ParameterSetName = 'Message',Position = 0)][Switch]$MSG
  )
  switch ($PsCmdlet.ParameterSetName) {
    "Create"
    {
      $log = @()
      $date1 = Get-Date -Format d
      $date1 = $date1.ToString().Replace("/", "-")
      $time = Get-Date -Format t
	
      $time = $time.ToString().Replace(":", "-")
      $time = $time.ToString().Replace(" ", "")
	
      foreach ($n in $Name)
      {$log += (Get-Location).Path + "\" + $folder + "\" + $n + "_" + $date1 + "_" + $time + "_.$Ext"}
      return $log
    }
    "Message"
    {
      $date = Get-Date
      $concatmessage = "|$date" + "|   |" + $Message +"|  |" + "$Severity|"
      switch($Severity){
        "Information"{Write-Host -Object $concatmessage -ForegroundColor Green}
        "Warning"{Write-Host -Object $concatmessage -ForegroundColor Yellow}
        "Error"{Write-Host -Object $concatmessage -ForegroundColor Red}
      }
      
      Add-Content -Path $path -Value $concatmessage
    }
  }
} #Function Write-Log
function Start-ProgressBar
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    $Title,
    [Parameter(Mandatory = $true)]
    [int]$Timer
  )
	
  For ($i = 1; $i -le $Timer; $i++)
  {
    Start-Sleep -Seconds 1;
    Write-Progress -Activity $Title -Status "$i" -PercentComplete ($i /100 * 100)
  }
}

#################Check if logs folder is created####
$logpath  = (Get-Location).path + "\logs" 
$testlogpath = Test-Path -Path $logpath
if($testlogpath -eq $false)
{
  Start-ProgressBar -Title "Creating logs folder" -Timer 10
  New-Item -Path (Get-Location).path -Name Logs -Type directory
}
$Reportpath  = (Get-Location).path + "\Report" 
$testlogpath = Test-Path -Path $Reportpath
if($testlogpath -eq $false)
{
  Start-ProgressBar -Title "Creating Report folder" -Timer 10
  New-Item -Path (Get-Location).path -Name Report -Type directory
}

$temppath  = (Get-Location).path + "\temp" 
$testlogpath = Test-Path -Path $temppath
if($testlogpath -eq $false)
{
  Start-ProgressBar -Title "Creating Temp folder" -Timer 10
  New-Item -Path (Get-Location).path -Name temp -Type directory
}
####################Load variables and log####################
$log = Write-Log -Name "MDMWelcome-Log" -folder "logs" -Ext "log"
$Report1 = Write-Log -Name "MDMWelcome-Report" -folder "Report" -Ext "csv"
$tempcsv = $temppath + "\tempcsv.csv"
Write-Log -Message "Start.......Script" -path $log

$Resource = "deviceManagement/managedDevices"
$graphApiVersion = "v1.0"
$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
$getdate = Get-Date -Hour 00 -Minute 00 -Second 00

##################Userid & password#################
$encrypted1 = Get-Content -Path ".\password1.txt"
$pwd = ConvertTo-SecureString -String $encrypted1
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userId, $pwd

###################Connect to Intune##########################
try
{
  Write-Log -Message "Connect to Intune" -path $log
  Connect-MSGraph -PSCredential $Credential
}
catch
{
  $exception = $_.Exception
  Write-Log -Message "Error loading Modules" -path $log -Severity Error 
  Write-Log -Message "$exception" -path $log -Severity Error 
  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error loading Module MDMWelcomeEmail" -Body $($_.Exception.Message)
  Start-ProgressBar -Title "exiting script Error loading Modules" -Timer 10
  exit;
}


try
{
  Write-Log -Message "Invoke Graph request" -path $log
  $Response = Invoke-MSGraphRequest -HttpMethod GET -Url $uri  -Verbose
  $getmdm = $Response.value | where{($_.managementAgent -eq "mdm") -and ($_.enrolledDateTime -ge $getdate) -and ($_.deviceEnrollmentType -eq "userEnrollment")}

  $NextLink = $Response."@odata.nextLink"
  $count = 0
  while ($NextLink -ne $null)
  {
    $count = $count + 1
    $count
    $Response = (Invoke-MSGraphRequest -HttpMethod GET -Url $NextLink  -Verbose)
    Write-Log -Message "Processing Page .....$count" -path $log
    $NextLink = $Response."@odata.nextLink"
    $getmdm += $Response.value | where{($_.managementAgent -eq "mdm") -and ($_.enrolledDateTime -ge $getdate) -and ($_.deviceEnrollmentType -eq "userEnrollment")}
  }

  $allMDM = $getmdm | select UserPrinCipalName -Unique #fetched all enrolled devices
}
catch
{
  $exception = $_.Exception
  Write-Log -Message "Error Calling Graph API" -path $log -Severity Error 
  Write-Log -Message "$exception" -path $log -Severity Error 
  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error Calling Graph API MMDMWelcomeEmail" -Body $($_.Exception.Message)
  Start-ProgressBar -Title "Error Calling Graph API" -Timer 10
  exit;
}

################Start comparing with previous data######################
try
{
$tespath = Test-Path -Path $tempcsv
if($tespath -eq $false)
{
Write-Log -Message "Export.....to tempcsv as it does not exist" -path $log
$allMDM | Export-Csv $tempcsv -NoTypeInformation
}
  $tempimport = Import-Csv $tempcsv
  $change = Compare-Object -ReferenceObject $allMDM -DifferenceObject $tempimport -Property UserPrinCipalName

  $Removal = $change |
  Where-Object -FilterScript {$_.SideIndicator -eq "=>"} |
  Select-Object -ExpandProperty UserPrinCipalName

  $Addition = $change |
  Where-Object -FilterScript {$_.SideIndicator -eq "<="} |
  Select-Object -ExpandProperty UserPrinCipalName

  $removalcount = $Removal.count
  $additioncount = $Addition.count
  
  Write-Log -Message "Remove Count $removalcount - ignore" -path $log
  Write-Log -Message "Communication Count $additioncount" -path $log
}
catch
{
  $exception = $_.Exception
  Write-Log -Message "Error Comparing the tempcsv with MDM" -path $log -Severity Error 
  Write-Log -Message "$exception" -path $log -Severity Error 
  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error Comparing the tempcsv with MDM MDMWelcomeEmail" -Body $($_.Exception.Message)
  Start-ProgressBar -Title "Error Comparing the tempcsv with MDM" -Timer 10
  exit;
}

if(($additioncount -gt "0") -and ($additioncount -lt $countofchanges))
{
  $collection = @()
  $Addition | ForEach-Object{
    $error.clear()
    $email = $_

    $body = @"
Dear user,

Intune Welcome Email,
Intune Welcome Email.

"@

    $mcoll = "" | select UserPrincipalName, Status
    $mcoll.UserPrincipalName = $email
    Write-Log -Message "Sending welecome email.....$email" -path $log
    #Send-MailMessage -SmtpServer $smtpserver -From $from -To $email -Subject "Intune - Welcome Email" -Body $body
    if($error)
    {
      $mcoll.Status = "Error"
      Write-Log -Message "Sending welecome email.....$email - Failed" -path $log -Severity Warning
    }
    else{$mcoll.Status = "Success"}
  
    $collection += $mcoll
  }
  
  Write-Log -Message "Export.....Report" -path $log
  $collection | Export-Csv $Report1 -NoTypeInformation
  Write-Log -Message "Sending.......Report" -path $log
  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "MDMWelcomeEmail - Report" -Body "MDMWelcomeEmail - Report" -Attachments $Report1
}
elseif($additioncount -ge $countofchanges)
{
  $exception = $_.Exception
  Write-Log -Message "Error Count $additioncount is greter then $countofchanges" -path $log -Severity Error 
  Write-Log -Message "$exception" -path $log -Severity Error 
  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error Count $additioncount is greter then $countofchanges MDMWelcomeEmail" -Body $($_.Exception.Message)
  Start-ProgressBar -Title "Error Count $additioncount is greter then $countofchanges" -Timer 10
  exit;
}

Write-Log -Message "Export.....to tempcsv" -path $log
$allMDM | Export-Csv $tempcsv -NoTypeInformation
##############################Recycle Logs##########################
Write-Log -Message "Recycle Logs" -path $log -Severity Information
$path1 = (Get-Location).path + "\report"
$path2 = (Get-Location).path + "\logs" 

$limit = (Get-Date).AddDays(-60) #for report recycling
Get-ChildItem -Path $path1 |
Where-Object {$_.CreationTime -lt $limit} |
Remove-Item -recurse -Force

Get-ChildItem -Path $path2 |
Where-Object {$_.CreationTime -lt $limit} |
Remove-Item -recurse -Force

Write-Log -Message "Script Finished" -path $log -Severity Information
Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Transcript Log - MDMWelcomeEmail" -Body "Transcript Log - MDMWelcomeEmail" -Attachments $log
###############################################################################