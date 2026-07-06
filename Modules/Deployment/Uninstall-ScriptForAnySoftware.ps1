# Purpose: Uninstall-ScriptForAnySoftware — Reusable PowerShell function libraries.
Function Uninstall-ScriptForAnySoftware {
################################################
# Powershell Detect and Remove software script #
#                                              #
# V1.0 - Gav                                   #
################################################
# - Edit the Variables below and launch the    #
#   script as an account that can access the   #
#   machines.                                  #
# - Script will check that logs exist and      #
#   create them if needed.                     #
################################################

cls

#VARIABLES - EDIT BELOW
    $software = "INSERT SOFTWARE HERE" # - Enter the name as it appears from WMIC query. WMIC PRODUCT NAME
    $textfile = "C:\Temp\pclist.txt"
    $Successlogfile = "C:\Temp\Done_Machines.txt"
    $Errorlogfile = "C:\Temp\Failed_Machines.txt"

#Date Calculation for Logs
    $today = Get-Date
    $today = $today.ToString("dddd (dd-MMMM-yyyy)")

#Load PC's From Text File
    $computers = Get-Content "$textfile"

#Check if Log Files Exist
    If (Test-Path $Successlogfile) {
        Write-Host -ForegroundColor Green "Success Log File Exists, Results will be appended"
                                   }
        else
                                   {
        Write-Host -ForegroundColor Red "Success Log File does not exist, creating log file"
        New-Item -path $Successlogfile -ItemType file
                                   }

    If (Test-Path $Errorlogfile) {
        Write-Host -ForegroundColor Green "Error Log File Exists, Results will be appended"
                                   }
        else
                                   {
        Write-Host -ForegroundColor Red "Error Log File does not exist, creating log file"
        New-Item -path $Successlogfile -ItemType file
                                   }



#Run Ping Test and Uninstall if turned on
    foreach ($computer in $computers) {
        If (Test-Connection -quiet -ErrorAction SilentlyContinue -computername $computer -count 2) 
        {
                Write-Host -ForegroundColor Green "$Computer is responding, Attempting Uninstall of $Software"
                Add-Content $Successlogfile "`n$today`n$Computer`n"
                Get-WmiObject -class Win32_Product -ComputerName $computer | Where-Object {$_.Name -match $software} | ForEach-Object { $_.Uninstall()}
        }
            else
        {
                Write-Host -ForegroundColor Red "$Computer is not responding"
                Add-Content $Errorlogfile "`n$today`n$Computer`n"
        }
                                       }
}