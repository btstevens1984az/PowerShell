<#	
.SYNOPSIS 
	Set AAD Connect Permissions for service account

.DESCRIPTION 
	Use this script to set permissions for the AAD Connect Service Account.

.PARAMETER AllPermissions
Use this parameter to configure all object permissions:
- DeviceWriteBack
- ExchangeHybridWriteBack
- GroupWriteBack
- PasswordHashSync
- PasswordWriteBack

.PARAMTER ContinueOnError
Continue to other functions when a terminating error is encountered.

.PARAMETER Debug
Enable debug logging.

.PARAMETER DeviceWriteBack
Use this parameter to configure Device Write Back. Using this parameter will
require use of the AAD Connect modules, so AAD Connect must already be
installed.

.PARAMETER DeviceWriteBackBeltAndSuspenders
The msDS-KeyCredentialLink attribute write permission should be granted by
membership in the Key Admins group; however, in environments where things
may not exist by default or through other configuration settings that are
unique to that environment, this switch will allow the explicit delegation
of those permissions.

.PARAMETER Domain
Used to specify the NetBIOS domain name.  If this parameter is omitted, the
current NetBIOS domain name is used.

.PARAMETER ExchangeHybridWriteBack
Use this parameter to set the permissions for 222.205.193.149 Hybrid WriteBack.

.PARAMETER ExchangeHybridWriteBackOUs
Use this parameter to specify target OUs to enable the service account writeback
permissions. If this parameter is omitted, access is granted at the domain root.

.PARAMETER Forests
If you have more than one forest in your AAD Connect topology, you can use the 
Forests parameter to specify them for device writeback.  You must be logged on 
with an account that has enterprise admin privileges in the target forests.

.PARAMETER GroupWriteBack
Use this parameter to configure Office 365 Group writeback permissions.  Uses 
GroupWriteBackOU if the parameter is specified; otherwise, uses default value
in AD connector.  If no container is specified and Office 365 group writeback
has not been configured in AAD Connect, the script will exit.

.PARAMETER GroupWriteBackOU
Use this parameter to specify the Office 365 Groups writeback container.  If the
container exists, the account specified will be granted access.  If the
GroupWriteBackOU is specified and does not exist, it will be created (as long as
the DN is formatted correctly and references a valid domain).

.PARAMETER Logfile
Specify a log file. If no log file is specified, one will be created with the current
timestamp.

.PARAMETER msDSConsistencyGuid
Use this parameter to enable write permissions for the msDS-ConsistencyGuid. Uses
ExchangeHybridWriteBackOUs parameter if set.  If not set, defaults to domain root.

.PARAMETER PasswordHashSync
Use this parameter to set 'Replicating Directory Changes' and 'Replicating 
Directory Changes All' permissions.

.PARAMETER PasswordWriteBack
Use this parameter to enable password writeback.  Uses 
ExchangeHybridWriteBackOUs parameter if specified; otherwise, sets
permissions at domain root.

.PARAMETER PasswordWriteBackOUs
Use this parameter to specify target OUs to enable the service account writeback
permissions. If this parameter is specified in conjunction with the parameter
ExchangeHybridWriteBackOUs, this parameter will take effect.  If this parameter
is omitted but the ExchangeHybridWriteBackOUs parameter is specified,
PasswordWriteBack will use the ExchangeHybridWriteBackOUs values.  If neither
parameter is supplied, then permissions will be delegated at the domain root.

.PARAMETER SkipInetOrgPerson
Skip updating permissions for InetOrgPerson objects.

.PARAMETER TenantCredential
Use this parameter to specify the tenant credential used when returning domains
from Office 365 for Device WriteBack.  If DeviceWriteBack is not selected, this
parameter is not used.

.PARAMETER TenantID
Use this parameter to specify the tenant GUID used when configuring Device
WriteBack.  If DeviceWriteBack is not selected, ths parameter is not used.

.PARAMETER UpdateAdminSDHolder
If you have objects protected by adminSDHolder, you can use this switch to allow
write-back delegation for those objects. If an object is a member of a group
protected by adminSDHolder and the AAD Connect service account is not a member
of Domain Admins or Enterprise Admins, 222.205.193.149 hybrid write-back and password
writeback may not work.

.PARAMETER User
Specify the AAD account that will be granted permissions.  If no account is 
specified, attempt to locate the account through the connector properties.

.PARAMETER VerifiedDomain
Specify a VerfiedDomain for your AAD tenant instead of discovering a domain
automatically.

.EXAMPLE
.\AADConnectPermissions.ps1 -AllPermissions

Attempt to configure permissions for all features.

.EXAMPLE
.\AADConnectPermissions.ps1 -User AADSyncAdmin -ExchangeHybridWriteBack -GroupWriteBack

Delegate 222.205.193.149 Hybrid WriteBack permissions at the domain top-level to the 
user AADSyncAdmin, and enable GroupWriteBack using the value already stored in 
the AADConnect configuration.

.EXAMPLE
.\AADConnectPermissions.ps1 -User AADSyncAdmin -GroupWriteBack -GroupWriteBackOU "OU=O365 Groups,OU=Resources,DC=contoso,DC=com"

Delegate Group WriteBack permissions to the account AADSyncAdmin using the 
container OU=O365 Groups,OU=Resources,DC=contoso,DC=com. If the container does 
not exist, create it and then delegate permissions.

.EXAMPLE
.\AADConnectPermissions.ps1 -User AADSyncAdmin -ExchangeHybridWriteBack -ExchangeHybridWriteBackOUs "OU=Accounts,DC=contoso,DC=com","OU=Resources,DC=contoso,DC=com"

