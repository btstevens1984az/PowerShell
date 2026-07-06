# Purpose: get-diskinfograph — Reusable PowerShell function libraries.
#############################################################
#
# Overview:         Function to show disk space as a graphic
# Date Created:     02/26/2018
# Function Name:    Get-DiskInfoGraphicDisplay
# 
#############################################################

function Get-DiskInfoGraphicDisplay{ 
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$ComputerName
        )
 
$diskInfo = gwmi win32_logicaldisk -ComputerName $ComputerName -Filter "DriveType = 3"
$lines = "="*30 
$used = " "*20 
$free = " "*10 
$thresold=40 
Write-Host  $lines"Graph"$lines -ForegroundColor Cyan 
Write-Host "`n" 
Write-Host $table -NoNewline  
Write-Host " " -BackgroundColor Red -NoNewline 
Write-Host "Used Space" -NoNewline "  "  
Write-Host " " -BackgroundColor Green -NoNewline 
Write-Host "Free Space" -NoNewline 
Write-Host 
 
foreach($disk in $diskInfo) 
{ 
    $usedSize = ($disk.size -$disk.FreeSpace)/$disk.Size 
    $freeDisk =  $disk.FreeSpace/$disk.Size 
    $percentDisk = "{0:P2}" -f $freeDisk 
    Write-Host 
    Write-Host $disk.PSComputerName " "$disk.DeviceID -ForegroundColor White -NoNewline 
    Write-Host "  "-NoNewline  
    Write-Host (" "*($usedSize * $thresold))-BackgroundColor Red -NoNewline 
    Write-Host (" "*($freeDisk * $thresold)) -BackgroundColor Green -NoNewline  
    #Write-Host $freeDisk "GB" -NoNewline 
    Write-Host " " $percentDisk "Free" 
} 
Write-Host  
Write-Host  $lines"Graph"$lines -ForegroundColor Cyan 
} 