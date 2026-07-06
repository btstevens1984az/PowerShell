# Purpose: DeviceRegSCPTool — Active Directory user, group, and domain administration.
cls

'=================================================='
Write-Host '          Device Registration SCP Tool         ' -ForegroundColor Green 
'=================================================='


Function Initialize-ADSyncDomainJoinedComputerSync
{
param(
    [Parameter(Mandatory=$True)] [string] $AdConnectorAccount,
    [Parameter(Mandatory=$True)] [System.Management.Automation.PSCredential] $AzureADCredentials,
    [Parameter(Mandatory=$False)] [string] [ValidateSet("AzureCloud","AzureChinaCloud","AzureGermanyCloud","USGovernment")] $AzureEnvironment,
    [Parameter(Mandatory=$False)] [string] $AzureADDomain)

$servicesContainerName = "Services"
$CNPrefix = "CN="

$drsContainerName = "Device Registration Configuration"
$containerType = "container"

$drsServicesContainerName = "Device Registration Services"
$drsServicesContainerType = "msDS-DeviceRegistrationServiceContainer"

$drsServicesObjectName = "DeviceRegistrationService"
$drsServicesObjectType = "msDS-DeviceRegistrationService"

$registeredDevicesContainer = "msDS-DeviceContainer"
$registeredDevicesLocation = "RegisteredDevices"

$deviceLocationAttribute = "msDS-DeviceLocation"

# The name for the SCP object is this GUID.
$scpObjectName = "62a0ff2e-97b9-4513-943f-0d221bd30080"
$scpType = "serviceConnectionPoint"

$deviceType = "msDS-Device"
$deviceSchemaType = "ms-DS-Device"
$userType = "user"
$keywordsProperty = "keywords"
$supportedAttributeProperties = "systemMayContain", "mayContain", "systemMustContain", "mustContain"
$keyProperty = "msDS-KeyCredentialLink"
$azureADIdKeyword = "azureADId"
$azureADNameKeyword = "azureADName"
$commaSeparator =","
$periodSeparator = "."
$colonSeparator = ":"
$atSeparator = "@"

$oneLevelSearchScope = 1


    # Get/Create DRS container and grant permissions to AdConnectorAccount
    $drsContainerDN = ConfigureDRSContainer $AdConnectorAccount

    # Configure Azure AD information in the DRS container
    ConfigureAzureADInformation $drsContainerDN $AzureADCredentials $AzureEnvironment $AzureADDomain

}

function ConfigureDRSContainer
{
param(
[Parameter(Mandatory=$True,Position=1)] [string] $adConnectorAccount)

    $rootDSEEntry = Get-ADRootDSE
    $configurationContainerDN = $rootDSEEntry.configurationNamingContext
    $servicesContainerDN = $CNPrefix + $servicesContainerName + $commaSeparator + $configurationContainerDN

    # Get/Create object with example DN:
    # CN=Device Registration Configuration,CN=Services,CN=Configuration,<forest-dn>
    $drsContainer = GetOrCreateADObject $drsContainerName $servicesContainerDN $containerType
    $drsContainerDN = $CNPrefix + $drsContainerName + $commaSeparator + $servicesContainerDN

    # Grant Read/Write access over DRS container to adConnectorAccount
    # Connector account is only expected to make updates and will not create any objects
    $userAcl = $adConnectorAccount + ":GRGW"
    GrantAcls $drsContainerDN $userAcl 'T' > $null
    return $drsContainerDN
}

function GetOrCreateADObject
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $objectName,
[Parameter(Mandatory=$True,Position=1)] [string] $parentDN,
[Parameter(Mandatory=$True,Position=2)] [string] $objectType,
[Parameter(Mandatory=$False,Position=3)] $otherAttributes)

    # Construct objectDN
    $objectDN = $CNPrefix + $objectName + $commaSeparator + $parentDN

    # Fetch the object
    $adObject = GetADObject $objectDN
    if(!$adObject) {
        # Create the object
        $adObject = CreateADObject $objectName $parentDN $objectType $otherAttributes
    }
    return $adObject
}

