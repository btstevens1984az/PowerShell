Function Get-HotFixHTMLREport {
<#
 .SYNOPSIS  
  Example of Table Formatting
 
 .DESCRIPTION  
  Example of outputting powershell content into a table formatted a bit nicer than from the shell
 
  
 .REF
#>

#Custom content for the <HEAD> tag, used in the convertto-html cmdlet
$Header = @"
<style>
    TABLE { font: menu; 
            border-width: 1px; 
            border-style: solid; 
            border-color: black; 
            border-collapse: collapse; 
            tr:nth-child(even); 
            Background-color: #f2f2f2;}
    TD    { Border-width: 1px; 
            padding: 3px; 
            border-style: solid; 
            border-color: black;}
</style>
"@

#Prompts for creds then Gets updates/hotfixes that have been installed on the specified machine
Get-HotFix -ComputerName 161.71.207.69 -Credential (Get-Credential) | Sort-Object -Property InstalledOn -Descending | `
#changes default titles of table and includes basic information from get-hotifx cmdlet
Select-Object -Property @{N='Computer'; E={$_.PSComputerName}},Description,HotfixID,InstalledBy,Installedon | `
#uses our previously declared html table to format the output
ConvertTo-Html -Head $Header | Out-File C:\Temp\hotfix.htm
}