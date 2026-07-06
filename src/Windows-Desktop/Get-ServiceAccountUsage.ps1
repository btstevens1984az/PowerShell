# Purpose: Get-ServiceAccountUsage — Windows desktop configuration and management.
function Get-ServiceAccountUsage {

    Param(
        [CmdletBinding(DefaultParametersetName='Explicit')]
 
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,
            HelpMessage = 'The name of the [remote] computer or an array of computer names')]
        [Alias('CN','IPAddress','Server','Computer','__SERVER')]
        [ValidateNotNullOrEmpty()]
        [string[]] $ComputerName=$ENV:COMPUTERNAME,

        [Parameter(ParameterSetName='Explicit',
            HelpMessage = 'The user account being used on a Service, Scheduled Task or Application Pool')]
        [Alias('User','UserName','Account')]
        [string] $UserAccount='*',

        [Parameter(Mandatory=$true, ParameterSetName='Implicit',
            HelpMessage = 'List Services, Scheduled Tasks or Application Pools run by Non System Accounts (LOCALSYSTEM / LOCALSERVICE / NETWOKSERVICE / etc.)')]
        [Alias('Implicit','NonDefault','NSA')]
        [switch] $NonSystemAccounts,

        [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {

        switch ($PsCmdlet.ParameterSetName) {

            'Explicit' {
                $ServiceFilter = "StartName LIKE '$($UserAccount.Replace('\','\\').Replace('*','%'))'"
                $TaskFilter = { $_.'Run As User' -like $UserAccount }
                $IIS6Filter = "WAMUserName LIKE '$($UserAccount.Replace('\','\\').Replace('*','%'))'"
                $IIS7Filter = "ProcessModel.UserName LIKE '$($UserAccount.Replace('\','\\').Replace('*','%'))'"
                break
                }

            'Implicit' {
                $ServiceFilter = "(NOT StartName LIKE '%LocalSystem') AND (NOT StartName LIKE '%LocalService') AND (NOT StartName LIKE '%NetworkService') AND (NOT StartName LIKE 'NT AUTHORITY%')"
                $TaskSystemAccounts = 'INTERACTIVE', 'SYSTEM', 'NETWORK SERVICE', 'LOCAL SERVICE', 'Run As User', 'Authenticated Users', 'Users', 'Administrators', 'Everyone', ''
                $TaskFilter = { $TaskSystemAccounts -notcontains $_.'Run As User' }
                $IIS6Filter = 'AppPoolIdentityType = 3'
                $IIS7Filter = 'ProcessModel.IdentityType = 3'
                break
                }
            }

            Write-Verbose "Services filter = $ServiceFilter"
            Write-Verbose "Tasks filter = `$_.'Run As User' -like $UserAccount"
            Write-Verbose "MicrosoftIISv2 filter = $IIS6Filter"
            Write-Verbose "WebAdministration filter = $IIS7Filter"

            $IsCredSpecified = ($Credential -and ($Credential -ne ([System.Management.Automation.PSCredential]::Empty)))

            function Get-xWmiObject {
                param(
                    [string] $ComputerName,
                    [string] $Namespace = 'root\cimv2',
                    [string] $Class,
                    [string] $Filter,
                    [int] $Timeout = 5
                ) 

                try {
                    $ConnectionOptions = New-Object System.Management.ConnectionOptions 
                    $EnumerationOptions = New-Object System.Management.EnumerationOptions
                    $ConnectionOptions.Authentication = 'PacketPrivacy'

                    $timeoutseconds = New-TimeSpan -Seconds $Timeout 
                    $EnumerationOptions.set_timeout($timeoutseconds)

                    $assembledpath = "\\" + $ComputerName + "\" + $Namespace 
 
                    $Scope = New-Object System.Management.ManagementScope $assembledpath, $ConnectionOptions 
                    $Scope.Connect()

                    $querystring = "SELECT * FROM " + $class 
                    if ($Filter) { $querystring += ' WHERE ' + $Filter}

                    $query = New-Object System.Management.ObjectQuery $querystring 
                    $searcher = New-Object System.Management.ManagementObjectSearcher 
                    $searcher.set_options($EnumerationOptions) 
                    $searcher.Query = $querystring 
                    $searcher.Scope = $Scope

                    return $searcher.get()
                }
                catch {
                    return $null
                }
            } 
	}

    process {

            foreach($Computer in $ComputerName) {

				if ($Computer -eq '.') { $Computer = $ENV:COMPUTERNAME }
                Write-Verbose 'Building the services parameters hashtable'
                $ParamServices = @{
                    Namespace = 'root\cimv2'
                    Class = 'Win32_Service'
                    Filter = $ServiceFilter
                    ErrorAction = 'SilentlyContinue'
                    ComputerName = $Computer
                }

                if ($IsCredSpecified) { $ParamServices.Add('Credential',$Credential) }

                Write-Verbose 'Building the scheduled tasks credentials parameters'
                $sCreds = $null
                if ($IsCredSpecified -ne $false) {
                    $User = $Credential.UserName
                    $Password = $Credential.GetNetworkCredential().Password
                    $sCreds = '/U {0} /P {1} ' -f $User, $Password
                }

                Write-Verbose 'Building the IIS6 parameters hashtable'
                $ParamIIS6 = @{
                    Namespace = 'root\MicrosoftIISv2'
                    Class = 'IIsApplicationPoolSetting'
                    Filter = $IIS6Filter
                    ErrorAction = 'Stop'
                    ComputerName = $Computer
                    Authentication = 'PacketPrivacy'
                }
                if ($IsCredSpecified) { $ParamIIS6.Add('Credential',$Credential) }

                Write-Verbose 'Building the IIS7 parameters hashtable'
                $ParamIIS7 = @{
                    Namespace = 'root\WebAdministration'
                    Class = 'ApplicationPool'
                    Filter = $IIS7Filter
                    ErrorAction = 'Stop'
                    ComputerName = $Computer
                    Authentication = 'PacketPrivacy'
                }

                if ($IsCredSpecified) { $ParamIIS7.Add('Credential',$Credential) }

                $LocalMachineAliases = $ENV:COMPUTERNAME,'localhost','127.0.0.1','::1'
                if ($LocalMachineAliases -contains $Computer -and $IsCredSpecified) {
                    Write-Warning "User credentials cannot be used for local connections. Ignoring credentials for all $Computer connections."
                    $ParamServices.Remove('Credential')
                    $sCreds = $null
                    $ParamIIS6.Remove('Credential')
                    $ParamIIS7.Remove('Credential')
                }

                Write-Verbose "Checking $Computer's availability"
                if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {

                    try {
                        Write-Verbose "Checking for Services on $Computer"
                        Get-xWmiObject @ParamServices | ForEach-Object {
                            New-Object -TypeName PSObject -Property @{
                                ComputerName = $Computer
                                Type = 'Service'
                                Name = $_.DisplayName
                                Account = $_.StartName
                            } | Select-Object ComputerName, Type, Name, Account
                        }
                    }
                    catch {
                        Write-Error $_
                    }

                    try {
                        Write-Verbose "Checking for Scheduled Tasks on $Computer"
                        Invoke-Expression "SCHTASKS /QUERY /S $Computer $sCreds /FO CSV /V" -ErrorAction Stop | ConvertFrom-CSV | Where-Object $TaskFilter | ForEach-Object {
                            New-Object -TypeName PSObject -Property @{
                                ComputerName = $Computer
                                Type = 'Task'
                                Name = $_.TaskName
                                Account = $_.'Run As User'
                            } | Select-Object ComputerName, Type, Name, Account
                        }
                    }
                    catch {
                        Write-Error 'Error checking Scheduled Tasks configuration'
                    }
 
                    try {
                        Write-Verbose "Checking for Application Pools on $Computer (using the MicrosoftIISv2 WMI namespace)"
						if ($AppPools = Get-xWmiObject @ParamIIS6) {
							$AppPools | ForEach-Object {
								New-Object -TypeName PSObject -Property @{
									ComputerName = $Computer
									Type = 'ApplicationPool'
									Name = ($_.Name -replace 'W3SVC/APPPOOLS/')
									Account = $_.WAMUserName
								} | Select-Object ComputerName, Type, Name, Account
							}
						}
                        else {
							Write-Verbose "Checking for Application Pools on $Computer (using the WebAdministration WMI namespace)"
							if($AppPools = Get-xWmiObject @ParamIIS7) {
								$AppPools | ForEach-Object {
									New-Object -TypeName PSObject -Property @{
										ComputerName = $Computer
										Type = 'ApplicationPool'
										Name = ($_.Name -replace 'W3SVC/APPPOOLS/')
										Account = $_.ProcessModel.UserName
									} | Select-Object ComputerName, Type, Name, Account 
								}
							}
						}
					}
					catch [System.UnauthorizedAccessException] { Write-Warning "Access denied on $Computer. cannot check Application Pools configuration. Please run elevated, or use credentials with administrative permissions" } 
					catch { Write-Verbose 'Cannot check Application Pools. NameSpaces MicrosoftIISv2 and WebAdministration do not exist or could not be contacted' } 
				}
				else { Write-Warning "Cannot connect to $Computer" }
			}
		}

<# 
	Name	: Get-ServiceAccountUsage 
	Blog	: http://blogs.technet.com/b/isrpfeplat/ 
     
	Disclaimer: 
	Microsoft provides programming examples for illustration only, without warranty either expressed or implied, including, but not limited to, the implied warranties of merchantability and/or fitness for a particular purpose. 
	This article assumes that you are familiar with the programming language being demonstrated and the tools used to create and debug procedures.  
	Microsoft support professionals can help explain the functionality of a particular procedure, but they will not modify these examples to provide added functionality or construct procedures to meet your specific needs. 
	If you have limited programming experience, you may want to contact a Microsoft Certified Solution Provider or the Microsoft fee-based consulting line at (800) 936-5200. 
     
.SYNOPSIS 
	Get a list of Windows Services, Scheduled Tasks and Application Pools where a specific user account is used, or not using any of the system accounts, on a given computer. 
 
.PARAMETER ComputerName 
	Specifies the name of a (remote) computer, or array of computer names. default is the local computer ($ENV:COMPUTERNAME) 
 
.PARAMETER UserAccount 
	Use this parameter to get the Windows Services, Scheduled Tasks or Application Pools being run by the specified account 
 
.PARAMETER NonSystemAccounts 
	Use this switch to get all Windows Services, Scheduled Tasks or Application Pools being run by NON system accounts 
 
.PARAMETER Credential 
	Use this parameter to specify an account that has permission to perform the queries. The default is the current user. 
 
.DESCRIPTION 
	Get a list of Windows Services, Scheduled Tasks and Application Pools where a specific user account is used, 
	or Windows Services, Scheduled Tasks and Application Pools being run by NON system accounts. 
 
	Requirements  
		1. Administrative permissions on the target computers 
		2. SCHTASKS.exe from Windows 2003 or above (for the usage of the /S parameter). 
		3. Queries the remote MicrosoftIISv2 or WebAdministration WMI NameSpaces for the Application Pools processModel configuration. 
 
.EXAMPLE 
	Get-ServiceAccountUsage -ComputerName '204.226.23.148' -UserAccount 'myDomain\myServiceAccount' 
	Gets all the Windows Services, Scheduled Tasks or Application Pools on the 'myRemoteMachine' computer, that are using the 'myDomain\myServiceAccount' identity 
 
.EXAMPLE 
	Get-ServiceAccountUsage -NonSystemAccounts 
	Gets all the Windows Services, Scheduled Tasks or Application Pools on the local machine, that are using any NON system account (e.g. LOCALSYSTEM / LOCALSERVICE / NETWOKSERVICE / ApplicationPoolIdentity) 
 
.EXAMPLE 
	Get-ServiceAccountUsage -UserAccount 'myDomain\*' 
	Gets all the Windows Services, Scheduled Tasks or Application Pools on the local machine, that are using any user account from the 'myDomain' domain 
 
.EXAMPLE 
	Get-ServiceAccountUsage -UserAccount '*NetworkService' 
	Gets all the Windows Services, Scheduled Tasks or Application Pools on the local machine, that are using the NetworkService identity 
 
.EXAMPLE 
	$arrComputersList | Get-ServiceAccountUsage -UserAccount 'myDomain\myServiceAccount' 
	Gets all the Windows Services, Scheduled Tasks or Application Pools from an array of computers, that are using the 'myDomain\myServiceAccount' identity 
 
.EXAMPLE 
	$arrComputersList | Get-ServiceAccountUsage -NonSystemAccounts -Credential (Get-Credential) 
	Gets all the Windows Services, Scheduled Tasks or Application Pools from an array of computers, that are using any NON system account (e.g. LOCALSYSTEM / LOCALSERVICE / NETWOKSERVICE / ApplicationPoolIdentity) 
	The connection to the remote computers will be done with the specified credentials. 
 
.LINK 
    Israel Platforms PFE Team blog: 
    http://blogs.technet.com/b/isrpfeplat/ 
#> 
}