function GrantAcls
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $objectDN,
[Parameter(Mandatory=$True,Position=1)] [string[]] $userAcls,
[Parameter(Mandatory=$True,Position=2)] [char] $inheritFlag
)
    # Grants permissions to specified objectDN
    & dsacls.exe $objectDN /G $userAcls /I:$inheritFlag
}

function GetADObject 
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $objectDN,
[Parameter(Mandatory=$False,Position=1)] [string[]] $properties)

    try {
        if($properties) {
            $object = Get-AdObject -Identity $objectDN -Properties $properties
        } else {
            $object = Get-AdObject -Identity $objectDN 
        }
    } catch {
    }
    return $object
}

function CreateADObject 
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $objectName, 
[Parameter(Mandatory=$True,Position=1)] [string] $parentDn, 
[Parameter(Mandatory=$True,Position=2)] [string] $objectType, 
[Parameter(Mandatory=$False,Position=3)] $otherAttributes) 

    $schemaSupportsObjectType = SchemaSupportsObjectType $objectType
    
    if($schemaSupportsObjectType) {
        if($otherAttributes) {
            return New-ADObject -name $objectName -path $parentDn -type $objectType -OtherAttributes $otherAttributes -passthru
        } else {
            return New-ADObject -name $objectName -path $parentDn -type $objectType -passthru
        }
    } else {
        Write-Output "[ERROR]`t Active Directory Schema does not support $objectType"
        break
    }
}

function SchemaSupportsObjectType 
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $objectType)

    $rootDSEEntry = Get-ADRootDSE
    $schemaDN = $rootDSEEntry.schemaNamingContext

    return SearchADObject $schemaDN $oneLevelSearchScope ldapDisplayName=$objectType 
}

function SearchADObject 
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $searchBase,
[Parameter(Mandatory=$True,Position=1)] [int] $searchScope,
[Parameter(Mandatory=$True,Position=2)] [string] $ldapFilter)

    try {
        $objects = Get-AdObject -LDAPFilter $ldapFilter -SearchScope $searchScope -SearchBase $searchBase
    } catch {
    }
    return $objects
}

function GetAzureADCompanyInformation
{
param(
[Parameter(Mandatory=$True,Position=0)] [System.Management.Automation.PSCredential] $credential,
[Parameter(Mandatory=$True,Position=1)] [string] $tenantAzureEnvironment)

    Connect-MsolService -Credential $credential -AzureEnvironment $tenantAzureEnvironment
    return Get-MsolCompanyInformation
}

function ConfigureAzureADInformation
{
param(
[Parameter(Mandatory=$True,Position=0)] [string] $drsContainerDN,
[Parameter(Mandatory=$True,Position=1)] [System.Management.Automation.PSCredential] $credential,
[Parameter(Mandatory=$False,Position=2)] [string] $azureEnvironment,
[Parameter(Mandatory=$False,Position=3)] [string] $tenantDomain)

    # Get tenant Azure environment
    if ([string]::IsNullOrEmpty($azureEnvironment))
    {
       $tenantAzureEnvironment = GetTenantAzureEnvironment $credential
    }
    else
    {
        $tenantAzureEnvironment = $azureEnvironment
    }

    # Fetch information from Azure AD
    $companyInformation = GetAzureADCompanyInformation $credential $tenantAzureEnvironment
    
    $currentAzureADId = $azureADIdKeyword + $colonSeparator + $companyInformation.ObjectId
    
	if ([string]::IsNullOrEmpty($tenantDomain))
    {
		$tenantDomain = GetTenantDomain $credential $tenantAzureEnvironment
    }
	else
	{
		if ((VerifyTenantDomain $credential $tenantAzureEnvironment $tenantDomain) -eq $false)
		{
			Write-Output "[ERROR]`t The specified domain name is not a verified, federated Azure Active Directory domain. You need to provide a domain that is verified and federated."
			return;
		}
	}

    $currentAzureADName = $azureADNameKeyword + $colonSeparator + $tenantDomain

    $currentScpKeywords = $currentAzureADId,$currentAzureADName

    # Setup Keywords for the Azure AD  Information serviceConnectionPoint 
    $keywordsMap = @{keywords=$currentScpKeywords}

    # The serviceConnectionPoint object for Azure AD information is located at 
    # CN=Azure AD Information,CN=Device Registration Configuration,CN=Services,CN=Configuration,<forest-dn>
    $scpObjectDN = $CNPrefix + $scpObjectName + $commaSeparator + $drsContainerDN

    # Get the existing serviceConnectionPoint
    $scpObject = GetADObject $scpObjectDN $keywordsProperty
    if(!$scpObject) {
        # If the object is not found, create it
        $scpObject = CreateADObject $scpObjectName $drsContainerDN $scpType $keywordsMap
    } else {
        # If the object exists, ensure that the keywords match.
        $existingScpKeywords = $scpObject.keywords
        if($existingScpKeywords[1] -ne $currentAzureADId -or $existingScpKeywords[0] -ne $currentAzureADName) {
            $currentScpKeywords = $currentAzureADId,$currentAzureADName
            $keywordsMap = @{keywords=$currentScpKeywords}
            # Update keywords to current Azure AD information.
            Set-ADObject $scpObject -Replace $keywordsMap
        }
    }
}

