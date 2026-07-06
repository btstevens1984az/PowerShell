# Purpose: PingVistaComputers — Network diagnostics, DNS, DHCP, and connectivity.
# ------------------------------------------------------------------------
# DATE: 5/17/2009
#
# KEYWORDS: validatepattern parameter attribute, 
# test-connection
# COMMENTS: This script uses the validatepattern attribute
# to only ping computers that have the word vista in their name.
#
# Best Practices chapter 12
# ------------------------------------------------------------------------
#requires -version 2.0
Param(
     [ValidatePattern("vista")]
     [alias("CN")]
     $computername
 )

Function New-TestConnection($computername)
{
 Test-connection -computername $computername -buffersize 16 -count 2 
} #end new-testconnection

# *** Entry Point to script
New-TestConnection($computername)

