Function Uninstall-Java {
<# 
.SYNOPSIS 
Java Updater
Brandon Stevens  Powersheel v5 
 
.DESCRIPTION 
[Only once] Before using any script, you need to run the following command as admin in PowerShell: 
 
            Set-ExecutionPolicy RemoteSigned 
 
[Every time] To run the script, lunch PowerShell as different user (your admin account) ; hold SHIFT and Right click 
 
After running the script against a computer: 
 
COMPUTER12 : is ON 
COMPUTER12 : Found -->    Java 8 Update 131 
COMPUTER12 : Found -->    Java 8 Update 141 
Would you like to Uninstall the above Version(s)? y/n: y 
COMPUTER12 : Uninstalling Java 8 Update 131 
COMPUTER12 : Uninstalling Java 8 Update 141 
COMPUTER12 : Installing   Java 8 Update 
COMPUTER12 : New Java is  Java 8 Update 151 
 
.EXAMPLE 
 
.\JavaUpdate.ps1 -ComputerName 117.166.145.89 
 
Use up arrow and change the computer name for quick action 
Warn users before executing the script 
 
#> 
 
[CmdletBinding()]  
param (  
    [Parameter(Mandatory = $True,  
               ValueFromPipeline = $True,  
               ValueFromPipelineByPropertyName = $True)]  
    [String]$ComputerName 
) 
function JavaInstall 
   { 
      #Get Java version(s) installed 
      $java = Get-WmiObject -Class win32_product -ComputerName $ComputerName -Filter "Name like '%Java%Update %'" | ForEach-Object {$_.Name} 
      $java | ForEach-Object { Write-Host "$ComputerName : Found -->    $_" -ForegroundColor Yellow} 
 
    if (($input= Read-Host -Prompt "Would you like to Uninstall the above Version(s)? y/n") -eq "y") 
        { 
            #Terminate all Java instances 
            $javaPath = (Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "ExecutablePath like '%java%'") | ForEach-Object {$_.ProcessId} 
            $javaPath | ForEach-Object {(Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "ProcessId='$_'").terminate() | Out-Null} 
             
            $oraclePath = (Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "ExecutablePath like '%oracle%'") | ForEach-Object {$_.ProcessId} 
            $oraclePath | ForEach-Object {(Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "ProcessId='$_'").terminate() | Out-Null}        
             
            #Terminate IEXPLORER, but only if Java is beeing used 
            if ($javaPath -or $oraclePath)  
                {                 
                    $exeIE = (Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "Name='iexplore.exe'") | ForEach-Object {$_.ProcessId} 
                    $exeIE | ForEach-Object {(Get-WmiObject -Class win32_process -ComputerName $ComputerName -Filter "ProcessId='$_'").Terminate() | Out-Null}                    
                } 
 
            #Uninstall Java old version(s) 
            $java | ForEach-Object { 
                                    Write-Host "$ComputerName : Uninstalling $_" -ForegroundColor White 
                                    (Get-WmiObject -Class win32_product -Filter "Name='$_'" -ComputerName $ComputerName).Uninstall() | Out-Null                             
                                    } 
 
            #Create the temp directory and copy file 
            $temp= [WMICLASS]"\\$ComputerName\ROOT\CIMV2:win32_Process"  
            $temp.Create("cmd.exe /c md c:\temp") | Out-Null 
         
            Copy-Item -Path "\\98.127.105.31\Java\msi\jre151.msi" -Destination "\\$ComputerName\c$\temp\" -Force 
 
            #Install the application 
            Write-Host "$ComputerName : Installing   Java 8 Update" -foregroundcolor White 
            $product= [WMICLASS]"\\$ComputerName\ROOT\CIMV2:win32_Product" 
            $product.Install("c:\temp\jre151.msi") | Out-Null        
      
            #Query new Java version(s) 
            $newJava = Get-WmiObject -Class Win32_Product -ComputerName $ComputerName -Filter "Name like '%Java%'" | Foreach-Object {$_.Name} 
            $newJava | Foreach-Object {Write-Host "$ComputerName : New Java is  $_" -foregroundcolor Green}                      
        } 
    else { 
            $input= "n" 
            Write-Host "$ComputerName : Operation has been canceled!" -foregroundcolor Red 
         } 
    } 
function Main 
    {               
        if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1) 
        { 
            Write-Host "$ComputerName : is ON" -ForegroundColor Green 
            JavaInstall 
        } 
        else  
        { 
            Write-Host "$ComputerName : is OFF" -ForegroundColor Red 
        } 
    } 
Main
}