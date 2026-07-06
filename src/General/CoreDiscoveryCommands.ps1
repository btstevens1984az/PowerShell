# Purpose: CoreDiscoveryCommands — General-purpose PowerShell utilities.
#scripts\SimpleDemos\CoreDiscoveryCommands.ps1

#Step 1 - install powershell tools for product you want to automate
<#For Powershell Version 2, you need to import the module or snapin 
before you can discover the commands:
Import-module / Get-module -listavailable
Older tools : Add-Pssnapin / Get-Pssnapin -registered
Newer tools: Find-module / Install-Module
#>

#Core Discovery Commands
#Step 2 - Command Discovery
Get-command
Show-Command #v3

#Step 3 - Command/Powershell Documentation
Get-Help #F1 in the ISE
Get-help about* #Conceptual Powershell Help

#step 4 - Display Properties
Select-object -Property * #Pipe to display all properties and Values

#Step 5 - Object/Output Discovery
Get-Member
Show-Object #http://www.powershellcookbook.com/recipe/bpqU/program-interactively-view-and-explore-objects
            #Show object is also located in the demo scripts: Scripts\functions\showobject.ps1
#Step 6
#Look up type/class documentation usually found on msdn.microsoft.com
"System.String" | Search-Bing #See demo files : scripts\functions\Search-Bing.ps1 as Search-Bing is not built-in