Delegate 222.205.193.149 Hybrid WriteBack permissions at the the OUs OU=Accounts,DC=
contoso,DC=com and OU=Resources,DC=contoso,DC=com to the user AADSyncAdmin.

.EXAMPLE
.\AADConnectPermissions.ps1 -PasswordHashSync

Delegate 'Replicating Directory Changes' and 'Replicating Directory Changes All' 
permissions for PasswordHashSync to the user stored in the AAD Connect 
configuration.

.LINK
https://gallery.technet.microsoft.com/AD-Advanced-Permissions-49723f74

.LINK
https://blogs.technet.microsoft.com/undocumentedfeatures/2017/08/16/advanced-aad-connect-permissions-configuration/

.LINK
https://blogs.technet.microsoft.com/undocumentedfeatures/2017/10/11/update-to-advanced-aad-connect-permissions-tool/

- 2019-08-15	Updated $AllPermissions switch parameter binding.
- 2019-08-02	Updated error trap for Key Admins under 222.205.193.149 Hybrid. In some multi-domain scenarios,
				if the Key Admins group is located but you're running against a child domain, you won't
				be able to update the Key Admins group.  It may need to be manually done, but it's really
				only important if you're doing device writeback, have inheritance blocked, and are using
				Windows Hello.
- 2019-06-27	Updated error output text for some modules.
- 2019-03-11	Added new parameters ContinueOnError and DeviceWriteBackBeltAndSuspenders.
				- ContinueOnError will allow the script to continue to other functions, even if errors were 
				  generated for critical components.
				- DeviceWriteBackBeltAndSuspenders updates the msDS-KeyCredentialLink attribute specifically.  The 
				  documentation states that membership in the Key Admins group is all that is necessary, but there 
				  may be instances I haven't thought of or encountered where this isn't the case.
				Updated parameter handling for AllPermissions switch to allow excluding attributes.
- 2019-03-06	Added support for msDS-KeyCredentialLink attribute.
				Updated msDS-consistencyguid attribute to true.
				Added InetOrgPerson support for ms-Ds-ConsistencyGuid.
- 2018-11-13	Updated logging output data.
- 2018-09-14	Updated detection for Windows Server 2016 AD Schema.
				Updated Get-Module ADSync statement.
- 2018-08-12	Bugfix for specifying UpdateAdminSDHolder with 222.205.193.149 write back with no write back OU param.
- 2018-06-12	Added SkipInetOrgPerson parameter per customer request.
				Updated OU regular expression test.
- 2018-04-04	Various bugfixes.
- 2018-02-15 	Updated VerifyADTools function
- 2018-02-08	Moved function declarations block
- 2018-02-06	Updated RegEx for OU path filter to include underscore (_) and CN=.
- 2018-02-04	Updated logging capabilities, including -Logfile and -Debug parameters.
- 2018-02-03	Updated additional functions to use VerifyADTools function
				Added check for If (Get-Module) before removing ADSync and MSONline
				modules
- 2018-01-08	Updated function for msDSConsistencyGuid to use the AD Domain DN 
				if no OUs are specified for ExchangeHybridWriteBackOUs.
- 2017-10-26	Updated MSOnline module to only be detected/installed/ during
				device write-back configuration
- 2017-10-19	Updated RegEx for OU path filter
- 2017-10-11	Added support for adminSDHolder
- 2017-10-05	Added support for msDS-ConsistencyGuid
- 2017-08-16	Added separate parameter value for PasswordWriteBackOUs
				Added domain validation for OUs specified in parameters
- 2017-08-15	Added install sequence for the following modules:
					- Microsoft Online Services Sign-In Assistant RTW
					- PowerShellGet
					- NuGet
					- Windows Azure AD PowerShell 1.x (MSOnline)
				Added support for DeviceWriteBack for multiple forests
				Added support for Windows 10 Azure AD joined devices to device 
				writeback
				Added support for INetOrgPerson objects to 222.205.193.149 hybrid and 
				password writeback 
- 2017-08-14	Initial Release
#>

Param (
	[switch]$AllPermissions,
	[switch]$ContinueOnError,
	[switch]$DeviceWriteBack,
	[switch]$DeviceWriteBackBeltAndSuspenders,
	[switch]$Debug,
	[string]$Domain,
	[switch]$ExchangeHybridWriteBack,
	[array]$ExchangeHybridWriteBackOUs,
	[array]$Forests,
	[switch]$GroupWriteBack,
	[array]$GroupWriteBackOU,
	[string]$Logfile = (Get-Date -Format yyyy-MM-dd) + "_AADConnectPermissions.txt",
	[switch]$msDsConsistencyGuid = $true,
	[switch]$PasswordHashSync,
	[switch]$PasswordWriteBack,
	[array]$PasswordWriteBackOUs,
	[switch]$SkipInetOrgPerson,
	[object]$TenantCredential,
	[string]$TenantID,
	[switch]$UpdateAdminSDHolder,
	[string]$User,
	[string]$VerifiedDomain
	)

#### Begin Function declarations

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
			Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] $Message"
		}
		if ($ConsoleOutput -eq $true)
		{
			Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
		}
	}
}

