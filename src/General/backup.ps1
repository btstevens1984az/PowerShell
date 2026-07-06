# Purpose: backup — General-purpose PowerShell utilities.
######################################################################################### 
# DATE    : 08-06-2015 
# COMMENT : This script makes files backup. 
#           
# VERSION : 1.0
#########################################################################################

$Source=Read-Host "Please type the source directory you want to backup"
$Destination=Read-Host "Please type the path directory you want to copy the backup files"
$Folder=Read-Host "Please type the root name folder"
$validation=Test-Path $Destination


New-PSDrive -Name "Backup" -PSProvider FileSystem -Root $Destination

if ($validation -eq $True){
        
       Set-Location Backup:
}
else{
    
    Write-Host "Error!Run Script Again"

    break
}

    robocopy $Source $Destination\$Folder *.* /mir /sec

    


Function Pause{

     Write-Host "Backup Sucessfull!!! `n"

     Write-Host "Press any key to continue..."

     $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null

}



Pause


