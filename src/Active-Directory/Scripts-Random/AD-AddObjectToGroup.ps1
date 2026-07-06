# Purpose: AD-AddObjectToGroup — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

$computers = Get-Content c:\temp\computers.csv

foreach ($computer in $computers) { 
    $compAdd = Get-ADComputer $computer
    Add-ADGroupMember -ID GBR-SD-SCCM-CAS002E3-MA -Members $compAdd -PassThru

}

#----------------------------------------------------------------------------------------#


Import-Module ActiveDirectory

$users = Get-Content c:\temp\visionusers.txt
$destinationGroup = Read-Host "Group Name"

$startCount = (Get-ADGroupMember -Identity $destinationGroup).Count
$newMembersCount = $users.Count

Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '* ENSURE RELEVANT PERMISSIONS HAVE BEEN SOUGHT BEFORE PROCEEDING *' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Read-Host -Prompt "Press ENTER to continue..."

foreach ($user in $users) { 
    $userAdd = Get-ADUser $user
    Add-ADGroupMember -ID $destinationGroup -Members $userAdd 

}

$endCount = (Get-ADGroupMember -Identity $destinationGroup).Count

$newCount = $endCount - $startCount

Write-Host - "$newMembersCount users have been added to group $destinationGroup" -ForegroundColor White -BackgroundColor Green
Write-Host - "$newCount Net total + $destinationGroup" -ForegroundColor White -BackgroundColor Green

#GBR-UK-HUB-U-Vision_Users