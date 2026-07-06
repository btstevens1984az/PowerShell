# Purpose: CheckAllDirectoryPermissions — General-purpose PowerShell utilities.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
Write-Output "Export ACL permissions for a folder/directory"
""
$Path = Read-Host -prompt 'Please eneter path to check ACL permissions'
""
$ReportName = Read-Host -prompt 'Please enter HTML Name'
[string]$CSS= @'
    <style>
    body {font-family:Verdana;
           font-size:8pt; 
           background: 	#ffffff}
    h2 {color:black;
        text-decoration:underline;
        font-size:18pt;}
    th { color:black;
         background-Color:CadetBlue; }
    tr {color:black}
    TR:Nth-Child(even) {Background-Color: #F0F8FF;}
    table, tr, td, th {padding: 2px; margin: 0px;vertical-align:top}
    table {margin-left: auto;margin-right: auto;}
    </style>
'@

Get-ChildItem $path -recurse | Where-Object { $_.PsIsContainer } | ForEach-Object { $path1 = $_.fullname; Get-Acl $_.Fullname | ForEach-Object { $_.access | Add-Member -MemberType NoteProperty 'Path' -Value $path1 -passthru }} | ConvertTo-Html -Head $css -Body "<h1>File Permissions Report</h1>`n<h5>Report ran by: $env:username</h5>`n<h5>Report ran on: $env:computername</h5>`n<h5>Generated on $(Get-Date)</h5>" | Out-File "C:\temp\$ReportName.html"

(Get-Content c:\temp\$ReportName.html).replace('-536805376', 'Modify, Synchronize') | Set-Content c:\temp\$ReportName.html
(Get-Content c:\temp\$ReportName.html).replace('268435456', 'FullControl') | Set-Content c:\temp\$ReportName.html
(Get-Content c:\temp\$ReportName.html).replace('-1610612736', 'ReadAndExecute, Synchronize') | Set-Content c:\temp\$ReportName.html
""
Write-Output "Exported to c:\temp\$ReportName.html"
""
pause 


