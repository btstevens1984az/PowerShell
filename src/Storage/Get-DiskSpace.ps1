# -----------------------------------------------------------------------------------------
# Script: Get-DiskSpace.ps1
# Date: July 21, 2015
# Version: 1.0
# Purpose: This script uses WMI to retrieve hard disk usage on local and remote computers.
#
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

<#
    .SYNOPSIS        Retrieve hard disk space usage on local or remote systems.
        .DESCRIPTION        Uses WMI to retrieve hard disk usage information from remote or local machines. Without any paramertes the script will return the hard disk        space usage for all hard disks. You can also specify to return the hard disk space usage for all of the hard disks that have either X percentage
        of free space or have X gigabytes of free space.

    .PARAMETER ComputerName
        Returns the hard disk space usage for all hard disks.

    .PARAMETER FreeSpace
        Returns the hard disk with X gigabytes of free space.

    .PARAMETER PercentFree
        Returns the hard disk with X percentage of free space.

    .Link 
        https://toolsmith.brycoretechnologies.com
#>


#Requires -version 3

[Cmdletbinding(DefaultParameterSetName="ListAll")]
Param (
    $ComputerName = $env:COMPUTERNAME,

    [Parameter(ParameterSetName="ByFreeSpace")]
    [int]$FreeSpace,

    [Parameter(ParameterSetName="ByPercent")]    [ValidateRange(1,100)]
    [int]$PercentFree
)


if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) {


    try {
    
    # Get the hard disk information
    $params = @{
        'ComputerName' = $ComputerName;
        'Class' = 'Win32_LogicalDisk';
        'Filter' = 'DriveType = 3';
        'ErrorAction' = 'Stop'
    }

    # If we are going to use alternate credentials to access the computer then supply it
    if($FS_Credential) {
        $params.Credential = $FS_Credential
    }

    # Create an array to hold the information about the processes running on the computer
    $allhdusage = New-Object System.Collections.ArrayList

    if ($PSCmdlet.ParameterSetName -eq "ByPercent") {

        $disks = Get-WmiObject  @params | Where-Object {([Math]::Round((($_.FreeSpace/1GB) / ($_.Size/1GB) * 100),0)) -le $PercentFree} | Select-Object DeviceID, FreeSpace, Size, VolumeName 
    }

    elseif ($PSCmdlet.ParameterSetName -eq "ByFreeSpace") {

        $disks = Get-WmiObject  @params | Where-Object {([Math]::Round($_.FreeSpace/1GB,0)) -le $FreeSpace} | Select-Object DeviceID, FreeSpace, Size, VolumeName 
    }

    else {

        $disks = Get-WmiObject  @params | Select-Object DeviceID, FreeSpace, Size, VolumeName 
    }
     


     if ($disks) {
        foreach ($disk in $disks) {

           $diskhash = [ordered]@{
                "Computer Name" = $ComputerName;
                "Device ID" = $disk.DeviceID;
                "Volumn Name" = $disk.VolumeName;
                "Size (GB)" = ([Math]::Round($disk.Size/1GB,2));
                "Used Space (GB)"=  ([Math]::Round($disk.Size/1GB - $disk.FreeSpace/1GB,2));
                "Free Space (GB)" = ([Math]::Round($disk.FreeSpace/1GB,2));
                "Percent Free (%)" = ([Math]::Round((($disk.FreeSpace/1GB) / ($disk.Size/1GB) * 100),2))
           }

           $objdisk = New-Object -TypeName PSObject -Property $diskhash
           
           $allhdusage.Add($objdisk) | Out-Null
        }
        
        # Output the disk inforamtion
        $allhdusage

     }

     }
     catch {
  
       $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}