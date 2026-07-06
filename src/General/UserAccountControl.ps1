# Purpose: UserAccountControl — General-purpose PowerShell utilities.
$user = get-aduser testimportuser2124 -Properties useraccountcontrol

$user.useraccountcontrol -band 65536

$newValue = $user.useraccountcontrol -bxor 65536

$user.useraccountcontrol = $newValue
$user | Set-ADUser -Replace @{useraccountControl =$newValue } -Verbose -PassThru |
 get-aduser -Properties useraccountcontrol