function GetTenantDomain
{
param(
[Parameter(Mandatory=$True,Position=0)] [System.Management.Automation.PSCredential] $credential,
[Parameter(Mandatory=$True,Position=1)] [string] $tenantAzureEnvironment)
###
    Connect-MsolService -Credential $credential -AzureEnvironment $tenantAzureEnvironment
    $domains = Get-MsolDomain
    foreach($domain in $domains) 
    {
        if($domain.Authentication -eq "Federated" -and $domain.Status -eq "Verified")
        {
            return $domain.Name
        }
        
        if($domain.IsInitial -eq "true") 
        {
            $initialDomain = $domain.Name
        }
    }
    
    return $initialDomain
}

function GetTenantAzureEnvironment
{
param(
[Parameter(Mandatory=$True,Position=0)] [System.Management.Automation.PSCredential] $credential)

    # Set default Azure environment to public
    $environment = "AzureCloud"

    # Get tenant name from user's upn suffix
    $upn = $credential.UserName
    $tenant = $upn.Split('@')[1]
    if ([string]::IsNullOrEmpty($tenant))
    {
        Write-Output "[ERROR]`t AzureADCredentials doesn't contain a valid user name. You need to provide the user name in the user principal name (UPN) format (user@example.com)."
        # Break will stop all script execution if not used in a loop or switch statement
        break
    }

    # Oauth discovery endpoint
    $url = "https://login.microsoftonline.com/$tenant/.well-known/openid-configuration"

    # Get CloudInstance from Oauth discovery endpoint
    try
    {
        $response = Invoke-RestMethod -Uri $url -Method Get
    }
    catch [Exception]
    {
        Write-Output "$_.Exception.Message"
        Write-Output "[ERROR]`t OAuth2 discovery failed. Please contact system administrator for more information."
        break
    }

    # Determine AzureEnvironment from tenant_region_scope and cloud_instance_name
    if ($response.tenant_region_scope.ToLower().equals("usg"))
    {
        $environment = "USGovernment"
    }
    elseif ($response.cloud_instance_name.ToLower().equals("chinacloudapi.cn"))
    {
        $environment = "AzureChinaCloud"
    }
    elseif ($response.cloud_instance_name.ToLower().equals("microsoftonline.de"))
    {
        $environment = "AzureGermanyCloud"
    }

    return $environment
}

