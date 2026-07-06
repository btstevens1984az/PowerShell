# Purpose: regPerm — General-purpose PowerShell utilities.
$Regpath = "HKCU:\software\test"
$user = "Testpfe87" #contoso\user if in another domain
$RegistryRights= "FullControl"
$Inheritance = "ContainerInherit"
$Propagation = "none"
$AccessControlType = "allow"
$acl = Get-Acl $Regpath
$ace = new-object System.security.accesscontrol.registryAccessRule ($user,$RegistryRights,$Inheritance,$Propagation,$AccessControlType)
$acl.SetAccessRule($ace)
$acl | Set-Acl $Regpath