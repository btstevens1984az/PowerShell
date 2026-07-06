# Purpose: Get-WmiProviders — PowerShell automation.
# ------------------------------------------------------------------------
# DATE: 12/27/2008
#
# KEYWORDS: function, wmi, Get-WmiObject, Select-Object
# Sort-Object
# COMMENTS: This script lists the wmi providers in a particular
# namespace. By default it lists providers in root\cimv2 namespace
# which is the default, on the local comptuer (also the default).
# This script works remotely by supplying a value for -computer
#
# Get-Help Get-WmiProviders will display signature of function
# example: Get-WmiProviders -namespace "root\default" -computer "mred1"
# ------------------------------------------------------------------------

Function Get-WmiProviders(
                                                $namespace="root\cimv2",
                                                $computer="localhost"
                                               )
{
 Get-WmiObject -class __Provider -namespace $namespace `
 -computername $computer |
 Sort-Object -property Name |
 Select-Object -property Name
} #end Get-WmiProviders

Get-WmiProviders

