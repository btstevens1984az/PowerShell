# Purpose: RecursiveWMINameSpaceListing — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 12/27/2008
#
# KEYWORDS: recurse, wmi, schema, namespace
# Foreach-object, Get-WmiObject, function
# COMMENTS: This script does a recursive listing of
# all the WMI namespaces on a computer. It will work
# remotely
#
#
# ------------------------------------------------------------------------

Function Get-WmiNameSpace($namespace, $computer)
{
 Get-WmiObject -class __NameSpace -computer $computer `
 -namespace $namespace -ErrorAction "SilentlyContinue" |
 Foreach-Object `
 -Process `
   { 
     $subns = Join-Path -Path $_.__namespace -ChildPath $_.name
     $subns
     $script:i ++
     Get-WmiNameSpace -namespace $subNS -computer $computer
   } 
} #end Get-WmiNameSpace

# *** Entry Point ***

$script:i = 0
$namespace = "root"
$computer = "LocalHost"
"Obtaining WMI Namespaces from $computer ..."
Get-WmiNameSpace -namespace $namespace -computer $computer
"There are $script:i namespaces on $computer"