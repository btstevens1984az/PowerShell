# Purpose: Working-WithWebAPI — PowerShell automation.
#Invoke-WebRequest
$Params = @{
 "URI"    = '<https://www.metaweather.com/api/location/2379574/>'
}
Invoke-WebRequest @Params

#Invoke-RestMethod
$Params = @{
 "URI"    = '<https://www.metaweather.com/api/location/2379574/>'
 "Method" = 'GET'
}
Invoke-RestMethod @Params

#Creds
$Credential = Get-Credential
$Params = @{
 "URI"            = '<https://httpbin.org/hidden-basic-auth/user/password>'
 "Authentication" = 'Basic'
 "Credential"     = $Credential
}
Invoke-RestMethod @Params

#API Key Authentication
$Params = @{
 "URI"     = '<https://httpbin.org/bearer>'
 "Method"  = 'GET'
 "Headers" = @{
 "Content-Type"  = 'application/json'
 "Authorization" = 'Bearer apikey'
 }
}
Invoke-RestMethod @Params

#OAuth Authentication
$AccessToken = ConvertTo-SecureString 'eyJ0eXAiOiJKV1QiL...' -AsPlainText -Force

$Params = @{
 "URI"            = '<https://graph.microsoft.com/v1.0/me>'
 "Authentication" = 'OAuth'
 "Token"          = $AccessToken
}
Invoke-RestMethod @Params

#Interacting with an API
