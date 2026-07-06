# Purpose: CreateGroupandChangeACL — General-purpose PowerShell utilities.
$adRead = [System.DirectoryServices.ActiveDirectoryRights]::GenericRead
$adWrite = [System.DirectoryServices.ActiveDirectoryRights]::GenericWrite
$adGenericReadWrite= $adRead -bor $adWrite
$domainDN = (Get-ADDomain).DistinguishedName
$TargetOURDN = "OU=SomeOU"
$InputFilePath = ".\sitetextfile.txt"

Get-content $InputFilePath| ForEach-Object {
$ParentGroup = Get-ADGroup “$_ Parent Group”
$ChildGroup = New-adgroup –name “$_ New Group” –path “$TargetOURDN,$domainDN” –groupscope global –groupcategory security -PassThru
Add-ADGroupMember $ParentGroup $childGroup
$parentGroupPrincipal = New-Object System.Security.Principal.SecurityIdentifier $ParentGroup.sid.ToString()
$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $parentGroupPrincipal,$adGenericReadWrite,"Allow"
$acl = Get-Acl "AD:$($childGroup.DistinguishedName)"
$acl.AddAccessRule($ACE)
Set-Acl -AclObject $acl -Path "AD:$($childGroup.DistinguishedName)"

}