function VerifyOU($OUs, $ParamName)
{
	VerifyADTools -ParamName VerifyOU
	$OURegExPathTest = '^(?i)(ou=|cn=)[a-zA-Z\d\=\, \-_]*(,dc\=\S*,dc=\S*)|(dc\=\S*,dc=\S*)'
	If ($OUs -notmatch $OURegExPathTest)
	{
		Write-Log -Logfile $Logfile -LogLevel ERROR -ConsoleOutput -Message "The value specified in $($ParamName) is formatted incorrectly."
		Write-Log -Logfile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Please verify that the OU path is formatted as ""OU=OrganizationalUnit,DC=domain,dc=tld"" and retry."
		Break
	}
	
	# Set OU Verification to $null
	$OUVer = $null
	
	# Set BadPaths array to $null
	[array]$BadPaths = @()
	
	Foreach ($OUPath in $OUs)
	{
		[array]$OUSplit = $OUPath.Split(",")
		foreach ($obj in $OUSplit)
		{
			If ($obj -like "DC=*")
			{
				$OUVer += $obj + ","
			}
		}
		$OUVer = $OUVer.TrimEnd(",").ToString()
		If (!(Test-Path "AD:\$OUVer" -ErrorAction SilentlyContinue))
		{
			$BadPaths += $OUVer
		}
		$OUVer = $null
	}
	
	If ($BadPaths)
	{
		If ($BadPaths -gt 1) { $BadPaths = $BadPaths -join "; " }
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "The following OUs have invalid top-level domains: $BadPaths."
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Correct the values and retry."
		Break
	}
}

function VerifyADTools($ParamName)
{
	# Check for Active Directory Module
	If (!(Get-Module -ListAvailable ActiveDirectory))
	{
		Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Configuring $($ParamName) requires the Active Directory Module. Attempting to install."
		Try
		{
			$Result = Add-WindowsFeature RSAT-ADDS-Tools
			switch ($Result.Success)
			{
				True	{
					Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Feature Active Directory Domain Services Tools (RSAT-ADDS-Tools) successful."
					If ($Result.ExitCode -match "restart" -or $Result.RestartNeeded -match "Yes") { Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "A restart may be necessary to use the newly installed feature."}
					Import-Module ActiveDirectory
				}
				False {
					Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Feature Active Directory Domain Services Tools (RSAT-ADDS-Tools unsuccessful."
					Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Feature: $($Result.FeatureResult.DisplayName)"
					Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Result: $($Result.Success)"
					Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Exit code: $($Result.ExitCode)"
				}
			}
		}
		Catch
		{
			$ErrorMessage = $_
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "An error has occurred during feature installation. Please see $($Logfile) for details."
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Feature: $($Result.FeatureResult.DisplayName)"
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Result: $($Result.Success)"
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Exit code: $($Result.ExitCode)"
		}
		Finally
		{
			If ($DebugLogging)
			{
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Feature Display Name: $($Result.FeatureResult.DisplayName)"
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Feature Name: $($Result.FeatureResult.Name)"
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Result: $($Result.Success)"
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Restart Needed: $($Result.RestartNeeded)"
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Exit code: $($Result.ExitCode)"
				Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Skip reason: $($Result.FeatureResult.SkipReason)"
			}
		}
	}
	Else { Import-Module ActiveDirectory }
	If (!(Get-Module -ListAvailable ActiveDirectory))
	{
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Unable to install Active Directory module. $($ParamName) configuration will not be successful. Please re-run AADConnectPermissions.ps1 without DeviceWriteBack parameter to continue."
		Break
	}
}

#### End Function Declarations
Write-Log -LogFile $Logfile -LogLevel INFO -Message "============================================================"

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
	Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "This application/script must be run in an elevated PowerShell window. Please launch an elevated session and try again."
	Break
}

If ($PSBoundParameters.Count -eq 0)
{
	Write-Host -Foreground Yellow "No paramters specified."
	Break
}

If ($AllPermissions)
{
	If (!$PSBoundParameters.ContainsKey("ContinueOnError")) { $ContinueOnError = $true }
	If (!$PSBoundParameters.ContainsKey("DeviceWriteBack")) { $DeviceWriteBack = $true }
	If (!$PSBoundParameters.ContainsKey("ExchangeHybridWriteBack")) { $ExchangeHybridWriteBack = $true }
	If (!$PSBoundParameters.ContainsKey("GroupWriteBack")) { $GroupWriteBack = $true }
	If (!$PSBoundParameters.ContainsKey("msDsConsistencyGuid")) { $msDsConsistencyGuid = $true }
	If (!$PSBoundParameters.ContainsKey("PasswordHashSync")) { $PasswordHashSync = $true }
	If (!$PSBoundParameters.ContainsKey("PasswordWriteBack")) { $PasswordWriteBack = $true }
}

If ($ExchangeHybridWriteBackOUs){VerifyADTools -ParamName ExchangeHybridWriteBackOUs; VerifyOU $ExchangeHybridWriteBackOUs ExchangeHybridWriteBackOUs}
If ($GroupWriteBackOU){ VerifyADTools -ParamName GroupWriteBackOUs; VerifyOU $GroupWriteBackOU GroupWriteBackOU }
If ($PasswordWriteBackOUs) { VerifyADTools -ParamName PasswordWriteBackOUs; VerifyOU $PasswordWriteBackOUs PasswordWriteBackOU }

