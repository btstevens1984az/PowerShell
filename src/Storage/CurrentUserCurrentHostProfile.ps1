# Purpose: CurrentUserCurrentHostProfile — Storage management and disk operations.
# -----------------------------------------------------------------------------
# BestPractices Profile
# Ed Wilson, msft, 11/19/2008
#
# profile contains: function, alias, variable, psdrive
# -----------------------------------------------------------------------------

# *** Functions go here ***

Function Set-Profile()
{
 Notepad $profile
 #MrEd function
}

Function Get-MoreHelp()
{
 #.Help Get-MoreHelp Get-Command
 Get-Help $args[0] -Full | 
 more
  #MrEd function
} #end Get-MoreHelp

Function Get-WmiClass([string]$ns, [string]$class)
{
 #.Help Get-WmiClass -ns "root\cimv2" -class "Processor"
 $ns = $args[0]
 $class = $args[1]
 Get-WmiObject -List -Namespace $ns |
 Where-Object { $_.name -match $class }
  #MrEd function
} #end Get-WmiClass


# *** Aliases go here ***

New-Alias -Name mo -Value Measure-Object -Option allscope `
  -Description "MrEd Alias"
New-Alias -name gmh -value Get-MoreHelp -Option allscope `
  -Description "MrEd Alias"
New-Alias -Name gwc -Value Get-WmiClass -Option readonly,allscope `
  -Description "Mred Alias"


# *** Variables go here ***

New-Variable -Name wulog -Value (Join-Path -Path $env:LOCALAPPDATA `
  -ChildPath microsoft\windows\windowsupdate.log -Resolve) `
  -Option readonly -Description "MrEd Alias"
New-Variable -Name docs -Value (Join-Path -Path $home -ChildPath documents) `
  -Option readonly -Description "MrEd Variable"
New-Variable -name wshShell -value (New-Object -ComObject Wscript.Shell) `
  -Option readonly -Description "MrEd Alias"


# *** PSDrives go here ***

New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root `
  -Description "MrEd PSdrive" | out-null

# *** Entry Point here ***
