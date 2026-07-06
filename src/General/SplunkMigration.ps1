# Purpose: SplunkMigration — General-purpose PowerShell utilities.
#version 0.1
#Updated to account for DB folder which contains the DB_ folders.
Function Add-SplunkFolderNumber
{
    param(
        [parameter(Mandatory)]
        [System.IO.DirectoryInfo[]]$Folders
        )
    $Folders | Add-Member -MemberType scriptProperty -Name FileNumber -Value {[int]($this.name.substring($this.Name.LastIndexOf("_")+1)) }
    $Folders | Add-Member -MemberType scriptProperty -Name FileNamePart1 -Value {$this.name.substring(0,($this.Name.LastIndexOf("_")+1)) }
    $Folders

}
Function Rename-SplunkDBFolders
{
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
            [parameter(Mandatory)]
            [System.IO.DirectoryInfo[]]$Folders,
            [parameter(Mandatory)]
            [int]$StartingNumber)
    $folders = $Folders | Sort-Object -Property FileNumber
    Foreach ($FolderToRename in $Folders)
    {
        if ($pscmdlet.ShouldProcess("$($FolderToRename.Fullname) ", "Rename to $($FolderToRename.Filenamepart1+$StartingNumber) "))
        {
         Rename-Item -path $FolderToRename.Fullname -NewName ($FolderToRename.Filenamepart1+$StartingNumber) -PassThru
        }
         $StartingNumber++
    }


}

Function Migrate-SplunkFiles
{
[cmdletbinding()]
param(
    [parameter(Mandatory)]
    [string]$source,
    [parameter(Mandatory)]
    [string]$Destination,
    [switch]$TestDontDoAnything 
)
    $Subfolders = Get-ChildItem $source -Directory 
    Foreach ($folder in $Subfolders)
    {
        if (Test-Path -Path "$($folder.fullname)\db")
        {
        $SourceDBFolders = Get-ChildItem -Path "$($folder.fullname)\db" -Directory -filter db_*
        if ($SourceDBFolders)
        {
            $SourceDBFolders = Add-SplunkFolderNumber -Folders $SourceDBFolders 
            $DestinationPAth = "$($folder.fullname)\db" -replace ($source -replace "\\", "\\"),$Destination
            $destinationDBFolders = Get-ChildItem -Path $DestinationPAth -Directory -filter db_*
            $DestinationDBFolders = Add-SplunkFolderNumber -folders $destinationDBFolders
            $DestHighNumber = $destinationDBFolders | Sort-Object FileNumber  | Select -Last 1 -ExpandProperty FileNumber
            $sourceNumber = $DestHighNumber +100
            If ($TestDontDoAnything)
            {
                $ReNamedFolders = Rename-SplunkDBFolders -Folders $SourceDBFolders -StartingNumber $sourceNumber -WhatIf
                Write-Verbose "Starting to Move Files to $DestinationPath "
                $ReNamedFolders  | Move-Item -Destination "$DestinationPath\" -Verbose -WhatIf
                Write-Verbose "Finished Moving Files to $DestinationPath "
            }
            else
            {
                $ReNamedFolders = Rename-SplunkDBFolders -Folders $SourceDBFolders  -StartingNumber $sourceNumber 
                Write-Verbose "Starting to Move Files to $DestinationPath "
                $ReNamedFolders  | Move-Item -Destination "$DestinationPath\" -Verbose 
                Write-Verbose "Finished Moving Files to $DestinationPath "

            }
        }
        }
        else
        {
            Write-Verbose "No DB folder detected in: $($folder.fullname)" 
        }
    }

}

#Migrate-SplunkFiles -source "C:\temp\splunk2" -Destination "C:\temp\splunk1" -Verbose -ErrorAction Inquire 4>  .\SplunkMigrate.txt       
#Migrate-SplunkFiles -source "C:\temp\splunk2" -Destination "C:\temp\splunk1" -Verbose -ErrorAction Inquire
#Migrate-SplunkFiles -source "C:\temp\splunk2" -Destination "C:\temp\splunk1" -Verbose -ErrorAction Inquire -TestDontDoAnything


<#
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
 You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and 
 distribute the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks
  to market Your software product in which the Sample Code is embedded; (ii) to include a valid 
  copyright notice on Your software product in which the Sample Code is embedded;
   and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any
    claims or lawsuits, including attorneys’ fees, 
  that arise or result from the use or distribution of the Sample Code.
#>