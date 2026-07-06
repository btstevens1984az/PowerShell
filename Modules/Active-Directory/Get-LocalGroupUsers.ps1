# Purpose: Get-LocalGroupUsers — Active Directory user, group, and domain administration.
Function Get-LocalGroupUsers {
<#
This script was written to combat the issue with Get-LocalGroupMember enumerating users
in a group that has a broken sid.
Usage: .\Get-LocalGroupUsers.ps1 -GroupName sftp*
#>

[CmdLetBinding()]
Param(

    [Parameter(Mandatory = $True, Position = 1)]
    [string]$GroupName

)

$LocalGroups = Get-LocalGroup | Where-Object { $_.Name -like $GroupName }

foreach ($LocalGroup in $LocalGroups) {

    # Attempt to enumerate user for a local group
    # If we try and fail we'll catch that error and let the user know
    try {

        Write-Host "`n$LocalGroup Members:`n"
        $Users = Get-LocalGroupMember $LocalGroup -ErrorAction Stop | Select-Object Name
        # I had to pipe out $Users to a string because write-host doesn't do formatting
        Write-Host ($Users.Name | Out-String)
        Write-Host "`n"

    }
    catch { Write-Host "Unable to enumerate users for: $LocalGroup`nPlease verify group doesn't have a broken sid." }

}
}