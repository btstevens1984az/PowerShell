# Purpose: Is-Online — Reusable PowerShell function libraries.
# Function Name: Is-Online?
# Test if a computer is online (quick ping replacement)
# -------------------------------------------
function Is-Online? {
    param($computername)
    return (test-connection $computername -count 1 -quiet)
}