Function CheckDsacls{
    $dsacls = "C:\Windows\System32\dsacls.exe"
    $dsaclsmu = "C:\Windows\System32\en-US\dsacls.exe.mui" 

    if (-not (Test-Path $dsacls)) {
        Write-Host "'dsacls.exe' file does not exist. Coping it from DC..." -ForegroundColor Yellow
        $DC = (Get-ADDomainController -Discover).hostname
        $dsaclsSource = "\\" + $DC + "\C$\Windows\System32\dsacls.exe"
        if (Test-Path $dsaclsSource){
            Copy-Item $dsaclsSource -Destination "C:\Windows\System32"
            Write-Host "dsacls.exe has copied successfully from DC." -ForegroundColor Green -BackgroundColor Black
            ''
        } else {
        Write-Host "Operation aborted. Unable to copy 'dsacls.exe' file from DC." -ForegroundColor red -BackgroundColor Black
        Write-Host "Please copy the file 'dsacls.exe' from the DC from the folder '%windir%\Windows\System32\' to AADConnect server under the folder '%windir%\Windows\System32\'." -ForegroundColor red -BackgroundColor Black
        exit
        }
    }

    if (-not (Test-Path $dsaclsmu)){
        Write-Host "Checking 'dsacls.exe.mui' file does not exist. Coping it from DC..." -ForegroundColor Yellow
        $DC = (Get-ADDomainController -Discover).hostname
        $dsaclsmuSource = "\\" + $DC + "\C$\Windows\System32\en-US\dsacls.exe.mui"
        if (Test-Path $dsaclsmuSource){
            Copy-Item $dsaclsmuSource -Destination "C:\Windows\System32\en-US"
            Write-Host "dsacls.exe.mui has copied successfully from DC." -ForegroundColor Green -BackgroundColor Black
            ''
        } else {
        Write-Host "Operation aborted. Unable to copy 'dsacls.exe.mui' file from DC." -ForegroundColor red -BackgroundColor Black
        Write-Host "Please copy the file 'dsacls.exe.mui' from the DC from the folder '%windir%\Windows\System32\en-US\' to AADConnect server under the folder '%windir%\Windows\System32\en-US\'." -ForegroundColor red -BackgroundColor Black
        exit
        }
    }
}

