# Purpose: Power Options Restart Now — General-purpose PowerShell utilities.
if($scope -eq ''){restart-computer 10.199.208.191 $computername -force -confirm:$false}
else{restart-computer 10.199.208.191 $computername -credential $creds -force -confirm:$false}