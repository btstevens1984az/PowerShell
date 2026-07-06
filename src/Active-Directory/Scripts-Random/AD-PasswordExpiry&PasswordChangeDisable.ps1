# Purpose: AD-PasswordExpiry&PasswordChangeDisable — Active Directory user, group, and domain administration.
$users = get-content c:\temp\users.txt

foreach ($user in $users) { 
    Get-ADUser $user | Set-ADUser -PasswordNeverExpires $true -CannotChangePassword $true }