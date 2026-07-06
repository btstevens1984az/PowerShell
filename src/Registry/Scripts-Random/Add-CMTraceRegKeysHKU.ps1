# Purpose: Add-CMTraceRegKeysHKU — Windows registry read and write operations.
<#    
    ************************************************************************************************************
    Purpose:     Set CMTrace defaults for HKU
    Pre-Reqs:    CMTrace installed
	Modified by: K. Proctor (K&K) 
    ************************************************************************************************************
#>
Reg Load HKU\DefaultTemp "C:\Users\Default\NTUSER.DAT"
$RegPath = "HKU:\DefaultTemp\Software\Microsoft\Trace32"
New-Item -Path $RegPath
New-ItemProperty -Path $RegPath -Name "Last Directory" -Value "C:\Windows\CCM\Logs"
New-ItemProperty -Path $RegPath -Name "Column0" -Value "0 800"
New-ItemProperty -Path $RegPath -Name "Column1" -Value "1 90"
New-ItemProperty -Path $RegPath -Name "Column2" -Value "2 110"
New-ItemProperty -Path $RegPath -Name "Column3" -Value "3 0"
New-ItemProperty -Path $RegPath -Name "Register File Types" -Value "1"
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\.lo_ -Value "Log.File"
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\.log -Value "Log.File"
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\Log.File
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\Log.File\shell
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\Log.File\shell\open
New-Item -Path HKU:\DefaultTemp\SOFTWARE\Classes\Log.File\shell\open\command -Value '"C:\Windows\CMTrace.exe" "%1"'
[gc]::Collect()
reg unload HKU\DefaultTemp
