# Purpose: GetOsVersionFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/14/2008
#
# KEYWORDS: operating system version, .NET framework
# system.environment class, environment class, ref,
# pass by reference
# COMMENTS: This function uses the system.environment
# dot net framework class to detect the version of the 
# operatingsystem. 
#
#
# ------------------------------------------------------------------------

Function Get-OsVersion([ref]$os)
{
 $os.value = [environment]::osversion
}

# *** entry point to script ***

$os = $null
Get-OsVersion([ref]$os)
if($os.version.major -ge 6)
 {
  "Windows Vista or greater detected"
 }
else
{
 "Windows Vista or greater not detected"
 exit
}