Function CheckInternet
{
$statuscode = (Invoke-WebRequest -Uri https://adminwebservice.microsoftonline.com/ProvisioningService.svc).statuscode
if ($statuscode -ne 200){
''
Write-Host "Operation aborted. Unable to connect to Azure AD, please check your internet connection." -ForegroundColor red -BackgroundColor Black
exit
}
}

Function ConfigureSCP 
{
            ''
            Write-Host "Do you need to configure Service Connection Point (SCP)?"
            $val= Read-Host '[Y] Yes [N] No (default is "N")'
                If ($val -eq 'Y') {
                CheckPrerequisits
                        ''
                        Write-Host "Checking MSOnline Module..." -ForegroundColor Yellow
                            
                            if (Get-Module -ListAvailable -Name MSOnline) {
                                Import-Module MSOnline
                                Write-Host "MSOnline Module has imported." -ForegroundColor Green -BackgroundColor Black
                            } else {
                                Write-Host "MSOnline Module is not installed." -ForegroundColor Red -BackgroundColor Black
                                Write-Host "Installing MSOnline Module....." -ForegroundColor Yellow
                                CheckInternet
                                Install-Module MSOnline 
                                
                                if (Get-Module -ListAvailable -Name MSOnline) {                                
                                Write-Host "MSOnline Module has installed." -ForegroundColor Green -BackgroundColor Black
                                Import-Module MSOnline
                                Write-Host "MSOnline Module has imported." -ForegroundColor Green -BackgroundColor Black
                                } else {
                                ''
                                ''
                                Write-Host "Operation aborted. MsOnline was not installed." -ForegroundColor red -BackgroundColor Black
                                exit
                                }
                            }


                    ''
                    CheckInternet
                    CheckDsacls
                    Write-Host "Fetching Azure AD Global Admin account credentials..." -ForegroundColor Yellow
                    $GACred = $host.ui.PromptForCredential("Need credentials", "Please enter Azure AD Global Admin account credentials.", "", "NetBiosUserName")
                    Connect-MsolService -Credential $GACred -ErrorAction SilentlyContinue
                        if($?){
                            Write-Host "You entered a valid credentials." -ForegroundColor Green -BackgroundColor Black
                            ''
                            Write-Host "Configuring Service Connection Point (SCP)...." -ForegroundColor Yellow
                            $connName=(Get-ADSyncConnector | ? {$_.Type -eq "AD"})
                            $connectorAccount = ($connName.ConnectivityParameters | Where {$_.Name -eq 'forest-login-user'}).Value
                            Initialize-ADSyncDomainJoinedComputerSync –AdConnectorAccount $connectorAccount -AzureADCredentials $GACred;
                            Write-Host "Service Connection Point has configured successfully as following:." -ForegroundColor Green -BackgroundColor Black
                            ''
                            $Root = [ADSI]"LDAP://RootDSE"
                            $ConfigurationName = $Root.rootDomainNamingContext
                            $scp = New-Object System.DirectoryServices.DirectoryEntry;
                            $scp.Path = "LDAP://CN=62a0ff2e-97b9-4513-943f-0d221bd30080,CN=Device Registration Configuration,CN=Services,CN=Configuration," + $ConfigurationName;

                                if ($scp.Keywords -ne $null){
                                    $scp.Keywords}
                                    
                                    }else{
                                 Write-Host "Operation aborted. You entered bad username or password." -ForegroundColor red -BackgroundColor Black
                            }

                                }else{
                                    Write-Host "Operation aborted. You declined to create Service Connection Point (SCP)." -ForegroundColor red -BackgroundColor Black
                                }

}


Function CheckPrerequisits {
$ServerName=hostname

''
Write-Host "Checking AAD Connect Server..." -ForegroundColor Yellow
if (Get-Module -ListAvailable -Name ADSync) {
    
    Write-Host $ServerName "is AD Connect Server." -ForegroundColor Green -BackgroundColor Black


    ''
    Write-Host "Checking Active Directory Module..." -ForegroundColor Yellow
        if (Get-Module -ListAvailable -Name ActiveDirectory) {
            Import-Module ActiveDirectory
            Write-Host "Active Directory Module has imported." -ForegroundColor Green -BackgroundColor Black
        } else {
            Write-Host "Active Directory Module is not installed." -ForegroundColor red -BackgroundColor Black
    
            Write-Host "Installing Active Directory Module..." -ForegroundColor Yellow
            Add-WindowsFeature RSAT-AD-PowerShell
            ''
            if (Get-Module -ListAvailable -Name ActiveDirectory) {
            Write-Host "Active Directory Module has installed." -ForegroundColor Green -BackgroundColor Black
            Import-Module ActiveDirectory
            Write-Host "Active Directory Module has imported." -ForegroundColor Green -BackgroundColor Black
            } else {
            Write-Host "Operation aborted. Active Directory Module was not installed." -ForegroundColor red -BackgroundColor Black
            exit
            }
        }

    ''
} else {
    Write-Host "Operation aborted." $ServerName "is not AAD Connect Server. Please run this tool on AAD Conect Server." -ForegroundColor red -BackgroundColor Black
    exit
    ''
}

}


$ErrorActionPreference = "SilentlyContinue"
''
Write-Host "Checking Service Connection Point (SCP)..." -ForegroundColor Yellow
$Root = [ADSI]"LDAP://RootDSE"
$ConfigurationName = $Root.rootDomainNamingContext
$scp = New-Object System.DirectoryServices.DirectoryEntry;
$scp.Path = "LDAP://CN=62a0ff2e-97b9-4513-943f-0d221bd30080,CN=Device Registration Configuration,CN=Services,CN=Configuration," + $ConfigurationName;
if ($scp.Keywords -ne $null){
    Write-Host "Service Connection Point is configured as following:" -ForegroundColor Green -BackgroundColor Black
    ''
    $scp.Keywords
    exit
}else{
   Write-Host "Service Connection Point is not configured:" -ForegroundColor red -BackgroundColor Black
   
   ConfigureSCP


}


