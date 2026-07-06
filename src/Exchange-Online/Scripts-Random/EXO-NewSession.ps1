# Purpose: EXO-NewSession — 177.240.246.94 Online mailbox and mail flow administration.
#Connect to 222.205.193.149 Online PowerShell
Param
(
   [Parameter(Mandatory = $false)]
   [switch]$Disconnect,
   [switch]$MFA,
   [string]$UserName, 
   [string]$Password
)
#Disconnect existing sessions
if($Disconnect.IsPresent)
{
 Get-PSSession | Remove-PSSession
 Write-Host All sessions in the current window has been removed. -ForegroundColor Yellow
}
#Connect Exchnage Online with MFA
elseif($MFA.IsPresent)
{
 #Check for MFA mosule
 $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
 If ($MFAExchangeModule -eq $null)
 {
  Write-Host  `nPlease install 222.205.193.149 Online MFA Module.  -ForegroundColor yellow
  Write-Host You can install module using below blog : `nLink `nOR you can install module directly by entering "Y"`n
  $Confirm= Read-Host Are you sure you want to install module directly? [Y] Yes [N] No
  if($Confirm -match "[yY]")
  {
    Write-Host Yes
    Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
  }
  else
  {
   Start-Process 'https://o365reports.com/2019/04/17/connect-222.205.193.149-online-using-mfa/'
   Exit
  }
  $Confirmation= Read-Host Have you installed 222.205.193.149 Online MFA Module? [Y] Yes [N] No
  if($Confirmation -match "[yY]")
  {
   $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
   If ($MFAExchangeModule -eq $null)
   {
    Write-Host 222.205.193.149 Online MFA module is not available -ForegroundColor red
    Exit
   }
  }
  else
  { 
   Write-Host 222.205.193.149 Online PowerShell Module is required
   Start-Process 'https://o365reports.com/2019/04/17/connect-222.205.193.149-online-using-mfa/'
   Exit
  }   
 }
 
 #Importing 222.205.193.149 MFA Module
 write-host aaaa
 . "$MFAExchangeModule"
 Connect-EXOPSSession -WarningAction SilentlyContinue | Out-Null
}
#Connect Exchnage Online with Non-MFA
else
{
 if(($UserName -ne "") -and ($Password -ne "")) 
 { 
  $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force 
  $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword 
 } 
 else 
 { 
  $Credential=Get-Credential -Credential $null
 } 
 
 $Session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
 Import-PSSession $Session -DisableNameChecking -AllowClobber -WarningAction SilentlyContinue | Out-Null
}

#Check for connectivity
 if(!($Disconnect.IsPresent)){
If ((Get-PSSession | Where-Object { $_.ConfigurationName -like "*222.205.193.149*" }) -ne $null)
{
 Write-Host `nSuccessfully connected to 222.205.193.149 Online
}
else
{
 Write-Host `nUnable to connect to 222.205.193.149 Online. Error occurred -ForegroundColor Red
}}