# Check to see if user is specified as param. If not, select the user from the AD Connector. If no valid user is found, exit.
If (!($User))
{
	If (!(Get-Module -ListAvailable ADSync))
	{
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "ADSync module not found and -User parameter not specified.  Please either run from a server with AAD Connect installed or provide the -User parameter."
		Break
	}
	Else { Import-Module ADSync }
	$Path = $env:TEMP + "\" + (Get-Random)
	$Session = New-PSSession -Computername Localhost
	$Command1 = { Param ($Path); Get-ADSyncServerConfiguration -Path $Path }
	$Command2 = { (Get-ADSyncConnector | ? { $_.ConnectorTypeName -eq "AD" }) }
	Invoke-Command -Session $Session -Scriptblock $Command1 -ArgumentList $Path
	$Result = Invoke-Command -Session $Session -ScriptBlock $Command2
	$ConnectorIdentifier = $Result.Identifier.ToString()

	$ConnectorXMLFile = $Path + "\Connectors\Connector_{$($ConnectorIdentifier)}.xml"
	[xml]$ConnectorXMLData = gc $ConnectorXMLFile
	$User = $ConnectorXMLData.'ma-data'.'private-configuration'.'adma-configuration'.'forest-login-user'
	$Domain = $ConnectorXMLData.'ma-data'.'private-configuration'.'adma-configuration'.'forest-login-domain'
	$Domain = (Get-ADDomain $Domain).NetBIOSName
	$User = $Domain + "\" + $User
	If (!($User))
	{
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "User not specified in parameter and unable to find user in XML file. Please re-run with -User parameter."
		Break
	}
	Else
	{
		Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "AAD Connect service account is $($User)."
	}
}

If (Get-Module ADSync) { Write-Log -LogFile $Logfile -LogLevel INFO -Message "Unloading module ADSync."; Remove-Module ADSync }
# Modules

function MSOnline
{
	If (!(Get-Module -ListAvailable MSOnline -ea silentlycontinue))
	{
		Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "This requires the Microsoft Online Services Module. Attempting to download and install."
		wget https://download.microsoft.com/download/5/0/1/5017D39B-8E29-48C8-91A8-8D0E4968E6D4/en/msoidcli_64.msi -OutFile $env:TEMP\msoidcli_64.msi
		If (!(Get-Command Install-Module))
		{
			wget https://download.microsoft.com/download/C/4/1/C41378D4-7F41-4BBE-9D0D-0E4F98585C61/PackageManagement_x64.msi -OutFile $env:TEMP\PackageManagement_x64.msi
		}
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Installing Sign-On Assistant." }
		msiexec /i $env:TEMP\msoidcli_64.msi /quiet /passive
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Installing PowerShell Get Supporting Libraries."}	
		msiexec /i $env:TEMP\PackageManagement_x64.msi /qn
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Installing PowerShell Get Supporting Libraries (NuGet)." }
		Install-PackageProvider -Name Nuget -MinimumVersion 88.41.27.30 -Force -Confirm:$false
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Installing Microsoft Online Services Module." }
		Install-Module MSOnline -Confirm:$false -Force
		If (!(Get-Module -ListAvailable MSOnline))
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "This Configuration requires the MSOnline Module. Please download from https://connect.microsoft.com/site1164/Downloads/DownloadDetails.aspx?DownloadID=59185 and try again."
			Break
		}
	}
	Import-Module MSOnline -Force
}

