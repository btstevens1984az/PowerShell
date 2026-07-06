# Purpose: GetDirects — General-purpose PowerShell utilities.
function Get-Directs
{
    param([parameter(Mandatory=$true,ValueFromPipeline=$True,Position = 0,HelpMessage="Enter a user identity")]$user)
    process
    {
        $adUser = Get-ADUser $user
        $directs = get-aduser -Filter {manager -eq $ADuser.DistinguishedName} -Properties manager
        $directs | ForEach-Object{$_.DistinguishedName}
        if ($directs)
        {
            $directs | Get-Directs
        }
    }
}
Get-Directs user51