# Purpose: SelectService — Windows desktop configuration and management.
# powershell 2
# july 31 2010  Kerry Kreitinger

# get user input on service to work with
$svc_input = Read-Host "Which SERVICE would you like?"
Write-Host "The $svc_input service will be checked"
get-service $svc_input | ft

# write service status out or compare and ask if start or stop is desired

write-host " DO you want to STOP START this service."

$svc_action = read-host "Enter action you want to do with the $svc_input service?"
write-host "You want to $svc_action the $svc_input service!"
$svc_verify = Read-Host "Is this correct?"

switch ($svc_verify) 
   { 
     ys {Write-host -Foregroundcolor yellow "Apparently you must be Joe Nicolleti, the codes is invalid and your system will now reboot"}
	n {goto end}
	no {"get-service -name $svc_input"}
       y {"stop-service -name $svc_input"}
        YES {"stop-service -name $svc_input"} 
        default {write-host "end"}
   }

switch ($svc_action) 
    { 
        START {start-service -name $svc_input}
        STOP {stop-service -name $svc_input} 
        default {Write-host -Foregroundcolor yellow "STOP or START was not entered as an action"}
    }

:end
get-service -name $svc_input | ft


# if action = start and verify = y do start
# if action = start and verify = yes do start
# if action = start and verify = n do nothing
# if action = start and verify = n do nothing
