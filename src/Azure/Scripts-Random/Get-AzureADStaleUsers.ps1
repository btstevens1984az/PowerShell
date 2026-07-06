<#
.SYNOPSIS
Check for stale Azure, Guest, or B2B accounts

.PARAMETER Credential
Specify a credential to use when connecting to Azure AD.

.PARAMETER InstallRequiredModules
This script requires the Get-AzureADPolicy cmdlet, which is only available in
the AzureADPreview module.  If the module is not installed or not available,
you can use either the MaxInactiveTime parameter or use the default of 90 days

.PARAMETER Logfile
Log events for script execution.

.PARAMETER MaxInactiveTime
Use this parameter to specify the MaxInactiveTime value for your tenant. This is
token refresh value.  The default value for Azure Active Directory is 90 days.
You cannot view, add, or modify an Azure AD policy without the AzureADPreview
module.  If you do not want to install the module, you can use the default for 
this parameter or specify your own value.

.PARAMETER Output
Specify the output file listing stale acccounts.

.PARAMETER StaleAgeInDays
Use this parameter to specify how many days past the refresh token an account
can be inactive before marking it stale.

.EXAMPLE
.\Get-AzureADStaleUsers.ps1 -MaxInactiveTime 30 -StaleAgeInDays 180
Return all objects that have not generated a refresh token in 210 days.

2018-06-22	Release.

.LINK
https://blogs.technet.microsoft.com/undocumentedfeatures/2018/06/22/how-to-find-staleish-azure-b2b-guest-accounts/

.LINK
https://gallery.technet.microsoft.com/Report-on-Azure-AD-Stale-8e64c1c5/edit?newSession=True
#>
param (
	[System.Management.Automation.PSCredential]$Credential,
	[switch]$InstallRequiredModules,
	[string]$Logfile = (Get-Date -Format yyyy-MM-dd) + "_GetAzureADStaleGuestAccountsLog.txt",
	[int]$MaxInactiveTime,
	[string]$Output = (Get-Date -Format yyyy-MM-dd) + "_GetAzureADStaleGuestAccounts.txt",
	[int]$StaleAgeInDays = 180
)

# Logging function
function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput, [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel)
{
	$Message = $Message + $Input
	If (!$LogLevel) { $LogLevel = "INFO" }
	switch ($LogLevel)
	{
		SUCCESS { $Color = "Green" }
		INFO { $Color = "White" }
		WARN { $Color = "Yellow" }
		ERROR { $Color = "Red" }
		DEBUG { $Color = "Gray" }
	}
	if ($Message -ne $null -and $Message.Length -gt 0)
	{
		$TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
		if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
		{
			Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] $Message"
		}
		if ($ConsoleOutput -eq $true)
		{
			Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
		}
	}
}

# Requires Azure AD Preview Module
If (!(Get-Module -ListAvailable "AzureADPreview" -ea SilentlyContinue))
{
	Write-Log -LogFile $Logfile -LogLevel WARN -Message "Azure AD Preview Module not detected." -ConsoleOutput
	If ($InstallRequiredModules)
	{
		Write-Log -LogFile $Logfile -LogLevel INFO -Message "Attempting to install module." -ConsoleOutput
		# Check if Elevated
		$wid = [system.security.principal.windowsidentity]::GetCurrent()
		$prp = New-Object System.Security.Principal.WindowsPrincipal($wid)
		$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
		if ($prp.IsInRole($adm))
		{
			Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Elevated PowerShell session detected. Continuing."
		}
		else
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "InstallRequiredModules must be run in an elevated PowerShell window. Please launch an elevated session and try again."
			$ErrorCount++
			Break
		}
		
		Install-Module AzureADPreview -Force
		
		Try
		{
			Import-Module AzureADPreview -Force
		}
		Catch
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Unable to import module. Please verify that the module is installed and try again." -ConsoleOutput
			Write-Log -LogFile $Logfile -LogLevel WARN -Message "Continuing using defaults for Azure AD Policy settings ('90 days token refresh')."
		}
	}
	Else
	{
		Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Unable to detect module and InstallRequiredModules switch not supplied. Please verify that the module has installed and try again." -ConsoleOutput
		Write-Log -LogFile $Logfile -LogLevel WARN -Message "Continuing using defaults for Azure AD Policy settings ('90 days token refresh')."
	}
}
Else
{
	Import-Module AzureADPreview -Force	
}

# VerifyMaxInactiveTime
If ($MaxInactiveTime -lt 1) { Write-Log -LogFile $Logfile -Message "The value specified for MaxInactiveTime must be greater than 0." -Console -LogLevel ERROR; Break }

# Check for existing Azure AD Connection
Try
{
	$TestAzureAD = Get-AzureADTenantDetail
}
Catch [Microsoft.Open.122.18.231.49.CommonLibrary.AadNeedAuthenticationException]
{
	Write-Host "You're not connected.";
	Connect-AzureAD -credential $cred
}


If (!($MaxInactiveTime))
{
	$AzureADPolicy = Get-AzureADPolicy | ? { $_.Type -eq "TokenLifetimePolicy" }
	If ($AzureADPolicy)
	{
		$PolicyData = $AzureADPolicy.Definition | ConvertFrom-Json
		# Retrieve value for MaxInactiveTime
		[int]$MaxInactiveTime = $PolicyData.TokenLifetimePolicy.MaxInactiveTime.Split(":")[0].Split(".")[0]
		
		# Test MaxInactiveTime; if not exist, set to AAD default of 90 days, 
		# per https://docs.microsoft.com/en-us/azure/active-directory/active-directory-configurable-token-lifetimes
		If (!$MaxInactiveTime)
		{
			$MaxInactiveTime = "90"
		}
	}
}

# Get guest users
$Filter = "UserType eq 'Guest'"
$Guests = Get-AzureADUser -All $true -Filter $Filter

# Calculate users whose last STS refresh token value is 'n' past expiration
# For example, if token expiration is 90 days, and StaleAgeInDays is 180, then
# return objects that have a token age 270 days ago
$Today = (Get-Date)
$Global:StaleUsers = $Guests | ForEach-Object {
	$TimeStamp = $_.RefreshTokensValidFromDateTime
	$TimeStampString = $TimeStamp.ToString()
	[int]$LogonAge = [math]::Round(($Today - $TimeStamp).TotalDays)
	[int]$StaleAge = $MaxInactiveTime + $StaleAgeInDays
	$User = $($_.Mail)
	If ($LogonAge -ge $StaleAge)
	{
		[pscustomobject]@{
			User		= $($User)
			ObjectID 	= $_.ObjectID
			IsStale  	= "True"
			LastLogon	= $TimeStamp
			DaysSinceLastLogon = $LogonAge
			UserIsStaleAfterThisManyDays = $StaleAge
		}
	}
}
$StaleUsers | Export-Csv -NoTypeInformation -Path $Output