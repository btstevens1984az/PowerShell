# Purpose: check — General-purpose PowerShell utilities.
# powershell 2
# kerry kreitinger
# get info from pcs in a list


$comp = get-content computers.txt

#  computers that don't have 64-bit OS installed

$comp | foreach {
 $os = get-wmiobject -class win32_operatingsystem -computername $_
 $OSArch = $os.osarchitecture
 if (!($OSArch -match "32-bit")) { add-content $_ -path next.txt }
}

#  computers without 64-bit OS can have 64-bit OS
$comp2 = get-content next.txt
$comp2 | foreach {
 $ps = get-wmiobject -class win32_processor -computername $_
 $SystemType = $ps.description
 if ($SystemType -like "*x64*") { add-content $_ -path final.txt }
}

