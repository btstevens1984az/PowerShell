# Purpose: Provision-Folders — Storage management and disk operations.
CD c:\
New-Item Public -Type Directory
CD Public
Get-Content c:\names.txt | `
ForEach-Object `
{
	New-Item $_ -Type Directory
	$acl = Get-Acl $_
	$ar = New-Object `
     system.security.accesscontrol.filesystemaccessrule`
     ($_,"FullControl","Allow")
	$acl.SetAccessRule($ar)
	Set-Acl $_ $acl
}
