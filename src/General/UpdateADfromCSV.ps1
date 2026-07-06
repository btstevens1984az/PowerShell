# Purpose: UpdateADfromCSV — General-purpose PowerShell utilities.
$users = Import-Csv C:\temp\UpdateAD\UsersUpdate.csv
$results = foreach ($user in $users)
{
    $Adfilter = "Surname -eq '$($user.LastName)' -and samaccountname -like '*$($user.id)'"  
    $ADuser = Get-ADUser -filter $Adfilter -Properties employeeID,employeeNumber
    if ($ADuser.count -gt 1)
    {
        Write-Error "More than 1 user returned with: $Adfilter"
        $user.status = "error: more than on match"
    }
    elseif ($aduser.EmployeeID -eq $user.ID)
    {
        $user.status = "success"
        $user.dn = $ADuser.DistinguishedName
        $user.ID = $ADuser.EmployeeID
    }
    else
    {
        $error.Clear()
        $ADuser | Set-ADUser -EmployeeID $user.ID 
        If (-not $error)
        {
                $user.status = "success"
                $user.dn = $ADuser.DistinguishedName
        }
    }
    $user
}

$results | Export-Csv C:\temp\results.csv -NoTypeInformation
