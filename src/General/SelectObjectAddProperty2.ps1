# Purpose: SelectObjectAddProperty2 — General-purpose PowerShell utilities.
$services = Get-Service
$hash =  @{
    name="RequiredServicesNames"
    expression = {$regServices = $_.RequiredServices
                    if ($regServices)
                    {
                        ($regServices.name) -join ";"
                    }
                    else
                    {
                        "none"
                    }
    
                 }
}
    
$services | Select-object name,status,displayname,$hash