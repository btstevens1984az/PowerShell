# Purpose: UpdateStudentGroups — General-purpose PowerShell utilities.
$Changes = import-csv .\StudentChanges.csv
$groups = import-csv .\Groups.csv
$groups
$ImportHash = @{}
$Changes | foreach{
    $ImportHash.($_.adgroup) += ,$_.aduser

}

Foreach ($group in $groups)
{
    $adgroupMembers = Get-ADGroupMember -Identity $group  | Select-Object -ExpandProperty samaccountname
    foreach ($student in $importhash.$group)
    {
        #addstudents not in group
        if ($student -notin $adgroupMembers)
        {
            try{
            $student| Add-ADPrincipalGroupMembership -MemberOf $group -Verbose -Confirm:$false -ErrorAction SilentlyContinue
            }
            catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
            {#student not found
              Write-host "$student not found in Active Directory"
            }
            catch
            {
                Write-Host "expected Error"
                throw $_
            }
        }

    }
    foreach ($student in $adgroupMembers)
    {
        #remove students from group
        if ($student -notin $importhash.$group)
        {
            
            $student| Remove-ADPrincipalGroupMembership -MemberOf $group -Verbose -Confirm:$false
        }
            
    }

}