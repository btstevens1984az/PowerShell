# Purpose: Get-Bios — Hardware and software inventory collection.
# ------------------------------------------------------------------------
# DATE: 7/7/2009
#
# KEYWORDS: BIOS, Get-WmiObject
#
# COMMENTS: This script displays the bios information
# from the current computer.
#
#
# ------------------------------------------------------------------------

Get-WmiObject -class Win32_Bios