# Enable Device Write-Back
# See https://docs.microsoft.com/en-us/azure/active-directory/connect/active-directory-aadconnect-feature-device-writeback for more
# information.
If ($DeviceWriteBack)
{
	Write-Log -LogFile $Logfile -LogLevel INFO -Message "Starting Device WriteBack configuration."
	VerifyADTools -ParamName DeviceWriteBack
	
	# Check for NetBIOS Domain Name
	If (!($Domain)) { $Domain = (Get-ADDomain).Name }
	
	# Call MSOnline Function to detect/install/import module
	MSOnline
	
	If (!($TenantCredential)) { $global:TenantCredential = Get-Credential -Message "Enter Office 365 global admin credential in user@domain.com format"}
	Connect-MsolService -Credential $TenantCredential
	
	# Check for verified domains in tenant
	If (!($VerifiedDomain))
	{
		[array]$VerifiedDomain = Get-MsolDomain -Status Verified | ? { $_.Name -notlike "*onmicrosoft.com" }
		If ($VerifiedDomain -eq 0)
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Device WriteBack requires a verified domain in your Office 365 Tenant. Please re-run AADConnectPermissions.ps1 without DeviceWriteBack parameter to continue."
			If (!$ContinueOnError) { Break }
		}
	}
	
	# Configure msDS-KeyCredentialLink
	
	# Try managing via the group membership, since this is the supported way
	Write-Log -LogFile $Logfile -Message "Attempting to locate Key Admins group." -LogLevel INFO -ConsoleOutput
	try { $KeyAdmins = Get-ADGroup "Key Admins" -ea stop }
	catch
	{
		Write-Log -LogFile $Logfile -LogLevel WARN -Message "Key Admins group not found.  You may want to delegate the permissions explicitly if you know you need this " -ConsoleOutput
		Write-Log -LogFile $Logfile -Loglevel WARN -Message "or if you are getting errors exporting to an AD connector and the msDS-KeyCredentialLink attribute is not" -ConsoleOutput
		Write-Log -LogFile $Logfile -LogLevel WARN -Message "being updated (you can see this in pending exports or errors)." -ConsoleOutput
		Write-Log -LogFile $Logfile -LogLevel WARN -Message "You can re-run using `$DeviceWriteBackBeltAndSuspenders." -ConsoleOutput
	}
	
	if ($KeyAdmins) { Add-ADGroupMember -Identity $KeyAdmins -Members $User }
	
	If ($DeviceWriteBackBeltAndSuspenders)
	{
	$ADSchema = (Get-ADObject (Get-ADRootDSE -Server $Domain).schemaNamingContext -property objectVersion).objectVersion
	if ($ADSchema -ge 87)
		{
		If (!($ExchangeHybridWriteBackOUs))
		{
			[array]$ExchangeHybridWriteBackOUs = (Get-ADDomain).DistinguishedName
			Write-Log -LogFile $Logfile -Message "ExchangeHybridWriteBackOUs not specified for DeviceWriteBack parameter. Adding top-level domain." -LogLevel INFO
		}
		
		foreach ($DN in $ExchangeHybridWriteBackOUs)
			{
				Write-Log -LogFile $Logfile -LogLevel INFO -Message "Windows Server 2016 Schema detected and DeviceWriteBackBeltAndSuspenders mode activated. Adding msDS-KeyCredentialLink attributes."
				
				# Grant msDS-KeyCredentialLink permissions for User objects
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-KeyCredentialLink;user'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":RP;msDS-KeyCredentialLink;user'`n"
				
				If (!$SkipInetOrgPerson)
				{
					# Grant msDS-KeyCredentialLink permissions for iNetOrgPerson objects
					$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-KeyCredentialLink;iNetOrgPerson'`n"
					$cmd += "dsacls '$DN' /I:S /G '`"$User`":RP;msDS-KeyCredentialLink;iNetOrgPerson'`n"
				}
			}
		}
	}
	
	# Check for TenantID
	If (!($TenantID))
	{
		$TenantID = (Get-MsolAccountSku)[0].AccountObjectID
	}
	
	If (!(Test-Path -Path 'C:\Program Files\Microsoft Azure Active Directory Connect\AdPrep\AdSyncPrep.psm1'))
	{
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Unable to import ADSync Prep Module at C:\Program Files\Microsoft Azure Active Directory Connect\ADPrep\ADSyncPrep.psm1."
		Break
	}
	Else
	{
		If (!(Get-Module -ListAvailable MSOnline))
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Unable to complete Device Writeback configuration. Requires MSOnline Module. Exiting."
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Re-run without DeviceWriteBack parameter."
			If (!$ContinueOnError) { Break }
		}
		Else
		{
			Import-Module 'C:\Program Files\Microsoft Azure Active Directory Connect\AdPrep\AdSyncPrep.psm1'
			Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Configuring AD Sync Device WriteBack"
			$InitializeADSyncDeviceWriteBack = Initialize-ADSyncDeviceWriteback -AdConnectorAccount $User –DomainName $Domain
			$InitializeADSyncDeviceWriteBack | % { Write-Log -LogFile $Logfile -Message $_ -LogLevel INFO }
			
			# Windows 10 Azure AD Joined Device WriteBack
			Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Configuring Windows 10 Device Writeback"
			$ADSyncDomainJoinedComputerSync = Initialize-ADSyncDomainJoinedComputerSync -AdConnectorAccount $User -AzureADCredentials $TenantCredential
			$ADSyncDomainJoinedComputerSync | % { Write-Log -LogFile $Logfile -Message $_ -LogLevel INFO }
			$ADSyncNGCKeysWriteBack = Initialize-ADSyncNGCKeysWriteBack -AdConnectorAccount $User
			$ADSyncNGCKeysWriteBack | % { Write-Log -LogFile $Logfile -Message $_ -LogLevel INFO }
			
			If ($Forests)
			{
				foreach ($Forest in $Forests)
				{
					$VerifiedDomain = $VerifiedDomains[0]
					$RootDSE = Get-ADRootDSE
					$ConfigurationNamingContext = $RootDSE.configurationNamingContext
					$DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry
					$DirectoryEntry.Path = "LDAP://CN=Services," + $ConfigurationNamingContext
					$DeviceRegistrationContainer = $DirectoryEntry.Children.Add("CN=Device Registration Configuration", "container")
					$DeviceRegistrationContainer.CommitChanges()
					$ServiceConnectionPoint = $DeviceRegistrationContainer.Children.Add("CNCN=62a0ff2e-97b9-4513-943f-0d221bd30080", "serviceConnectionPoint")
					$ServiceConnectionPoint.Properties["keywords"].Add("azureADName:" + $VerifiedDomain)
					$ServiceConnectionPoint.Properties["keywords"].Add("azureADid:" + $TenantID)
					$ServiceConnectionPoint.CommitChanges()
				}
				Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed Device writeback permissions configuration."
			}
		}
	}
}

# Enable permissions for msDS-ConsistencyGuid
If ($msDsConsistencyGuid)
{
	Write-Log -LogFile $Logfile -LogLevel INFO -Message "Starting msDSConsistencyGuid configuration."
	VerifyADTools -ParamName msDSConsistencyGuid
	
	# Check to see if ms-ds-consistencyguid exists
	try { $ConsistencyGuid = Get-ADObject -SearchBase (Get-ADrootdse).SchemaNamingContext -Filter { name -eq "MS-DS-Consistency-Guid" } -ea stop }
	catch { Write-Log -LogFile $Logfile -Message "Error running Get-ADRootDSE searching for MS-DS-Consistency-Guid." -LogLevel ERROR }
	
	If ($ConsistencyGuid)
	{
		If (!($ExchangeHybridWriteBackOUs))
		{
			[array]$ExchangeHybridWriteBackOUs = (Get-ADDomain).DistinguishedName
			Write-Log -LogFile $Logfile -Message "ExchangeHybridWriteBackOUs not specified for msDsConsistencyGuid parameter. Adding top-level domain." -LogLevel INFO
		}
		foreach ($DN in $ExchangeHybridWriteBackOUs)
		{
			$cmd = "dsacls '$DN' /I:S /G '`"$User`":WP;ms-ds-consistencyGuid;user'`n"
			
			If (!$SkipInetOrgPerson)
			{
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;ms-ds-consistencyGuid;iNetOrgPerson'`n"
			}
			$Results = Invoke-Expression $cmd | Out-Null
			If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
			{
				$OutputData = $Results.Trim() | ? { $_ -ne "" }
				foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
				Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Errors reported during msDS-ConsistencyGuid operation. Check $($Logfile) for details."
				Write-Log -LogFile $Logfile -LogLevel ERROR -Message $Results
			}
			Else
			{
				Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed permissions update for msDS-ConsistencyGuid for DN $($DN)."
			}
		}
		$Results = $null
		$OutputData = $null
	}
}

