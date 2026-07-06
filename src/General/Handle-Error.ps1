# Purpose: Handle-Error — General-purpose PowerShell utilities.
# On Error Resume Next
Write-Host "starting",""
#3..-3 |
-1,-2,3,5,0,"five" |
ForEach-Object `
{
	# Capture the current value of $ErrorActionPreference
$StdErrPref = $ErrorActionPreference
# Change the value of $ErrorActionPreference so that
#    the script doesnt generate and error
$ErrorActionPreference = "SilentlyContinue"

# If you uncomment the following line, you can handle a
#    specific error
trap [DivideByZeroException] {  "undefined"; continue}

# Or uncomment the following line tohandle any error
trap [Exception] { "error"; continue}

1 / $_
$ErrorActionPreference = $StdErrPref
}
Write-Host "","finished"

