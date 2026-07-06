# Purpose: passwordLastSet — Security auditing and compliance checks.
# The first line is the path to your .csv file. It can be a local or network location.

$strPath = "H:\AdminTasks\PasswordLastSet.csv"
# Use the next 4 lines to get the current domain and filter on the User object.

$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter = "(objectClass=User)"
#The next line uses QADUser cmdlet to get all users except those with the Password Never Expires flag set.

Get-QADUser -IncludeAllProperties -sizelimit 0 |Select-Object logonname, pwdLastSet, email | Export-Csv -Path $strPath
#Use the next line to choose which AD attributes to include in the report. Each attribute will create a column heading with the same name.

# Select-Object sn, givenanme, SamAccountName, passwordexpires |
#Finally, export the data.

# Export-Csv -Path $strPath