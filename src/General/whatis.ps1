# Purpose: whatis — General-purpose PowerShell utilities.
clear-host
$strFilter = "computer"
 $objDomain = New-Object System.DirectoryServices.DirectoryEntry
 $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.SearchScope = "Subtree" 
$objSearcher.PageSize = 6000 
$objSearcher.Filter = "(objectCategory=$strFilter)"
$colResults = $objSearcher.FindAll()
foreach ($i in $colResults) 
    {
        $objComputer = $i.GetDirectoryEntry()
        Get-WMIObject Win32_BIOS -computername $objComputer.Name | Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
		 Get-command ("C:\program files\microsoft office\office12\OUTLOOK.exe" ).FileVersionInfo.ProductVersion | Out-File -filepath �C:\LOGS\OutlookVersion.txt� -append
    }
