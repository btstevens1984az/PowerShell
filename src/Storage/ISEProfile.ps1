# Purpose: ISEProfile — Storage management and disk operations.
#IF ($PSVersionTable.PSVersion.Major -ge 5)
#{
#    Import-Module PSDesiredStateConfiguration
#
#}
Import-Module Modules:\ISEScriptingGeek
#Import-Module Modules:\ISE-Comments
Import-Module Modules:\ISERegex
. scripts:\Functions\CloseAllISEFiles.ps1
#cd C:\temp
cls