# Purpose: Get-UserLogons — General-purpose PowerShell utilities.
$share = "\\186.189.182.154\share"
$logons = "U:\HPCA\Logons.txt"
$logs = Get-ChildItem -path $share -Filter *.log -Recurse
ForEach ($log in $logs){
    $content = Get-Content $log.FullName
    Add-Content $logons $content
}