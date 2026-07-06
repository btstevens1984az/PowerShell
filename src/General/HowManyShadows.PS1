# Purpose: HowManyShadows — General-purpose PowerShell utilities.
# pwershell2
# kerry
# findout if shadow copies are on server

$class=[WMICLASS]"root\cimv2:win32_shadowcopy"

# Count copies setup
$shadow = get-wmiobject win32_shadowcopy
"There are {0} shadow copies on this sytem" -f $shadow.count