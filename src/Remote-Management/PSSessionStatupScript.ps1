# Purpose: PSSessionStatupScript — PowerShell automation.
#session statupScript demo
#Identify commands to be visible in the PSSession
$pattern = "(Get-)|(Select-)|(Convert-)|(Measure-)|(format-)|(out-)|(Exit-)"
get-command -CommandType cmdlet | Where-object { $_.Name -notmatch $pattern } | 
    ForEach-Object {$_.Visibility = "Private"}

#optionally disable Powershell language
#$ExecutionContext.SessionState.LanguageMode="NoLanguage"
