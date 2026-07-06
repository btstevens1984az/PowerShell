# Purpose: Get-HotFixReportMultipleKBs — Windows Update and patch management.
Function Get-HotFixReportMultipleKBs {

# Add hotfixes to scan for
$hotFixes = @(
    "KB4012212", 
    "KB4012215", 
    "KB4012218",
    "KB4015546",
    "KB4015549",
    "KB4015552",
    "KB4019263",
    "KB4019264",
    "KB4019473",
    "KB4022722",
    "KB4022723",
    "KB4012598",
    "KB4012214",
    "KB4012217",
    "KB4012213",
    "KB4012216",
    "KB4012606",
    "KB4013198",
    "KB4015546",
    "KB4013429"
    )
 
# Add computers to scan for
$computers = (get-content -path c:\Users\$env:USERNAME\Desktop\computers.txt) 
 
# Report name
$Report = @()
$reportName = "c:\Users\$env:USERNAME\Desktop\Report_$(get-date -Uformat "%Y%m%d-%H%M%S").csv"
 
# return hotfix
Function Get-HotFixStatus([string]$hotFixes, [string]$computers) 
{ 
  Get-WmiObject -class  win32_QuickFixEngineering -Filter "HotFixID = '$hotfixes'" -computername $computers
} 
 
# Output to screen - create report with true or false
Function Get-HotFixReport([string[]]$hotFixes, [string[]]$computers) 
{ 
  foreach($computer in $computers) 
  { 
    Write-Host " "
    Write-Host $computer
    foreach ($hotfix in $hotfixes) 
    { 
     Write-Host $hotfix
     $status =  $(if(Get-HotFixStatus -hotfix $hotfix -computer $computer) {$true} else {$false}) 
     $object = New-Object -TypeName PSObject 
     $object | Add-Member -MemberType NoteProperty -Name Computer -Value $computer
     $object | Add-Member -MemberType NoteProperty -Name HotFix -Value $hotfix
     $object | Add-Member -MemberType NoteProperty -Name Installed -Value $status
     Write-host "--" $status
     $object     
    }
   } 
} 
 
Clear-Host
Write-Host "Compiling report..."
Get-HotFixReport -hotfix $hotfixes -computer $computers | 
Sort-object -property computer | 
Export-Csv $reportName -NoTypeInformation -UseCulture
ii $reportName
 
Write-Host " "
Write-Host "Done!"
}