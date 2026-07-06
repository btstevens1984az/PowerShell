# Purpose: get-users — General-purpose PowerShell utilities.
param(
$name = "",[switch]$help,[string]$domain,[switch]$lastlogon,[switch]$verbose,[object]$customdcs,[switch]$noprogress,[string]$exclude )
$starttime 		= get-date
$verbosefile = "$env:windir\Temp\GU$(($env:username).toupper())-$((get-date).year)$((get-date).month)$((get-date).day)-$((get-date).hour)$((get-date).minute).txt"

if($verbose) { write-host -foregroundcolor green "Verbose : See $verbosefile for more information" }

function GetHelp() {
cls
$HelpText = @"
NAME    : get-users.ps1
VERSION : 1.8
DESCR   : Gets userinformation from the Active Directory
RETUNS  : Objects

PARAMETERS:
-name       The name or pattern you look for
-d          domain
-help       Prints the HelpFile 
-verbose    Verbose output
-lastlogon  if set the lastlogon tag is added. Running down available DCs
-customDCs  specify custom DCs (input = Object)
-noprogress hides progressbar
-exclude    excludes every object with This string in its DN Address

SYNTAX :
`$objs = ./get-users.ps1 -name <name> -d <domain> [-verbose] [-lastlogon -customdcs <OBJECTs> -exclude <string> ]

get-users.ps1 -help

Displays the help topic for the script

"@
	$HelpText
}

function Convert-LargeInteger([object]$LargeInteger){
	$type = $LargeInteger.GetType()
	$highPart = $type.InvokeMember("HighPart","GetProperty",$null,$LargeInteger,$null)
	$lowPart = $type.InvokeMember("LowPart","GetProperty",$null,$LargeInteger,$null)
	$bytes = [System.BitConverter]::GetBytes($highPart)
	$tmp = New-Object System.Byte[] 8
	[Array]::Copy($bytes,0,$tmp,4,4)
	$highPart = [System.BitConverter]::ToInt64($tmp,0)
	$bytes = [System.BitConverter]::GetBytes($lowPart)
	$lowPart = [System.BitConverter]::ToUInt32($bytes,0)
	$lowPart + $highPart
}

function getuserdata {
	$global:objectCount = 0
	$userproperties = @("sAMAccountName","mail","displayname","company","department","homedirectory","homedrive","distinguishedName","legacyExchangeDN","profilepath")
	$objects = @()
	if(!$customdcs) { 
		$DCs = (([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Domains | ? {$_.Name -eq $domain}).DomainControllers
		if(!$DCs) { Write-Host -foregroundcolor RED "Error : The domain cannot be found"
		return "The Domain cannot be found"
		}
		$DomainDN = (([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Domains | ? {$_.Name -eq $domain}).GetDirectoryEntry().distinguishedName
		
		} else { $DCs = $customdcs } 
		$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]"LDAP://$DomainDN")
		$Searcher.filter = "(&(objectCategory=person)(objectClass=user)(sAMAccountName= $name))"
		$Searcher.PageSize = 100000
		if($verbose) { $VerbosePreference = 'Continue' }
		$users = $Searcher.Findall()
		$ii = 100 / $($users.count)
		$i = 100 / $($users.count)
		foreach( $user in $users) 
		{
			if($verbose) { add-content -path "$verbosefile" -value "$($user.path)" }
			$userDN = [ADSI]$user.path 
			$UserObject = New-Object PsObject
			foreach ($userproperty in $userproperties) 
			{
				$UserObject | Add-Member -memberType NoteProperty $userproperty -Value "$($userDN.$userproperty)"
			}
			$arrSID = $userDN.objectSid.Value
			$DN = $UserObject.distinguishedName
			$SID = New-Object System.Security.Principal.SecurityIdentifier ($arrSID,0)
			$groupSID = $SID.AccountDomainSid.Value + "-" + $userDN.primaryGroupID.ToString()
			$group = [adsi]("LDAP://<SID=$groupSID>")
			$UserObject | Add-Member -memberType NoteProperty "primaryGroup" -Value "$($group.name)" 
			if($lastlogon) 
			{
				$LLObjects = @()
				foreach($DC in $DCs) 
				{
					$UserDC = ([ADSI]"LDAP://$($DC.Name)/$DN").LastLogon[0]
					if($UserDC) 
					{
						$UserDC2 = Convert-LargeInteger $UserDC
						if($verbose) { add-content -path "$verbosefile" -value $([datetime]::fromfiletime($UserDC2)) 
						}
						$LLObjects += $UserDC2
					}
				} 
				if($LLObjects.count -eq 0) { # What if object is empty

					$UserObject | Add-Member -memberType NoteProperty "LastLogon" -Value "No Last Logon found"

				} elseif ($LLObjects.count -eq 1) # What if 1 object is found
				{
					if($LLObjects[0] -eq 0) # What if object this object returns zero
					{
						$UserObject | Add-Member -memberType NoteProperty "LastLogon" -Value "No Last Logon found" 

					} else 
					{
						$UserLastLogon = [datetime]::fromfiletime($LLObjects[0]) 
						$UserObject | Add-Member -memberType NoteProperty "LastLogon" -Value "$UserLastLogon"
					}
				}
				else {
					$UserLastLogon = [datetime]::fromfiletime(($LLObjects | sort -descending)[0])

					if( (($LLObjects | sort -descending)[0]) -eq 0) 
					{
						$UserObject | Add-Member -memberType NoteProperty "LastLogon" -Value "No Last Logon found" 
					} else 
					{
						$UserObject | Add-Member -memberType NoteProperty "LastLogon" -Value "$UserLastLogon" }
				}
			}
			if(!$noprogress) {write-progress -id 1 -activity "Enumerating $($users.count) user(s)" -status "$($user.path)" -percentComplete ($i); }
			$i = $i + $ii

			if(!$exclude) 
			{
				$objects += $UserObject
			}
			else
			{
				if($($user.path) -like "*$exclude*" ) { } else { $objects += $UserObject }
			}
		}

		$test = $objects
		$global:objectCount = $test.count
		return $objects
	}
	
	if($help -or ! $name) { gethelp } else {getuserdata
	
		$totaltime = ((get-date) - $starttime)
		if($verbose) 
			{ 
			add-content -path "$verbosefile" -value "Script finished -->[ $([float]$totaltime.minutes) minutes & $([float]$totaltime.seconds) seconds. ]" 
			write-host "Script finished -->[ $([float]$totaltime.minutes) minutes & $([float]$totaltime.seconds) seconds. ]"
			}
	}