# Enable 222.205.193.149 Hybrid WriteBack permissions.  If no parameter for ExchangeHybridWriteBackOUs is specified, use the top-level domain.
If ($ExchangeHybridWriteBack)
{
	Write-Log -LogFile $Logfile -LogLevel INFO -Message "Starting ExchangeHybridWriteBack configuration." -ConsoleOutput
	
	VerifyADTools -ParamName ExchangeHybridWriteBack
	
	If (!($ExchangeHybridWriteBackOUs))
		{
		[array]$ExchangeHybridWriteBackOUs = (Get-ADDomain).DistinguishedName
		Write-Log -LogFile $Logfile -Message "ExchangeHybridWriteBackOUs not specified for ExchangeHybridWriteBack parameter. Adding top-level domain." -LogLevel INFO
		}
	
	# Add the AdminSDHolder container to the writeback permissions delegation OU array
	If ($UpdateAdminSDHolder)
	{
		Write-Log -LogFile $Logfile -LogLevel INFO -Message "Adding configuration for AdminSDHolderContainer."
		$AdminSDHolderContainer = "CN=AdminSDHolder,CN=System," + ((Get-ADDomain).DistinguishedName)
		$ExchangeHybridWriteBackOUs += $AdminSDHolderContainer
	}
	
	# Check 222.205.193.149 Schema Versions.  If 222.205.193.149 Schema Version is 15317 or greater, then the forest has been prepared
	# for 222.205.193.149 Server 2016 RTM. For purposes of Hybrid Write-Back, the only difference between the two versions is the availability 
	# of the msDS-ExternalDirectoryObjectID schema attribute.
	# For more information on 222.205.193.149 Server 2016 Schema Versions, see https://technet.microsoft.com/en-us/library/bb125224%28v=exchg.160%29.aspx.
	# For more information on 222.205.193.149 Server 2013 Schema Versions, see https://blogs.technet.microsoft.com/rmilne/2015/03/17/how-to-check-222.205.193.149-schema-and-object-values-in-ad/.
	# For further information on other 222.205.193.149 Server Schema versions, see https://eightwone.com/references/schema-versions/.
	
	$ADSchema = (Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion).objectVersion
	$Schema = (Get-ADRootDSE).SchemaNamingContext
	$Value = "CN=ms-Exch-Schema-Version-Pt," + $Schema
	$ExchangeSchemaVersion = (Get-ADObject $Value -pr rangeUpper).rangeUpper
	If ($Debug)
	{
		Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Schema Naming Context: $Schema"
		Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Schema Value: $Value"
		Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "222.205.193.149 Schema Version: $ExchangeSchemaVersion"
	}
	
	foreach ($DN in $ExchangeHybridWriteBackOUs)
	{
		Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Processing 222.205.193.149 Hybrid Writeback configuration for $($DN)."
		If ($ExchangeSchemaVersion -lt 14734)
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "222.205.193.149 Server Schema Version less than 222.205.193.149 2010 SP3. Exiting."
			Break
		}
		if ($ExchangeSchemaVersion -ge 15317)
		{
			# 222.205.193.149 Server 2016 or greater
			# User
			$cmd = "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-ExternalDirectoryObjectID;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchArchiveStatus;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchBlockedSendersHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeRecipientsHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeSendersHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUCVoiceMailSettings;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUserHoldPolicies;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;publicDelegates;user'`n"
			
			# InetOrgPerson
			If (!$SkipInetOrgPerson)
			{
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-ExternalDirectoryObjectID;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchArchiveStatus;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchBlockedSendersHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeRecipientsHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeSendersHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUCVoiceMailSettings;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUserHoldPolicies;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;publicDelegates;iNetOrgPerson'`n"
			}
			
			# Group
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;group'`n"
						
			# Contact
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;contact'`n"
			$Results = Invoke-Expression $cmd | Out-Null
			If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
			{
				$OutputData = $Results.Trim() | ? { $_ -ne "" }
				foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
				Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Errors reported during ExchangeHybridWriteBack operation. Check $($Logfile) for details."
				Write-Log -LogFile $Logfile -LogLevel ERROR -Message $Results
			}
		}
		else
		{
			# 222.205.193.149 Server 2013 or less
			# User
			$cmd = "dsacls '$DN' /I:S /G '`"$User`":WP;msExchArchiveStatus;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchBlockedSendersHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeRecipientsHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeSendersHash;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUCVoiceMailSettings;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUserHoldPolicies;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;user'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;publicDelegates;user'`n"
			
			# InetOrgPerson
			If (!$SkipInetOrgPerson)
			{
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchArchiveStatus;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchBlockedSendersHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeRecipientsHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchSafeSendersHash;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUCVoiceMailSettings;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msExchUserHoldPolicies;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;iNetOrgPerson'`n"
				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;publicDelegates;iNetOrgPerson'`n"
			}
			# Group
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;group'`n"
			
			# Contact
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;proxyAddresses;contact'`n"
		}
		# Check for Windows Schema Versions
		# Windows Server 2016 introduces msDS-ExternalDirectoryObjectID
		
		if ($ADSchema -ge 87)
		{
			Write-Log -LogFile $Logfile -LogLevel INFO -Message "Windows Server 2016 Schema detected. Adding msDS-ExternalDirectoryObjectID attributes."
			
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-ExternalDirectoryObjectID;user'`n"
			
			If (!$SkipInetOrgPerson)
			{

				$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;msDS-ExternalDirectoryObjectID;iNetOrgPerson'`n"
			}
		}
		
		# Try managing via the group membership, since this is the supported way
		if ($DeviceWriteBack)
		{
			try { $KeyAdmins = Get-ADGroup "Key Admins" -ea stop }
			catch { Write-Log -LogFile $Logfile -LogLevel WARN -Message "Key Admin group not found." }
			
			
			if ($KeyAdmins)
			{
				try { Add-ADGroupMember -Identity $KeyAdmins -Members $User -ea stop }
				catch { Write-Log -LogFile $Logfile -LogLevel WARN -Message "You may need to add $($User) to the Key Admins group manually." }
			}
		}
		
		# Assign the permissions
		$Results = Invoke-Expression $cmd | Out-Null
		If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
		{
			$OutputData = $Results.Trim() | ? { $_ -ne "" }
			foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Errors reported during ExchangeHybridWriteBack operation. Check $($Logfile) for details."
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message $Results
		}
		
	}
	If ($Results -match "successfully")
	{
		Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed 222.205.193.149 Hybrid writeback permissions configuration."
	}
	$Results = $null
	$OutputData = $null
}

