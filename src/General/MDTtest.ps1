# Purpose: MDTtest — General-purpose PowerShell utilities.
$PW = ConvertTo-SecureString -String "P3vkcsb6" -AsPlainText -Force
$Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "YOURDOMAIN\joindomain2", $PW

$dc=$(get-addomaincontroller -server example.com -credential $Creds).hostname


$mach=get-adcomputer 114.148.18.125 -server $dc -credential $creds

$target=Get-ADOrganizationalunit -LDAPFilter "(name=win7test)" -server $dc -credential $creds
$mach|Move-ADObject -TargetPath $target.DistinguishedName
