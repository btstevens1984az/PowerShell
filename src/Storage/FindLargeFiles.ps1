# Purpose: FindLargeFiles — Storage management and disk operations.
###################################################################
# FindLargeFiles.ps1
# ed wilson, msft, 5/14/2007
#
# uses get-childItem to get listing
# uses foreach-object to iterate through
# Pipelines the result, and uses write host
#
##################################################################
cls
$intLength = 10240
get-childitem |
 foreach-object `
  { if 
      ($_.length -gt $intLength) 
	  { Write-Host "The following files are over $intLength bytes" `
	    $_.name, $_.length -ForegroundColor Blue
	   }
   }
    