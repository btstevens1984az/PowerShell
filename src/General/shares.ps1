# Purpose: shares — General-purpose PowerShell utilities.
# powershell 2
# kerry kreitinger
# get SHARE info from pcs in a list


$comp = get-content computers.txt

$comp | foreach {
 $os = get-wmiobject -class win32_share -computername $_ | out-file shareinfo.txt
{ add-content $_ -path shares.txt }
}

