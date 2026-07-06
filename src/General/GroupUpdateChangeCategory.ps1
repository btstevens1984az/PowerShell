# Purpose: GroupUpdateChangeCategory — General-purpose PowerShell utilities.
Function Update-MyGroups
{
    [cmdletbinding()]
    param($GroupName,$memberstoRemove,$memberstoAdd)

    $group = Get-ADGroup $groupName
    Write-Verbose "Setting $groupname to a distribution group"
    $group = $group | Set-ADGroup -GroupCategory Distribution -PassThru -Verbose
    #Start-Sleep -Seconds 5
    Write-verbose "Removing Members: $($memberstoRemove.name -join ';')"
    $group | Remove-ADGroupMember -Members $memberstoRemove  -Verbose -Confirm:$false
    Write-verbose "Adding Members: $($memberstoAdd.name -join ';')"
    $group | Add-ADGroupMember -Members $memberstoAdd -Verbose -Confirm:$false
    #Start-Sleep -Seconds 100
    Write-Verbose "Setting $groupname back to a security group"
    $group = $group | Set-ADGroup -GroupCategory Security -Verbose -PassThru |Get-ADGroup -Properties Members
    $group | Add-Member -MemberType NoteProperty -Name RemovedMembers -Value $memberstoRemove -Force
    $group | Add-Member -MemberType NoteProperty -Name AddedMembers -Value $memberstoAdd -Force
    $group
}

$group = Get-ADGroup class123
$memberstoRemove = $group  | Get-ADGroupMember | select -First 2
$memberstoAdd = get-aduser -Filter "name -like 'john*'"
$results = Update-MyGroups -GroupName class123 -memberstoRemove $memberstoRemove -memberstoAdd $memberstoAdd -Verbose