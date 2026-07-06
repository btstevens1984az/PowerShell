# Purpose: Get-EnabledBreakpointsFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE:
#
# KEYWORDS: Get-PSBreakPoint
#
# COMMENTS: This function returns enabled breakpoints
#
# Windows PowerShell Best Practices
# #Requires -Version 2.0
# ------------------------------------------------------------------------

Function Get-EnabledBreakpoints
{
  Get-PSBreakpoint | 
  Format-Table -Property id, script, command, variable, enabled -AutoSize
}

# *** Entry Point to Script ***

Get-EnabledBreakpoints
