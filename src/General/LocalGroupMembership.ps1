# Purpose: LocalGroupMembership — General-purpose PowerShell utilities.
    # Try to find a group by its name.
    function EnumerateMembers
    {
    param
    (
        [System.DirectoryServices.AccountManagement.GroupPrincipal] $Group
    )

    Set-StrictMode -Version Latest

    # Create the output array.
    $members = @();
    foreach($member in $group.Members)
    {
        if($member.ContextType -eq "Domain")
        {
            # Select only the first part of the full domain name.
            [String]$domainName = $member.Context.Name;
            $domainName = $domainName.Substring(0, $domainName.IndexOf('.'));

            if($member.StructuralObjectClass -eq "computer")
            {
                $members += ($domainName+'\'+$member.Name);
            }
            else
            {
                $members += ($domainName+'\'+$member.SamAccountName);
            }
        }
        else
        {
            $members += $member.Name;
        }
    }

    return $members;
}
    add-type -AssemblyName System.DirectoryServices.AccountManagement
    
    $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList ([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    $group = $null

    $GroupName = Read-Host "enter group name"
    $group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($principalContext, $GroupName);

    # The group is found. Enumerate all group members.
    $members = [String[]]@(EnumerateMembers -Group $group)
    $members
