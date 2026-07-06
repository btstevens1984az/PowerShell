# Purpose: Optional Symlink — General-purpose PowerShell utilities.
### SYMBOLIC LINK FILES
#references
#https://msdn.microsoft.com/en-us/library/aa365006(VS.85).aspx
#https://msdn.microsoft.com/en-us/library/aa365680(v=vs.85).aspx

#region Setup
#save current demo location
pushd
$DemoPath= 'c:\temp2'
#endregion setup

# Create a new symbolic link file named MySymLinkFile.txt in C:\Temp which links to $DemoPath\test.ps1
cd C:\Temp
if (-not (Test-Path $DemoPath\test.ps1))
{
    new-item -Path $DemoPath\test.ps1 -ItemType file -Force
    Set-Content -Path $DemoPath\test.ps1 -Value "#this is a test"
    $DeleteTest = $true
}
New-Item -ItemType SymbolicLink -Name MySymLinkFile.txt -Target $DemoPath\test.ps1  # File
# Target is an alias to the Value parameter
<# Equivalent to above
New-Item -ItemType SymbolicLink -Path C:\Temp -Name MySymLinkFile.txt -Value $DemoPath\test.ps1
New-Item -ItemType SymbolicLink -Path C:\Temp\MySymLinkFile.txt -Value $DemoPath\test.ps1
New-Item -ItemType SymbolicLink -Name C:\Temp\MySymLinkFile.txt -Value $DemoPath\test.ps1
#>

### SYMBOLIC LINK DIRECTORIES
# Create a new symbolic link directory named MySymLinkDir in C:\Temp which links to the $DemoPath folder
# ItemType is the same for files and directories - autodetect based on specified target
New-Item -ItemType SymbolicLink -Name MySymLinkDir -Target $DemoPath   # Directory
# Target is an alias to the Value parameter

# Similar to above, any combination of Path and Name also works
<#
New-Item -ItemType SymbolicLink -Path C:\Temp -Name MySymLinkDir -Value $DemoPath
New-Item -ItemType SymbolicLink -Path C:\Temp\MySymLinkDir -Value $DemoPath
New-Item -ItemType SymbolicLink -Name C:\Temp\MySymLinkDir -Value $DemoPath
#>
### HARD LINKS
New-Item -ItemType HardLink -Path C:\Temp -Name MyHardLinkFile.txt -Value $DemoPath\test.ps1
# Same combinations of Path and Name allowed as described above

### DIRECTORY JUNCTIONS
New-Item -ItemType Junction -Path C:\Temp\MyJunctionDir -Value $DemoPath
# Same combinations of Path and Name allowed as described above

# GET-CHILDITEM
# Append link type column to Mode property and display with Get-ChildItem
# Use 'l' for all link types
# Increase the width of the Length column by 4 (from 10 to 14)
Get-ChildItem C:\Temp | sort LastWriteTime -Descending


# New Target property
# Works with any link type
# Not displayed in the default table view
# Displayed in the default list view
# New LinkType property with values: SymbolicLink
Get-ChildItem C:\Temp\MySymLinkFile.txt | Format-List


# REMOVE-ITEM
# Works like any other item type 

# Removes MySymLinkFile.txt
Remove-Item C:\Temp\MySymLinkFile.txt 

#Prompts for Confirmation
Remove-Item C:\Temp\MySymLinkDir 
#need to use force for deleting symlink to a director as well as junctions
Remove-Item C:\Temp\MySymLinkDir -Force
Remove-Item C:\temp\MyJunctionDir -Force
remove-item C:\temp\MyHardLinkFile.txt

#demo cleanup
if ($DeleteTest)
{
    remove-item $DemoPath\test.ps1
    Remove-Variable -Name DeleteTest
}
#return to previous demo localtion
popd