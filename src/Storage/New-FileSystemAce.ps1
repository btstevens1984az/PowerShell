# Purpose: New-FileSystemAce — Storage management and disk operations.
function New-Acl {

param($user,$context,$rights,$type)

$id = new-object System.Security.Principal.NTAccount("$context\$user")
$iFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$pFlags = [System.Security.AccessControl.PropagationFlags]"None"

$acl = new-object System.Security.AccessControl.DirectorySecurity
$ace = New-Object System.Security.AccessControl.FileSystemAccessRule($id,$rights,$iFlags,$pFlags,$type)

$acl.AddAccessRule($ace)
$acl.SetOwner($id)
}
