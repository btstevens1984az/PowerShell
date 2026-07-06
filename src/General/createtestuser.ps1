# Purpose: createtestuser — General-purpose PowerShell utilities.
# Description: PowerShell script to bulk create users in a ZZZ test ou
#  OU will also be created if it sdoesn't exist
#########################################################

### Variables

# Get the logged-on user's domain in DN form
$mydom = (get-addomain).distinguishedname

# Specify the OU we want to create the users in
$ouName = "ZZZUser Accounts"

# Build the full DN of the target OU
$oudn = "OU=$ouname,$mydom"

# Specify the number of users to create
$userCount = 10

# Specify the description attribute for the users
$datetime = get-date -format G
$desc = "Test user created $datetime"

### Start creating

# Check if the target OU exists. If not, create it.
$OU = get-adorganizationalunit -Filter { name -eq $ouname }
if($OU -eq $null)
{New-ADOrganizationalUnit -Name $OUName -Path $mydom}
else
{write-host "The OU" $ou "already exists - this is good..."}

# Create users

$i = 1
While ($i -le $usercount)
{
$Uname = "ZZZUser" + $i
$UDdname = "ZZZTest ZZZUser" + $i
New-ADUser �Name $Uname �SamAccountName $Uname �DisplayName $UDdname `
-Path $oudn �Enabled $true �ChangePasswordAtLogon $false -description $desc `
-AccountPassword (ConvertTo-SecureString "P@ssword" -AsPlainText -force) -PassThru
$i = $i + 1
}

#End