# Purpose: auditAD — Microsoft Azure cloud resource management.

#region HTML style
$HTMLCSS=@"
<style>
table {
   # border-collapse: collapse;
   border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;
}
h2 {text-align:center}
th, td {
    #padding: 8px;
    #text-align: left;
    #border-bottom: 1px solid #ddd;
    border-width: 1px; padding: 3px; border-style: solid; border-color: black;
}

tr:hover{background-color:#f5f5f5}
</style>
"@

##Configuration partition d'annuaire ##

#Initialisation des variables globales 
#Récupération du nom de la forêt, des noms des domaines et de tous les DCs.
#Emplacement du fichier html
#Global variable
#forest is current forest
#forest name is curent forest name
#domaine name is all domains name in the current forest
#allDCs is all DC in the entire forest
#htmlReportPath is the path where the HTML report is created
$forest=get-adforest
$forestName=$forest.Name
$domainName=$forest.domains
$allDCs = (Get-ADForest).Domains | Foreach-Object { Get-ADDomainController -Filter * -Server $_ }
$htmlReportPath = "c:\temp\"
$date = (get-date -Format "dd_MM_yyyy_HH_mm")
$htmlReportFileName = "ADReport_$date.html"
$DNSPathFile = "c:\temp\dns.txt"


#Region generalities
#Check if ActiveDirectory Recyclebin is enable or not
#If it's disabled result is null 
#If it's enabled result is an object collection
function Get-RecycleBinState {
    if ((Get-ADOptionalFeature -Filter 'name -eq "Recycle Bin Feature"').EnabledScopes)
    {
        $recyclebinState= $true
    }
    else
    {
        $recyclebinState= $false
    }
    $result=[PSCustomObject]@{
        RecycleBin = "RecycleBin"
        State = $RecyclebinState
    }
    return $result    
}


#Schema version
function Get-SchemaVersion {
    $SchemaVersion = (Get-ADObject (Get-ADRootDSE).schemaNamingContext -Property objectVersion).objectVersion 
    switch ($SchemaVersion)
    {
        '13' { $result = "13 - Windows 2000"}
        '30' { $result = "30 - Windows 2003"}
        '31' { $result = "31 - Windows 2003 R2"}
        '44' { $result = "44 - Windows 2008"}
        '47' { $result = "47 - Windows 2008 R2"}
        '56' { $result = "56 - Windows 2012"}
        '69' { $result = "69 - Windows 2012 R2"}
        '87' { $result = "87 - Windows 2016"}
        '88' { $result = "88 - Windows 2019"}
        Default { $result = "La valeur n'est pas renseignée dans le script"}
    }
    return $result
}

#Get number of days for tombstone
function Get-TombstoneDays 
{
    $query = (Get-ADObject -Identity “CN=Directory Service,CN=Windows NT,CN=Services,$((Get-ADRootDSE).configurationNamingContext)” -properties tombstonelifetime).tombstonelifetime
    if ($null -ne $query)
    {
        $result = $query
    }
    else 
    {
        $result = "60"
    }
    return $result
}

#Get summary informations about AD forest
#Forest functional level, schema master, schema version, domain naming master, tombstone lifetime, recyclebin state and all domains names
function Get-ForestSummary {
    $result=[PSCustomObject][ordered]@{
        ForestName = $forestname
        'Forest Functional Level' = $forest.ForestMode
        'Schema Master' =  $forest.schemamaster
        'Schema Version' = $SchemaVersion
        'Domain Naming Master' = $forest.domainnamingmaster
        'Tombstone lifetime' = $tombstone
        RecycleBin = $recyclebin.state
        DomainName = $domainname -join ", "
    }
    return $result
}

#endregion

#Region FSMO domain roles
#Get all FSMO domains rôles in all domains (infrastructure master, RID master and PDC emulator) and the domain functional level
function Get-FSMOAllDomains {
    $result=$domainName | Foreach-Object {
        $domain = Get-ADDomain $_

            [PSCustomObject]@{
            Domain = $_
            InfrastructureMaster = $domain.infrastructuremaster.split(".")[0]
            RIDMaster = $domain.RIDMaster.split(".")[0]
            PDCEmulator = $domain.PDCEmulator.split(".")[0]
            DomainFunctionalLevel=$domain.domainmode
        }
    }
    return $result
}
#endregion

#Region Domain Created date
#Give domain name, domain netbios name and domain creation date
Function Get-DomainCreatedDate {
    $requestparam = @{
        SearchBase = (Get-ADForest).PartitionsContainer
        LDAPFilter = "(&(objectClass=crossRef)(systemFlags=3))"
        Property = @("dnsRoot", "nETBIOSName", "whenCreated")
    }

     foreach ($domain in Get-ADObject @requestparam | Sort-Object WhenCreated)
     {
        [PSCustomObject]@{
            DomainName = $domain.dnsRoot -join ''
            DomainNetbiosName = $domain.netbiosname
            WhenCreated = $domain.WhenCreated
        }
     }
}
#endregion

#Region duplicate SPN
#Get number of duplicates SPNs in the entire forest and their account
Function Get-DuplicateSPNNumber
{
    $command = setspn -X -F
    $query = $command -match "(?mi)^(\d+)"
    if ($query -match "^0")
    {
        return $query
    }
    else
    {
        return $command
    }
} 
#endregion

#region globalcatalogs
#Check if DCs are Global Catalogs 
Function Get-GlobalCatalogServers
{
    foreach ($DC in $allDCs)
    {
        [PSCustomObject]@{
            ServerName = $DC.hostname
            IsGlobalCatalog = $DC.IsGlobalCatalog
        }

    }
} 
#endregion

#region all RODC
#Check if all DC are Read only domain controller
Function Get-RODCServers
{
    foreach ($DC in $allDCs)
    {
        [PSCustomObject]@{
            ServerName = $DC.hostname
            IsRODCServer = $DC.IsReadOnly
        }

    }
} 
#endregion

#region NTP
#Give time source from all DCs
function Get-TimeSource {
    $result=$alldcs | Foreach-Object {
        $req=Invoke-Command -ComputerName $_.hostname -ScriptBlock { w32tm /query /source }
        [PSCustomObject]@{
            Server = $_.name
            TimeSource = $req
        }
    }
    return $result
}
#endregion

#region AD sites and services
#List all AD sites, associated subnets and location fields
function Get-SitesSubnets
{
    $query=[DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites.subnets
    $query | ForEach-Object{
        [PSCustomObject]@{
            Name = $_.name
            Site = $_.site           
        }
    }
}
#List all sites costs and replication schedule 
function Get-SiteLinkInformation {
    $SiteLinkParam = @{
        Filter = 'objectClass -eq "siteLink"'
        Searchbase = (Get-ADRootDSE).ConfigurationNamingContext
        Property = @("Options", "Cost", "ReplInterval", "SiteList", "Schedule")
    }
    $param = @(
        'Name',
        @{Name="SiteCount";Expression={$_.SiteList.Count}},
        'Cost', 
        'ReplInterval',
        @{Name="Schedule";Expression={If($_.Schedule){If(($_.Schedule -Join " ").Contains("240")){"NonDefault"}Else{"24x7"}}Else{"24x7"}}}, 
        @{Name="Options";Expression={if($_.Options){$_.options}Else{"<N/A>"}}}
    )
    Get-ADObject @SiteLinkParam | Select-Object $param
}


#list sites with domain controler,subnet and site link number
function Get-EmptySite {
    $BadSitesParam = @{
        LDAPFilter = '(objectClass=site)'
        SearchBase = (Get-ADRootDSE).ConfigurationNamingContext
        Properties = @("WhenCreated", "Description")
    }
    $param=@(
        'name', 
        @{label='IsEmpty';expression={If ($(Get-ADObject -Filter {ObjectClass -eq "nTDSDSA"} -SearchBase $_.DistinguishedName)) {$false} else {$true}}}, 
        @{label='DCName';expression={@($((Get-ADObject -Filter {ObjectClass -eq "nTDSDSA"} -SearchBase $_.DistinguishedName) | ForEach-Object { $_.distinguishedname.split(",")[1].split("=")[1]}))-join ", "}},
        @{label='DCCount';expression={@($(Get-ADObject -Filter {ObjectClass -eq "nTDSDSA"} -SearchBase $_.DistinguishedName)).Count}},
        @{label='SubnetCount';expression={@($(Get-ADObject -Filter {ObjectClass -eq "subnet" -and siteObject -eq $_.DistinguishedName} -SearchBase (Get-ADRootDSE).ConfigurationNamingContext)).Count}},
        @{label='SiteLinkCount';expression={@($(Get-ADObject -Filter {ObjectClass -eq "sitelink" -and siteList -eq $_.DistinguishedName} -SearchBase (Get-ADRootDSE).ConfigurationNamingContext)).Count}}
        
    )
    $result=Get-ADObject @BadSitesParam |
    Select-Object $param

    return $result
}

#give number of manual and auto created linksite
function get-adconnectionsitelink 
{
    $result = [PSCustomObject]@{
            description = "object connection"
            autogenerated = (Get-ADReplicationConnection -Filter * | Where-Object {$_.autogenerated -eq $true} | Measure-Object).count
            manual = (Get-ADReplicationConnection -Filter * | Where-Object {$_.autogenerated -eq $false} | Measure-Object).count
            total = (Get-ADReplicationConnection -Filter * | Measure-Object).count
        }
    return $result
}
#endregion

#region AD services
#Check all necessary services for AD (ntfrs or dfsr,netlogon,kdc,w32time)
Function Get-ADServicesStatus
{
    $services =@("ntfrs","dfsr","netlogon","kdc","w32time")
    foreach ($DC in $allDCs)
    {
        foreach ($service in $services)
        {
            $query = get-service $service -ComputerName $DC -ErrorAction SilentlyContinue
            [PSCustomObject]@{
                ComputerName = $DC
                ServiceName = $query.name
                ServiceStatus = $query.status
            }
        }
    }
} 
#endregion

#region dcdiag
#Execute DCdiag on all Domain Controllers
#this function is implemented to be able to capture dcdiag output and convert it to an object with regex
#Nativement dcdiag a pour sortie du texte. Cette fonction permet de faire un objet en sortie.
function Invoke-DcDiag {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController
    )
    $command = dcdiag.exe /s:$DomainController
    $result=@()
    #Cette ligne est nécessaire pour que l'éxécution du script fonctionne dans l'ISE en francais
    [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(437)    
   
   # connaitre la langue courante du système : (Get-Culture).lcid)  1033 = anglais 1036 = francais

   #regex for french language
    $regex = [regex]"(?sm)\.+\sLe\stest\s(\w+).+?de\s([A-Za-z0-9_-]+)\sa\s(réussi|échoué)" 
    $allmatches = $regex.Matches($command)
    Foreach($line in $allmatches){
        $ObjectDiag = [PSCustomObject]@{
            Server = $DomainController.Split(".")[0]
            TestName = $line.Groups[1].Value
            TestResult = $line.Groups[3].Value
        }
        $result+=$ObjectDiag
    }
    return $result
}
#endregion

#region last hotfix date
#Last Time Microsoft update is installed on all DCs
Function Get-LastUpdateDate
{
    $hotfixes=((get-hotfix).properties | Where-Object {$_.name -eq "installedon"}).value 
    $temp = @()
    foreach ($hotfix in $hotfixes)
    {
        $temp+=[datetime]$hotfix
    }
    $result = $temp | Sort-Object -Descending | Select-Object -first 1
    return $result.DateTime
} 
#endregion

#region bitlocker
#Get Bitlocker State on all DCs
#If bitlocker module is installed, list all volume and check if they are encrypted.
#If bitlocker module is not installed, volume are not encrypted.
Function Get-BitlockerState
{
    foreach ($DC in $allDCs)
    {
        #Check if bitlocker module is installed on the DC
        if ($null -ne (Invoke-Command -ComputerName $DC.hostname -ScriptBlock {get-command -Module bitlocker}))
        {
            $query=Invoke-Command -ComputerName $DC.hostname -ScriptBlock {get-bitlockervolume | sort-object MountPoint}

            foreach ($line in $query)
            {
                [PSCustomObject]@{
                    ServerName = $line.computerName
                    IsInstalled = $True           
                    MountPoint = $line.MountPoint
                    VolumeStatus = $line.volumeStatus
                }
            }
        }        
        else
        {
        
            [PSCustomObject]@{
                ServerName = $DC.hostname   
                IsInstalled = $false        
                MountPoint = "<N/A>"
                VolumeStatus = "<N/A>"
            }
        }
        
    }
}
#endregion

#region sensitive group member
#List all sensitive group member in all domains
$SchemaAdmin = (Get-ADGroupMember -Identity "$((get-addomain).domainsid.value)-518" -Recursive).name 
$EnterpriseAdminsMember=(Get-ADGroupMember -Identity "$((get-addomain).domainsid.value)-519" -Recursive).name
$DomainsAdminsMember=$domainName | Foreach-Object {write-output "Domaine : $_ ";(Get-ADGroupMember -Identity "$((get-addomain).domainsid.value)-512" -Recursive).name}
$AccountOperator = $domainName | Foreach-Object {write-output "Domaine : $_ ";(Get-ADGroupMember -Identity S-1-5-32-548 -Recursive).name}
$Administrators = $domainName | Foreach-Object {write-output "Domaine : $_ ";(Get-ADGroupMember -Identity S-1-5-32-544 -Recursive).name}
$BackupOperators = $domainName | Foreach-Object {write-output "Domaine : $_ ";(Get-ADGroupMember -Identity S-1-5-32-551 -Recursive).name}
$ServerOperators = $domainName | Foreach-Object {write-output "Domaine : $_ ";(Get-ADGroupMember -Identity S-1-5-32-549 -Recursive).name}
#endregion

#region SID history
#All migrated users from previous domain / forest in current domain
function Get-UsersSIDHistory
{
    $query = Get-aduser -filter * -properties sidhistory | Where-Object {$_.sidhistory} 
    foreach ($user in $query)
    {
        [PSCustomObject]@{
            name = $user.name
            SamAccountName = $user.SamAccountName
            ActualSID = $user.SID
            SIDHistory = $user.SIDHistory -join ","
        } 
    }
}
#endregion

#region privileged account
#Get all accounts with AdminCount = 1
#in AD there is an object called adminsdholder. this object protect securite information of all sensitive account (domain admin, backup operator, acocunt operator, ...)
#All these group member have attribute admincount=1
#sdprop process runs each 1 hour on PDC DC to disable inheritanceon on all protected group objects member and apply adminsdholder permission.
Function Get-PrivilegedAccounts {
    foreach ($domain in $domainName) {        
        Get-ADObject -filter 'AdminCount -eq 1' -server $domain | 
        Where-Object { $_.ObjectClass -eq 'user' } | 
        ForEach-Object {
            [PSCustomObject]@{
                DomainName        = $domain
                PrivilegedAccount = $_.name
            }
        }
    }   
}
#endregion

#region firewall state
#Get status of firewall for all profiles (domain, private, public) in all DC
Function Get-FirewallState
{
    foreach ($DC in $allDCs)
    {
        $query = Invoke-Command -ComputerName $DC -ScriptBlock {Get-NetFirewallProfile} 
        [PSCustomObject]@{
            ServerName = $DC.hostname
            Domain = ($query | Where-Object {$_.profile -eq "Domain"}).enabled         
            Private = ($query | Where-Object {$_.profile -eq "Private"}).enabled 
            Public = ($query | Where-Object {$_.profile -eq "Public"}).enabled 
        }        
    }
} 
#endregion

#region hardware DC configuration
#Hardware Configuration of all DCs (Logical CPU number,RAM, physical or virtual, OS, last boot)
function Get-AllDCHardware
{
    $allDCs | Foreach-Object {
        [PSCustomObject]@{
            ServerName = $_.name
            LogicalCPUNb = (Get-CimInstance win32_computersystem -ComputerName $_.hostname).numberOfLogicalProcessors
            'RAM(GB)' = [math]::Round((Get-CimInstance win32_computersystem -ComputerName $_.hostname).TotalPhysicalMemory/1GB)
            Type = (get-CimInstance win32_computersystem -ComputerName $_.hostname).model
            OS = (Get-CimInstance Win32_OperatingSystem -ComputerName $_.hostname).caption
            LastBoot = (Get-CimInstance -ClassName win32_operatingsystem -ComputerName $_.hostname).lastbootuptime
        }
    }
}
#endregion

#region diskspace usage on DC
#Disk space usage of all DCs
function Get-AllDCDiskSettings {
     $allDCs | Foreach-Object {
        $disk=get-CimInstance -class win32_logicaldisk -ComputerName $_.name | Where-Object {$_.DriveType -eq 3}
        $disk | Foreach-Object {
            [PSCustomObject]@{
                ServerName = $_.systemname
                DiskLetter = $_.DeviceID
                'FreeSpace(GB)' = [math]::Round($_.FreeSpace/1GB)
                'TotalSpace(GB)' = [math]::Round($_.size/1GB)
            }
        }
    }
}
#endregion

#region DC network configuration 
#Network setup of all DCs (IP,subnet,gateway,DNS1,DNS2)
function Get-AllDCNetworkSettings {
    $alldcs | Foreach-Object {
        $req=Get-CimInstance -Class "win32_networkadapterconfiguration" -ComputerName $_.name | Where-Object {$_.ipenabled -eq "true"}
        [PSCustomObject]@{
            Name = $_.name
            IPAddress = $req.ipaddress[0]
            Subnet = $req.ipsubnet[0]
            Gateway = $req.defaultipgateway[0]
            DNS1 = $req.dnsserversearchorder[0]
            DNS2 = $req.dnsserversearchorder[1]
        }
    }
}
#endregion

#region default OU
#List default OU for computer and OU creation in domain
Function Get-OURedirect
{
    $domainName | Foreach-Object {
        [PSCustomObject]@{
            DomainName = $_
            DefaultComputersOU = (Get-ADDomain -Identity $_).ComputersContainer     
            DefaultUsersOU = (Get-ADDomain -Identity $_).UsersContainer
        }
    }   
} 
#endregion

#region NTDS size and location
#List Active directory base and logs paths and size
function Get-AllDCNTDSSettings {
    $allDCs | Foreach-Object {
        $ntdsConfig=invoke-command -computername $_.name -scriptblock {get-itemproperty "HKLM:\SYSTEM\CurrentControlSet\Services\ntds\Parameters"}
        [PSCustomObject]@{
            Name = $_.name
            DBPath = $ntdsConfig.'DSA Database file'
            DBLogPath = $ntdsConfig.'Database log files path'
            'DBSize(MB)' = [math]::Round((get-childitem $($ntdsConfig.'DSA Database file')).length/1MB)
        }
    }
}
#endregion

#region netlogon and sysvol
#Check if Netlogon and Sysvol folders are shared
Function Get-ADSharedFolderStatus
{
    $folders =@("netlogon","sysvol")
    foreach ($DC in $allDCs)
    {
        foreach ($folder in $folders)
        {
            $query = get-smbshare -CimSession $DC.hostname -Name $folder
            [PSCustomObject]@{
                ServerName = $DC.hostname
                SharedFolderName = $folder
                State = $query.ShareState
            }
        }
    }
}
#endregion

#region FRS or DFSR is used
#Check if GPO (SYSVOL folder) is replicated by FRS or DFS-R mechanism
#If msDFSR-Flags attribute equal empty FRS is used 
#If msDFSR-Flags attribute equal 0  migration from FRS to DFSR is started 
#If msDFSR-Flags attribute equal 16 migration from FRS to DFSR is prepared
#If msDFSR-Flags attribute equal 32 migration from FRS to DFSR is redirected 
#If msDFSR-Flags attribute equal 48 migration from FRS to DFSR is eliminated (ended) 

function Get-SysvolReplicationType {
    $result = $domainName| Foreach-Object {
        $DFSRFlags=(Get-ADObject -identity "CN=DFSR-GlobalSettings,$((Get-ADDomain).systemscontainer)" -properties msDFSR-Flags).'msDFSR-Flags'
        $query=$DFSRFlags -eq 48
        [PSCustomObject]@{
            Domain = $_ 
            DFSR = $query
            FRS = -not $query
        }
    }
    return $result
}
#endregion


#region SYSVOL size
#SYSVOL folder and size in KB
function Get-SysvolSummary {
    $result=$domainName| Foreach-Object {
    $syssize=(get-childitem "\\$_\sysvol" -recurse | Measure-Object -property Length -Sum).sum / 1KB
    $getADDomain=Get-ADDomain
        [PSCustomObject]@{
            Domain = $_
            'SYSVOLSize(KB)' = [math]::Round($syssize)
            RootFolderSYSVOL = (get-childitem "\\$($getADDomain.forest)\sysvol\$($getADDomain.forest)").name -join ", "
            PolicyFolderSYSVOL = (get-childitem "\\$($getADDomain.forest)\sysvol\$($getADDomain.forest)\policies").name -join ", "
            ScriptFolderSYSVOL = (get-childitem "\\$($getADDomain.forest)\sysvol\$($getADDomain.forest)\scripts").name -join ", "
            TotalCreatedGPONb = (get-gpo -All).count
        }
    }
    return $result
}
#endregion

#region Centralstore
function Test-Policydefinitions
{
    $domainName| Foreach-Object {
        $query = test-path "\\$_\SYSVOL\$_\policies\PolicyDefinitions"
        [PSCustomObject]@{
            Domain = $_ 
            PolicyDefinitionsFolderExists = $query
        }
    }
} 
#endregion


#region DHCP Allowed
#Get All Microsoft DHCP allowed in AD forest
Function Get-AllowedDHCPServers
{
    foreach ($domain in $domainName){
    $count=0   
        foreach ($DC in $allDCs)
        {
            if($null -ne (get-command -Module dhcpserver))
            {
                $query = Get-DhcpServerInDC
                if ($null -ne $query)
                {
                    $count=1
                    $query | ForEach-Object {
                        [PSCustomObject]@{		
		                    'Domain'    = $domain
		                    'DHCPServerName' = $_.DnsName
                        }
                    }
                    break;
                }
            }
        }        
        if ($count -eq 0)
        {
            [PSCustomObject]@{		
		        'Domain'    = $domain
		        'DHCPServerName' = "None"
            }
        }
    }
}   
#endregion

#region accounts disabled
#Total Computer and users number and total disabled  
Function Get-ADAccountState {
    [PSCustomObject]@{
        TotalUsers = (Get-ADUser -filter *).count
        DisabledUsers = (Get-AdUser -filter * |Where-Object {$_.enabled -eq $False}).count
        TotalComputers = (Get-ADComputer -filter *).count
        DisabledComputers = (Get-AdUser -filter * |Where-Object {$_.enabled -eq $False }).count
    }        
} 
#endregion


#Computers and users disabled and where password never expire
Function Get-ADPasswordState{
    [PSCustomObject]@{
        UsersPasswordNeverExpire = (get-aduser -filter * -properties passwordneverexpires | Where-Object {$_.passwordneverexpires -eq $true}).count
        ComputersPasswordNeverExpire = (get-adcomputer -filter * -properties passwordneverexpires | Where-Object {$_.passwordneverexpires -eq $true}).count
        UsersLocked = (get-aduser -filter * -properties LockedOut | Where-Object {$_.LockedOut -eq $true}).count
        ComputersLocked = (get-adcomputer -filter * -properties LockedOut | Where-Object {$_.LockedOut -eq $true}).count
    }        
} 
#endregion

#region GPO
function Get-GPOPasswordSettings
{
    $passwordpolicy=Get-ADDefaultDomainPasswordPolicy
    [PSCustomObject]@{
        #Password Complexity Enabled (3 of 4 between tiny letter, capital letter, number and special character)
        ComplexityEnabled=$passwordpolicy.complexityEnabled
        #Account lockout time
        'LockoutDuration(hours)'=$passwordpolicy.LockoutDuration
        #Tentative number before account is locked
        lockoutThreshold=$passwordpolicy.LockoutThreshold
        #Maximum password age
        'MaxPasswordAge(days)'=$passwordpolicy.MaxPasswordAge
        #Minimum password age
        'MinPasswordAge(days)'=$passwordpolicy.MinPasswordAge
        #Minimum password length
        MinPasswordLength=$passwordpolicy.MinPasswordLength
        #Password history
        PasswordHistoryCount=$passwordpolicy.PasswordHistoryCount
        #Reversible encryption is enabled ?
        ReversibleEncryptionEnabled=$passwordpolicy.ReversibleEncryptionEnabled
    }
}
#endregion

#region computerOS
function Get-ComputerOSVersion{
    $param=@{
        filter = "operatingsystem -like 'windows*'"
        properties = "operatingsystem","operatingsystemversion"
    }
    $req = (Get-ADcomputer @param) | group-object operatingsystem,operatingsystemversion | Sort-Object name -Descending 
    foreach ($entry in $req)
    {
        [pscustomobject]@{
            Name = $entry.name.split(",")[0]
            ReleaseID = $entry.name.split(",")[1]
            Number = $entry.count
        }
    }
}

#endregion

#check if _msdcs exist as independant domainzone and is forest wide scope replication
function Get-MsdcsSettings
{
    $RegexReplicationType = "AD-Forest|AD-Domain|AD-Legacy"
    dnscmd /zoneinfo _msdcs.$forestname > $DNSPathFile
    if(Select-String -Path $DNSPathFile -Pattern $RegexReplicationType)
    {
        [PSCustomobject]@{
            DirectDNSZoneCreated = $True
            ReplicationType = (Select-String -Path $DNSPathFile -Pattern $RegexReplicationType).ToString().Split(" ")[4]
        }
    }
    else
    {
        [PSCustomobject]@{
            DirectDNSZoneCreated = $false
            ReplicationType = "Not applicable"
        }
    }
}

<#
#paramétrage IP (a lancer sur chaque DC) NON COMPATIBLE 2008R2
$allDCs = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }
$NetworkConfigDC=$allDCs | Foreach-Object {
    $req=Invoke-Command -ComputerName $_.name -ScriptBlock { Get-NetIPConfiguration}

    [PSCustomObject]@{
        Name = $_.name
        InterfaceAlias = $req.InterfaceAlias
        Ipaddress = $req.IPv4Address.ipaddress
        Mask = $req.IPv4Address.prefixLength
        Gateway = $req.IPv4DefaultGateway.nexthop
        DNS = $req.DNSServer.serveraddresses | where { $_ -ne "::1"}
    }
}
#>


#region main function
###### Exécution des commandes
$recyclebin = Get-RecycleBinState
$SchemaVersion = Get-SchemaVersion 
$tombstone = Get-TombstoneDays
$summary = Get-ForestSummary
$FSMODomain = Get-FSMOAllDomains
$DomainCreatedDate = Get-DomainCreatedDate
$DuplicateSPNNumber = Get-DuplicateSPNNumber
$GlobalCatalogServers = Get-GlobalCatalogServers
$RODCServers = Get-RODCServers
$TimeSource = Get-TimeSource
$SiteLink = Get-SiteLinkInformation 
$BadSites = Get-EmptySite
$adconnectionsitelink  = get-adconnectionsitelink 
$ADServicesStatus = Get-ADServicesStatus
$ADServicesStatusResult = $ADServicesStatus | Where-Object {$_.ServiceStatus -eq "Stopped"} 
$dcdiag = $alldcs | Foreach-Object {Invoke-DcDiag -DomainController $_.hostname}
$dcdiagResult = $dcdiag| Group-Object testresult | Select-Object name,count
$dcdiagError = ($dcdiag | Group-Object testresult | where-object {$_.name -eq "échoué"}).group
$LastUpdateTime = Get-LastUpdateDate
$BitlockerState = Get-BitlockerState

$FirewallState = Get-FirewallState
$DCHardware = Get-AllDCHardware
$DCDiskHardware = Get-AllDCDiskSettings
$DCNetworkConfig = Get-AllDCNetworkSettings 
$DCNTDSConfig = Get-AllDCNTDSSettings 
$ADSharedFolderStatus = Get-ADSharedFolderStatus
$SYSVOLReplication = Get-SysvolReplicationType 
$SYSVOLSize = Get-SysvolSummary
$OURedirect = Get-OURedirect
$UsersSIDHistory = Get-UsersSIDHistory
$PrivilegedAccounts = Get-PrivilegedAccounts
$ADAccountState = Get-ADAccountState
$ADPasswordState = Get-ADPasswordState
$DHCPAllowed = Get-AllowedDHCPServers
$GPOPasswordSettings = Get-GPOPasswordSettings
$ComputerOSVersion = Get-ComputerOSVersion
$Policydefinitions = Test-Policydefinitions
$MsdcsSettings = Get-MsdcsSettings
#endregion


<#
.Synopsis
   Generate HTML report
.DESCRIPTION
   Use all variable to build html report with CSS style written on the top of this page
.EXAMPLE
   Get-HTMLReport -Path "c:\temp\report.html"
#>
function Get-HTMLReport
{
    [CmdletBinding()]

    Param
    (
        #HTML file path
        [Parameter(Mandatory=$true)]
        [string] $Path,

        #HTML file name
        [Parameter(Mandatory=$true)]
        [string] $FileName
    )
    begin   
    {
        if(!(Test-Path $Path))
        {
            New-Item -Path $Path -ItemType directory
        }
        $HTMLfilename="$path\$filename.html"
    }
    process
    {
    #HTML generation

    $HTMLTitle = "<h1>Active Directory Report</h1>"


    $recyclebin = $recyclebin | ConvertTo-Html -Fragment
    $SchemaVersion = $SchemaVersion | ConvertTo-Html -Fragment
    $tombstone = $tombstone | ConvertTo-Html -Fragment
    $summary = $summary | ConvertTo-Html -Fragment -as list
    $FSMODomain = $FSMODomain | ConvertTo-Html -Fragment
    $DomainCreatedDate = $DomainCreatedDate | ConvertTo-Html -Fragment
    $DuplicateSPNNumber = $DuplicateSPNNumber | ConvertTo-Html -Fragment -property @{label='DuplicateSPNNumber' ; expression = {$_}}
    $GlobalCatalogServers = $GlobalCatalogServers | ConvertTo-Html -Fragment
    $RODCServers = $RODCServers | ConvertTo-Html -Fragment
    $TimeSource = $TimeSource | ConvertTo-Html -Fragment
    $SitesSubnets = $SitesSubnets | ConvertTo-Html -Fragment
    $SiteLink = $SiteLink  | ConvertTo-Html -Fragment
    $BadSites = $BadSites | ConvertTo-Html -Fragment
    $adconnectionsitelink  = $adconnectionsitelink  | ConvertTo-Html -Fragment
    $ADServicesStatus = $ADServicesStatus | ConvertTo-Html -Fragment
    $ADServicesStatusResult = $ADServicesStatusResult | ConvertTo-Html -Fragment
    $dcdiag = $dcdiag | ConvertTo-Html -Fragment
    $dcdiagResult = $dcdiagResult | ConvertTo-Html -Fragment
    $dcdiagError = $dcdiagError | ConvertTo-Html -Fragment
    $LastUpdateTime = $LastUpdateTime | ConvertTo-Html -Fragment -property @{label='Last Update Date' ; expression= {$_}}
    $BitlockerState = $BitlockerState | ConvertTo-Html -Fragment

    $SchemaAdmin = $SchemaAdmin | ConvertTo-Html -Fragment -property @{label='Schema Admin' ; expression = {$_}}
    $EnterpriseAdminsMember= $EnterpriseAdminsMember | ConvertTo-Html -Fragment -property @{label='Enterprise Admins' ; expression = {$_}}
    $DomainsAdminsMember=$DomainsAdminsMember | ConvertTo-Html -Fragment -property @{label='Domain Admins' ; expression = {$_}}
    $AccountOperator = $AccountOperator | ConvertTo-Html -Fragment -property @{label='Account operators' ; expression = {$_}}
    $Administrators = $Administrators | ConvertTo-Html -Fragment -property @{label='Administrateurs' ; expression = {$_}}
    $BackupOperators = $BackupOperators | ConvertTo-Html -Fragment -property @{label='Backup operators' ; expression = {$_}}
    $ServerOperators = $ServerOperators | ConvertTo-Html -Fragment -property @{label='Server operators' ; expression = {$_}}

    $FirewallState = $FirewallState | ConvertTo-Html -Fragment
    $DCHardware = $DCHardware | ConvertTo-Html -Fragment
    $DCDiskHardware = $DCDiskHardware | ConvertTo-Html -Fragment
    $DCNetworkConfig = $DCNetworkConfig | ConvertTo-Html -Fragment
    $DCNTDSConfig = $DCNTDSConfig | ConvertTo-Html -Fragment
    $ADSharedFolderStatus = $ADSharedFolderStatus | ConvertTo-Html -Fragment
    $SYSVOLReplication = $SYSVOLReplication | ConvertTo-Html -Fragment
    $SYSVOLSize = $SYSVOLSize | ConvertTo-Html -Fragment
    $OURedirect = $OURedirect | ConvertTo-Html -Fragment
    $UsersSIDHistory = $UsersSIDHistory | ConvertTo-Html -Fragment
    $PrivilegedAccounts = $PrivilegedAccounts | ConvertTo-Html -Fragment
    $ADAccountState = $ADAccountState | ConvertTo-Html -Fragment
    $ADPasswordState = $ADPasswordState | ConvertTo-Html -Fragment
    $DHCPallowed = $DHCPAllowed | ConvertTo-Html -Fragment
    $GPOPasswordSettings = Get-GPOPasswordSettings | ConvertTo-Html -Fragment
    $ComputerOSVersion = Get-ComputerOSVersion | ConvertTo-Html -Fragment
    $Policydefinitions = $Policydefinitions | ConvertTo-Html -Fragment
    $MsdcsSettings = $MsdcsSettings | ConvertTo-Html -Fragment


    #region HTML body

    $HTML = @"
    <!DOCTYPE html>
    <html>
    <head>
    <title>Report</title>
    <meta name="generator" content="PowerShell" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    $HTMLCSS
    </head>
    <body>
    $HTMLTitle
    <h3>Summary</h3>
    $Summary 

    <h3> FSMO Domain Roles </h3>
    $FSMODomain 

    <h3> Domain creation date </h3>
    $DomainCreatedDate 

    <h3> Duplicates SPN </h3>
    $DuplicateSPNNumber

    <h3> Global Catalogs </h3>
    $GlobalCatalogServers

    <h3> RODC </h3>
    $RODCServers

    <h3>Time source</h3>
    $TimeSource


    <h3>Sites and Services AD</h3>
    <h4> Networks </h4>
    $SitesSubnets 
    <h4> Sites links </h4>
    $SiteLink 
    <h4> Empty sites </h4>
    $BadSites
    <h4> Sites links type and number </h4>
    $adconnectionsitelink


    <h3>Etats Services AD</h3>
    $ADServicesStatus
    Stopped services
    $ADServicesStatusResult 

    <h3>Dcdiag</h3>
    $dcdiag <br />
    Result summary
    $dcdiagResult <br />
    Failed result
    $dcdiagError

    <h3>_msdcs migration</h3>
    $MsdcsSettings  

    <h3>Date of the last update</h3>
    $LastUpdateTime

    <h3>Bitlocker</h3>
    $BitlockerState 

    <h3>Schema administrator members</h3>
    $SchemaAdmin

    <h3>Enterprise administrator members</h3>
    $EnterpriseAdminsMember

    <h3>Domain admins members</h3>
    $DomainsAdminsMember

    <h3>Account operrator members</h3>
    $AccountOperator

    <h3>Administrator members</h3>
    $Administrators

    <h3>Backup operator members</h3>
    $BackupOperators

    <h3>Server operator members</h3>
    $ServerOperators

    <h3>Account with SID history</h3>
    $UsersSIDHistory

    <h3>Privileged group members</h3>
    $PrivilegedAccounts

    <h3>Windows firewall state</h3>
    $FirewallState

    <h3>Hardware configuration</h3>
    $DCHardware <br />
    $DCDiskHardware

    <h3>Network configuration</h3>
    $DCNetworkConfig

    <h3>Default account creation OU</h3>
    $OURedirect

    <h3>NTDS base configuration</h3>
    $DCNTDSConfig

    <h3>Netlogon and sysvol shared state</h3>
    $ADSharedFolderStatus

    <h3>SYSVOL replication</h3>
    $SYSVOLReplication

    <h3>SYSVOL size</h3>
    $SYSVOLSize

    <h3>Policydefinition</h3>
    $Policydefinitions    

    <h3>Allowed DHCP servers</h3>
    $DHCPAllowed

    <h3>Disabled User and computer account</h3>
    $ADAccountState

    <h3>Locked accountnumber</h3>
    $ADPasswordState <br />

    <h3>Default password domain policy</h3>
    $GPOPasswordSettings <br />

    <h3>Domain computers OS</h3>
    $ComputerOSVersion <br />  
    
    $End Date $(get-date -Format "dd/MM/yyyy HH:mm")
    </body>
    </html>
"@

    $HTML | out-file -FilePath $HTMLfilename
    #endregion

    Invoke-Item $HTMLfilename

    }
}

Get-HTMLReport -Path $htmlReportPath -FileName $htmlReportFileName



