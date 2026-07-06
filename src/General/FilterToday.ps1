# Purpose: FilterToday — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 2/18/2009
#
# KEYWORDS: Filter
#
# COMMENTS: This is a filter that chooses only files that
# were written to today. 
#
# PowerShell Best Practices
# ------------------------------------------------------------------------

Filter IsToday
{
 Begin {$dte = (Get-Date).Date}
 Process { $_ | 
                  Where-Object { $_.LastWriteTime -ge $dte }
                }
}

Get-ChildItem -Path C:\fso | IsToday