# Purpose: Vulnerabilities — Standalone GUI applications and utilities.
$key = Read-Host 'What is your API Key?'
$body = Read-Host 'Insert JSON Body here'
Invoke-WebRequest -UseBasicParsing https://api.msrc.microsoft.com/engage/cars -ContentType "application/json" -Header @{ "870c97b46a2a41a0ae3174ee66b7f184" = $key } -Method POST -Body $body
Read-Host -Prompt "Press Enter to Exit..."