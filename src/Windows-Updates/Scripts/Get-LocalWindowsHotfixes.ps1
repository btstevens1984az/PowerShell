# Purpose: Get-LocalWindowsHotfixes — Windows Update and patch management.
﻿Function Get-LocalWindowsHotfixes {
{
    $outputs = Invoke-Expression "wmic qfe list"
    $outputs = $outputs[1..($outputs.length)]
    
    
    foreach ($output in $Outputs) {
        if ($output) {
            $output = $output -replace 'y U','y-U'
            $output = $output -replace 'NT A','NT-A'
            $output = $output -replace '\s+',' '
            $parts = $output -split ' '
            New-Object -Type PSObject -Property @{
                KBArticle = [string]$parts[0]
                Computername = [string]$parts[1]
                Description = [string]$parts[2]
                FixComments = [string]$parts[6]
                HotFixID = [string]$parts[3]
                InstalledOn = [datetime]::ParseExact($parts[5], "M/d/yyyy", $null)
                InstalledBy = [string]$parts[4]
                InstallDate = [string]$parts[7]
                Name = [string]$parts[8]
                ServicePackInEffect = [string]$parts[9]
                Status = [string]$parts[10]
            }
        }
    }
}
}