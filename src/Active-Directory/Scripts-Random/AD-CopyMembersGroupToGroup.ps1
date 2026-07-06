# Purpose: AD-CopyMembersGroupToGroup — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

#Write-Host "Red on white text." -ForegroundColor red -BackgroundColor white
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '**ENSURE RELEVANT PERMISSIONS HAVE BEEN SOUGHT BEFORE PROCEEDING**' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Read-Host -Prompt "Press ENTER to continue..."

$credentials = Get-Credential -Message 'Enter ADMIN/PRIV credentials.'

$sourceGroup = Read-Host -Prompt 'Enter name of group to copy members from'
$destinationGroup = Read-Host -Prompt 'Enter name of group to copy members to'

$users = Get-ADGroupMember -Identity $sourceGroup -Credential $credentials

$startCount = (Get-ADGroupMember -Identity $destinationGroup).Count
$newMembersCount = $users.Count

foreach ($user in $users) {
    Add-ADGroupMember -Identity $destinationGroup -Members $user.distinguishedname -Credential $credentials
}

$endCount = (Get-ADGroupMember -Identity $destinationGroup).Count

$newCount = $endCount - $startCount

Write-Host - "$newMembersCount users have been added to group $destinationGroup" -ForegroundColor White -BackgroundColor Green
Write-Host - "$newCount NET TOTAL + $destinationGroup" -ForegroundColor White -BackgroundColor Green
