# Purpose: ADcmdletWalkthrough — General-purpose PowerShell utilities.
Import-Module ActiveDirectory
$domainInfo = Get-ADDomain
$DC = (Get-addomaincontroller).HostName
$DomainFQDN = $domainInfo.DNSRoot
$DomainDN =  $domainInfo.DistinguishedName
$DomainNetbios = $domainInfo.NetBIOSName
$GC = (Get-ADDomainController -Service 2,6 -Discover).Hostname  #Will also have ADWS(6)
$DefaultPassword = "P@ssword1"
$testUserPrefix = "TestDel"
$OuRDN = "OU=Testing"
$Department = "PFE"
$NumTestUsers = 10000
$testGroup = $testuserprefix+"Group"
$StaleOuRDN = "ou=stalecomputers"


###########Create Connection#############
Get-Aduser -filter *
Get-ADUser –filter * -server "$($GC):3268" 		#Get-ADUser –filter * -server ("$GC"+":3268")
$cred = Get-Credential
New-PSDrive -PSProvider ActiveDirectory -Name $DomainNetbios -Root "" –Server $DomainFQDN  `
–credential $cred
Set-location "$($DomainNetbios):"

#############Create a User################
$pass = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force
 New-ADUser -SamAccountName $testUserPrefix -GivenName $testUserPrefix -Surname $testUserPrefix `
-Name $testUserPrefix -Department $Department -UserPrincipalName "$testUserPrefix@$DomainFQDN" `
-AccountPassword $pass -Path "$OuRDN,$DomainDN"  -passthru | Enable-ADAccount

##########Create some Test users##########
 1..$NumTestUsers | %{New-ADUser -SamAccountName "$TestuserPrefix$_" -GivenName "$TestuserPrefix$_" -Surname "$TestuserPrefix$_" `
-Name "$TestuserPrefix$_" -Department $Department -UserPrincipalName "$TestuserPrefix$_@$DomainFQDN" `
-AccountPassword $pass -Path "$OuRDN,$DomainDN" -description "Test User:$(Get-date)" -passthru | Enable-ADAccount -passthru}

##########Get a single object#############
get-aduser -Identity $testUserPrefix #match on SamAccountName
Help about_ActiveDirectory_Identity

###########Searching AD#############
#return all Active Directory users
Get-ADuser –filter *
#return all Universal Security Groups:
Get-ADGroup  -filter {GroupCategory  -eq "Security"  -and GroupScope -eq "Universal"}
#More comparision operator options
Help about_Comparison_Operators

Get-ADUser -filter {mail -like "*"}

#Find Accounts configured for DES:
Get-ADUser -Filter {UserAccountControl -band 0x200000}

#find objects created within the last 24 hours
$OneDayAgo = (Get-date).adddays(-1)
Get-ADObject -filter {whencreated -gt $OneDayAgo}

Get-Help about_ActiveDirectory_Filter


#############Working with Computers#############
$OneYearAgo = (Get-date).AddYears(-1)
Get-ADComputer -Filter {LastLogonTimeStamp -lt $OneYearAgo} | Disable-ADAccount
#You can easily move these accounts as well
Get-ADComputer -Filter {LastLogonTimeStamp -lt $OneYearAgo} | Disable-ADAccount -PassThru |
Move-ADObject -TargetPath "ou=stalecomputers,$DomainDN"


###########Working with Groups##################
$user = Get-ADuser –Identity “Administrator” –Property “memberof”
$group = Get-ADGroup –Identity “Administrators”
if (Get-ADUser -Filter { memberOf -RecursiveMatch $group.DistinguishedName } `
-SearchBase $user.DistinguishedName -SearchScope Base)
{$true}
Else
{$false}

#Create a Group
$newGroup = New-ADGroup -name $testGroup -Path "$OuRDN,$DomainDN" `
-GroupScope "Global" –passthru

#Populate a Group
$Users= Get-ADUser -filter {Department -eq $Department}
Add-ADGroupMember -Identity $newGroup -Members $Users
#Alternatively Add-ADPrincipalGroupMembership can also be used to populate the group using a pipeline.
#$Users | Add-ADPrincipalGroupMembership -MemberOf  $testGroup

#Get Group members including nested
Get-ADGroupMember $testGroup -Recursive

######AD Recycle Bin#########################
#restore all objects deleted within the last 8 hours
#Top level objects need to be restored first so you can loop the following command or simply run it a couple of times
#Get-ADObject -filter {ISDeleted -eq $true -and msDS-LastknownRDN -like "*"} `
#-IncludeDeletedObjects -Properties *,msds-localeffectivedeletiontime | 
#Where-Object{$_.$("msds-localeffectivedeletiontime") -GT ((GET-DATE).ADDhours(-8))} | 
#Restore-Adobject -confirm


###########Group Policy##########
Import-Module GroupPolicy
Get-Command -Module GroupPolicy | Select-Object Name
help Get-GPOReport -examples

#remove PSDrive
cd c:
Remove-PSDrive $DomainNetbios