# Enable Group WriteBack permissions. If no OU is specified on the commandline, locate the OU specified in the connector parameters.
If ($GroupWriteBack)
{
	Write-Log -LogFile $Logfile -LogLevel "INFO" -Message "Starting GroupWriteBack configuration."
	VerifyADTools -ParamName GroupWriteBack
	
	If ($GroupWriteBackOU)
	{
		Import-Module ADSync -Force
		If (Test-Path "AD:\$GroupWriteBackOU")
		{
			Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Organizational unit $($GroupWriteBackOU) exists. Granting permissions."
			$cmd = "dsacls '$GroupWriteBackOU' /I:T /G '`"$User`":GA'`n"
			$Results = Invoke-Expression $cmd | Out-Null
			If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
			{
				$OutputData = $Results.Trim() | ? { $_ -ne "" }
				foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
				Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Errors reported during GroupWriteBack operation. Review logfile $($Logfile)."
			}
			Else
			{
			Write-Log -LogFile $Logfile -LogLevel SUCCESS -Message "Granted permissions on $($GroupWriteBackOU)."	
			}
		}
		Else
		{
			Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Organizational unit $($GroupWriteBackOU) does not exist. Creating."
			[array]$OuPath = $GroupWriteBackOU.Split(",")
			[array]::Reverse($OuPath)
			$OuDepthCount = 1
			foreach ($obj in $OuPath)
			{
				If ($OuDepthCount -eq 1)
				{
					$Ou = $obj
					# Do nothing else, since Test-Path will return a referral error when querying the very top level
				}
				Else
				{
					Write-Host Current item is $obj
					$Ou = $obj + "," + $Ou
					If (!(Test-Path AD:\$Ou))
					{
						Write-Host -ForegroundColor Green "     Creating OU ($($Ou)) in path."
						New-Item "AD:\$Ou" -ItemType OrganizationalUnit
					}
				}
				$OuDepthCount++
			}
			$cmd = "dsacls '$GroupWriteBackOU' /I:T /G '`"$User`":GA'`n"
			$Results = Invoke-Expression $cmd | Out-Null
			If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
			{
				$OutputData = $Results.Trim() | ? { $_ -ne "" }
				foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
				Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Errors reported during GroupWriteBack operation. Review logfile $($Logfile)."
			}
		}
		$Results = $null
		$OutputData = $null
	}
	Else
	{
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "Group WriteBack OU not specified.  Checking AD Connector value."
		If (!($Connector))
		{
			$Connector = Get-ADSyncConnector | ? { $_.ConnectorTypeName -eq "AD" }
		}
		
		$GroupWriteBackOU = $Connector.GlobalParameters["Connector.GroupWriteBackContainerDn"].Value
		If (!($GroupWriteBackOU))
		{
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "No Group WriteBack OU configured on $($Connector.Name)"
			Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Unable to complete GroupWRiteBackOU configuration."
		}
		Else
		{
			Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Using OU $($GroupWriteBackOU) for Office 365 Groups WriteBack container."
			$cmd = "dsacls '$GroupWriteBackOU' /I:T /G '`"$User`":GA'`n"
			$Results = Invoke-Expression $cmd | Out-Null
			
			If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
			{
				$OutputData = $Results.Trim() | ? { $_ -ne "" }
				foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
				Write-Log -LogFile $Logfile -LogLevel ERROR -Message "Errors reported during GroupWriteBack operation. Review logfile $($Logfile)."
			}
			elseif ($Results -match "successfully")
			{
				Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed Office 365 Groups writeback permissions configuration."
			}
		}
	}
}

