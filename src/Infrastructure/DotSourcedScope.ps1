# Purpose: DotSourcedScope — Core infrastructure automation scripts.
#DotSourcedScope.ps1

 $DotSourcedTime = get-date
 $DotSourcedDay  = (get-date).day
 $DotSourcedNum  = "17061961"

 write-output "'`$DotSourcedTime' variable is $DotSourcedTime"
 write-output "'`$DotSourcedDay'  variable is $DotSourcedDay"
 write-output "'`$DotSourcedNum'  variable is $DotSourcedNum"

 Write-output "The above variabled are still present and accessable."
 