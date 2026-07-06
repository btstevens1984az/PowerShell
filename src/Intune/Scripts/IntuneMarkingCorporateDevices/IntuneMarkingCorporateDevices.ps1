# Purpose: IntuneMarkingCorporateDevices — Microsoft Intune endpoint management.
<#	
    ===========================================================================
    Created with: 	ISE
    Created on:   	9/12/2019 1:46 PM
    Filename:     	IntuneMarkingCorporateDevices.ps1
    ===========================================================================
    .DESCRIPTION
    Update Device Ownership in Intune for users that select Corporate Device to Corporate
#>

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

####################Load variables and log##########
$log = Write-Log -Name "o365IntuneDeviceMarking-Log" -folder "logs" -Ext "log"

$smtpserver = "smtpserver"
$erroremail = "Reportsand@labtest.com"
$from = "DoNotReply@labtest.com"
$count = "1000"

Write-Log -Message "Start .......Script" -path $log
Write-Log -Message "Loading Credentials" -path $log
##################Userid & password#################
$userId = "serviceaccount@labtest.com"
$encrypted1 = Get-Content -Path .\password1.txt
$pwd = ConvertTo-SecureString -String $encrypted1
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $userId, $pwd
################connect to modules###################
try
{
  Connect-MSGraph -PSCredential $Credential
  Write-Log -Message "Intune Module Loaded" -path $log
}
catch
{
  $exception = $_.Exception
  Write-Log -Message "Error loading Intune Module" -path $log -Severity Error 
  Write-Log -Message $exception -path $log -Severity error
  Send-MailMessage -SmtpServer $smtpserver -To $erroremail -From $from -Subject "Error has occured loading Intune Module - AMTIntuneDeviceWipe" -Body $($_.Exception.Message)
  Exit
}

################Start Work#############################
Write-Log -Message "Fetch all devices with devicecategory as Corporate Device" -path $log
try{
  $fetchallcorporate=Get-IntuneManagedDevice -Filter {deviceCategoryDisplayName eq 'Corporate Device' and managedDeviceOwnerType eq 'personal'}
  Write-Log -Message "Fetched all devices with devicecategory as Corporate Device" -path $log
}
catch{
  $exception = $_.Exception
  Write-Log -Message "Error fetching device category" -path $log -Severity Error 
  Write-Log -Message $exception -path $log -Severity error
  Send-MailMessage -SmtpServer $smtpserver -To $erroremail -From $from -Subject "Error fetching device category - IntuneCorporateDeviceMarking" -Body $($_.Exception.Message)
  Exit

}

 Write-Log -Message "Start Changing the ownership to company" -path $log
 if(($fetchallcorporate.count -gt 0) -and ($fetchallcorporate.count -lt $count)){
   try{
     $fetchallcorporate | foreach-object{
       $managedeviceid = $_.managedDeviceId
       $devicename = $_.deviceName
       $userPrincipalName=$_.userPrincipalName
       Update-IntuneManagedDevice -managedDeviceId $managedeviceid -managedDeviceOwnerType "company"
       Write-log -Message "Update $devicename - $managedeviceid - $userPrincipalName ownership to Company" -path $log
     }

   }
   catch{
     $exception = $_.Exception
     Write-Log -Message "Error updating $devicename - $managedeviceid - $userPrincipalName ownership to Company" -path $log -Severity Error 
     Write-Log -Message $exception -path $log -Severity error
     Send-MailMessage -SmtpServer $smtpserver -To $erroremail -From $from -Subject "Error updating ownership to company - IntuneCorporateDeviceMarking" -Body $($_.Exception.Message)
   }
 }
 elseif($fetchallcorporate.count -gt $count){
 $fetchcount = $fetchallcorporate.count
   Write-Log -Message "Count is greater than $count -  $fetchcount" -path $log -Severity error
   Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error Count is greater than $count -  $fetchcount - IntuneCorporateDeviceMarking" -Body "Error Count is greater than $count -  $fetchcount - IntuneCorporateDeviceMarking"
   exit;

 }
 Write-Log -Message "Finish Changing the ownership to company" -path $log
 ##############################################################################
$path1 = $logpath

$limit = (Get-Date).AddDays(-60) #for report recycling
Get-ChildItem -Path $path1 |
Where-Object -FilterScript {$_.CreationTime -lt $limit} |
Remove-Item -Recurse -Force

Write-Log -Message "Script Finished" -path $log
Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Transcript Log - IntuneCorporateDeviceMarking" -Body "Transcript Log - IntuneCorporateDeviceMarking" -Attachments $log
################################################################################