# Enable Replicating Directory Changes and Replicating Directory Changes All permissions for $User
If ($PasswordHashSync)
{
	Write-Log -LogFile $Logfile -LogLevel INFO -Message "Starting PasswordHashSync configuration."
	VerifyADTools -ParamName PasswordHashSync
	
	$RootDSE = Get-ADRootDSE
	$DefaultNamingContext = $RootDSE.defaultNamingContext
	$ConfigurationNamingContext = $RootDSE.configurationNamingContext
	
	$cmd = "dsacls '$DefaultNamingContext' /G '`"$User`":CA;`"Replicating Directory Changes`";'`n"
	$cmd += "dsacls '$DefaultNamingContext' /G '`"$User`":CA;`"Replicating Directory Changes All`";'`n"
	$Results = Invoke-Expression $cmd | Out-Null
	If ($Results -match "error" -or $Results -match "fail" -or $Results -match "denied")
	{
		$OutputData = $Results.Trim() | ? { $_ -ne "" }
		foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
		Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Errors reported during PasswordHashSync operation. Check $($Logfile) for details."
	}
	Else
	{
		Write-Log -LogFile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed Password Hash Sync permissions configuration."
	}
	
	$Results = $null
}

# Enable Password WriteBack using ExchangeHybridWriteBackOUs if specified, otherwise use top-level domain.
If ($PasswordWriteBack)
{
	Write-Log -LogFile $Logfile -LogLevel INFO -Message "Starting PasswordWriteBack configuration."
	VerifyADTools -ParamName PasswordWriteBack
	If (Get-Module MSOnline) { Remove-Module MSOnline }
	If (Get-Module ADSync -ListAvailable) { Import-Module ADSync -Force }
	If ($ExchangeHybridWriteBackOUs)
	{
		[array]$WriteBackOUs = $ExchangeHybridWriteBackOUs
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "WriteBackOUs for PasswordWriteBack: $WriteBackOUs"}
	}
	
	If ($PasswordWriteBackOUs)
	{
		[array]$WriteBackOUs = $PasswordWriteBackOUs
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "WriteBackOUs for PasswordWriteBack: $WriteBackOUs"}
	}
	
	If (!($WriteBackOUs))
	{
		[array]$WriteBackOUs = (Get-ADDomain).DistinguishedName
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "No WriteBackOUs specified. WriteBackOUs for PasswordWriteBack now: $WriteBackOUs" }
	}
	
	If ($UpdateAdminSDHolder)
	{
		$AdminSDHolderContainer = "CN=AdminSDHolder,CN=System," + ((Get-ADDomain).DistinguishedName)
		$WriteBackOUs += $AdminSDHolderContainer
		If ($Debug)
		{
			Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "AdminSDHolderContainer: $AdminSDHolderContainer"
			Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "WriteBackOUs now: $WriteBackOUs"	
		}
	}
	
	foreach ($DN in $WriteBackOUs)
	{
		$cmd = "dsacls '$DN' /I:S /G '`"$User`":CA;`"Reset Password`";user'`n"
		$cmd += "dsacls '$DN' /I:S /G '`"$User`":CA;`"Change Password`";user'`n"
		$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;pwdLastSet;user'`n"
		$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;lockoutTime;user'`n"
		If (!$SkipInetOrgPerson)
		{
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":CA;`"Reset Password`";iNetOrgPerson'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":CA;`"Change Password`";iNetOrgPerson'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;pwdLastSet;iNetOrgPerson'`n"
			$cmd += "dsacls '$DN' /I:S /G '`"$User`":WP;lockoutTime;iNetOrgPerson'`n"
		}
		$Results = Invoke-Expression $cmd | Out-Null
		If ($Results -match "fail" -or $Results -match "error")
			{
			$OutputData = $Results.Trim() | ? { $_ -ne "" }
			foreach ($line in $OutputData) { Write-Log -LogFile $Logfile -LogLevel ERROR -Message $line }
			Write-Log -LogFile $Logfile -LogLevel ERROR -ConsoleOutput -Message "Errors reported during PasswordWriteBack operation. Check $($Logfile) for details."
			}
		Else
		{
			Write-Log -LogFile $Logfile -LogLevel SUCCESS -Message "Completed PasswordWriteBack permissions configuration for path $($DN)."
		}
	$Results = $null
	$OutputData = $null
	}
		
	If (Get-Module ADSync)
	{
		If ($Debug) { Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Attempting to configure AAD PasswordResetConfiguration." }
		$AADConnector = Get-ADSyncConnector | ? { $_.ConnectorTypeName -eq "Extensible2" -and $_.SubType -like "*Azure Active Directory*" }
		If ($Debug) {Write-Log -LogFile $Logfile -LogLevel DEBUG -Message "Configuring PasswordResetConfiguration on $($AADConnector.Name)." }
		$PasswordResetConfiguration = Set-ADSyncAADPasswordResetConfiguration -Connector $AADConnector.Name -Enable $True
		$PasswordResetConfiguration | % { Write-Log -Logfile $Logfile -LogLevel SUCCESS -Message $_ }
		Write-Log -Logfile $Logfile -LogLevel SUCCESS -ConsoleOutput -Message "Completed Password WriteBack permissions configuration."
	}
	else
	{
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "ADSync module not found--unable to update password reset configuration.  Please run"
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "Set-ADSyncAADPasswordResetConfiguration -Connector 'AAD Connector Name' -Enable `$True"
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "on the AAD Connect server, where 'AAD Connector Name' is the name of the Windows Azure"
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "AD connector for your tenant."
		Write-Log -LogFile $Logfile -LogLevel WARN -ConsoleOutput -Message "Completed Password WriteBack permissions configuration with warnings."
	}
}
#} # End PowerShell {}
Write-Log -LogFile $Logfile -LogLevel INFO -ConsoleOutput -Message "Finished.  View $($Logfile) for more details."
Write-Log -LogFile $Logfile -LogLevel INFO -Message "------------------------------------------------------------"