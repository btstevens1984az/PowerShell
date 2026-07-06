# Purpose: Export Office365 User Roles to CSV — Microsoft 365 tenant administration.
Connect-MsolService

$AllUserRoles = @()

$Users = Get-MsolUser -All
foreach($user in $Users)
{
    $UserRoles = Get-MsolUserRole -UserPrincipalName $User.UserPrincipalName
    foreach($role in $UserRoles)
    {
        $aRole = New-Object PSObject
        $UserName = $User.UserPrincipalName
        $RoleName = $role.Name.ToString()

        Add-Member -input $aRole noteproperty ‘UserName’ $UserName
        Add-Member -input $aRole noteproperty ‘RoleName’ $RoleName
        $AllUserRoles += $aRole
    }
}

$AllUserRoles | export-csv -Path C:\temp\O365UserRoles.csv -NoTypeInformation -Force