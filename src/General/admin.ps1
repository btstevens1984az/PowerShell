

# write-host "###########################################################################" -ForegroundColor DarkCyan  
# write-host "###################### TOOL KIT USING POWERSHELL ##########################" -ForegroundColor Yellow  
# write-host "################ 11 TOOLS FOR REMOTE ADMINISTRATION #######################" -ForegroundColor Green  
# write-host "##################### USE ADMIN ACCOUNT TO START ##########################" -ForegroundColor Yellow  
# write-host "## by Shaiju J.S ##################################### 01 Nov 2010 ########" -ForegroundColor Green  
# write-host "###########################################################################" -ForegroundColor DarkCyan  
   
  
  
<#   
.NAME  
  
Remote_Admin_Tools.ps1  
     
.SYNOPSIS    
  
This is a simple Powershell script to provide a set of 11 tools to make remote administration easy.    
  
.DESCRIPTION    
  
You can use the below key words to get the corresponding tools.  
  
R - To restart a remote server  
I - To do IISRESET on a remote web server  
W - To do WLBS query on a web server for Windows Load Balancing status  
J - To get the status of SQL Job starting with any string you input (You will be prompted to give Server name and Job name string)  
V - To start a specific service on a remote machine (Make sure to provide the 'Service Name'properly- as shown in the properties page of the services)  
X - To stop a specific service on a remote machine (Make sure to provide the 'Service Name'properly- as shown in the properties page of the services)  
T - To get the status of scheduled tasks running on a remote machine (You will be prompted for Server Name)  
L - To list and log off selected Terminal Service session on a remote machine (You will be prompted for Server Name)  
B - To get the basic inventory of a remote machine (You will be prompted for Server Name)  
A - Availability of a Process (Responding or not)  
U - Utilization of resources by a process (CPU and Memory)  
E - To Exit  
  
.IMPORTANT  
  
You need an administrative account with domain privileges and SQL access to use this tool.  
  
Make sure to exit this application after use, to avoid possible security problems.  
  
You need to have PS Terminal Service installed and added to powershell to use the terminal service functions.  
  
PLease find the links below for more details.  
     
.ERROR HANDLING  
  
Much coding is not done to handle all the errors and exceptions, so you might receive errors in non standard scenarios.  
  
.LINK  
  
http://technet.microsoft.com/hi-in/scriptcenter/powershell(en-us).aspx  
http://www.powershellcommunity.org/  
http://en.wikipedia.org/wiki/Windows_PowerShell  
http://code.msdn.microsoft.com/PSTerminalServices   
http://code.msdn.microsoft.com/PSTerminalServices/Release/ProjectReleases.aspx?ReleaseId=3953  
#>  
  
  
#######################################################################################  
  
$a = (Get-Host).PrivateData  
$a.WarningBackgroundColor = "red"  
$a.WarningForegroundColor = "white"  
#To change your screen or background color set the following:  
#$Host.Ui.RawUi.BackGroundColor = "Blue"  
# To change your test or foreground color set the following:  
#$Host.Ui.RawUi.ForeGroundColor = "Yellow"  
  
gc env:computername   
Get-Date   
  
function Read-Choice {  
                          PARAM([string]$message, [string[]]$choices, [int]$defaultChoice=11, [string]$Title=$null )  
                          $Host.UI.PromptForChoice( $caption, $message, [Management.Automation.Host.ChoiceDescription[]]$choices, $defaultChoice )  
                     }  
  
                        switch(Read-Choice "Use Short Cut Keys:[]" "&Restart","&IISRESET","&WLBS Status","&Job- SQL","&V-Start Service","&X-Stop Service","&Task- Scheduled","&Log-off TS","&Basic Inventory","&Availability- Process:Response","&Utilization- Process:Resource","&Exit")  
  
                        {  
                         0   
                        {   
                            Write-Host "You have selected the option to restart a server" -ForegroundColor Yellow  
                            $ServerName = Read-Host "Enter the name of the server to be restarted"  
                            $qry = ('select statuscode from win32_pingstatus where address="' + $ServerName + '"')  
                            $rslt = gwmi -query "$qry"  
                            if ($rslt.StatusCode -eq 0)   
  
                              {  
                                Get-Date  
                                write-host "$ServerName is reachable"  
                                 $server = gwmi Win32_operatingsystem -computer $ServerName  
                                Write-Host "$ServerName is getting restarted"  
                                Get-Date   
                                $server.reboot()  
                                Write-Host "Starting continuous ping to test the status"    
                                $stat=ping -n 100 $ServerName   
                                $stat           
                                Start-Sleep -s 300  
                                Write-Host "Here is the last reboot time: "   
                                $wmi=Get-WmiObject -class Win32_OperatingSystem -computer $ServerName   
                                $LBTime=$wmi.ConvertToDateTime($wmi.Lastbootuptime)  
                                $LBTime  
                                   
                               }  
  
                            else {  
                                    Get-Date  
                                    write-host "$ServerName is not reachable, please check this manually"  
                                    exit  
                                   }  
  
                         }   
                         1   
                        {   
                              Write-Host "You have selected the option to do IISRESET" -ForegroundColor Yellow  
                            $Server1 = Read-Host "Enter the server name on which iis need to be reset"  
                            rcmd \\$Server1 iisreset  
                         }   
                         2   
                        {  
                            Write-Host "You have selected the option to check WLBS status" -ForegroundColor Yellow  
                            $Server2 = Read-host "Enter the remote computer name"   
                             rcmd \\$Server2 wlbs query  
                        }   
                         3   
                        {   
                              Write-Host "You have selected the option to get the status of SQL job" -ForegroundColor Yellow  
                            write-host "Hope you are logged in with an account having SQL access privilege"  
                             [System.Reflection.Assembly]::LoadWithPartialName(?Microsoft.SqlServer.SMO?) | out-null  
                            $instance = Read-Host "Enter the server name"  
                            $j = Read-Host "Job names starting with....."                              
                            $s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $instance  
                            $s.JobServer.Jobs |Where-Object {$_.Name -ilike "$j*"}| SELECT NAME, LASTRUNOUTCOME, LASTRUNDATE   
                         }   
                         4  
                         {  
                             Write-Host "You have selected the option to start a service" -ForegroundColor Yellow  
                            $Server4 = Read-host "Enter the remote computer name"  
                             $svc4 = Read-host "Enter the name of the service to be started"  
                             (Get-WmiObject -computer $Server4 Win32_Service -Filter "Name='$svc4'").InvokeMethod("StartService",$null)  
                         }  
                         5  
                         {  
                             Write-Host "You have selected the option to stop a service" -ForegroundColor Yellow  
                            $Server5 = Read-host "Enter the remote computer name"  
                             $svc5 = Read-host "Enter the name of the service to be stopped"  
                             (Get-WmiObject -computer $Server5 Win32_Service -Filter "Name='$svc5'").InvokeMethod("StopService",$null)  
                         }  
                         6  
                         {  
                             Write-Host "You have selected the option to get the scheduled task status list" -ForegroundColor Yellow  
                            $Server6 = Read-host "Enter the remote computer name"  
                             schtasks /query /S $Server6    
                         }  
                         7  
                         {  
                             Write-Host "You have selected the option to list and log off terminal service sessions" -ForegroundColor Yellow  
                            Import-Module PSTerminalServices  
                             $server7 = Read-Host "Enter Remote Server Name"  
                            $session = Get-TSSession -ComputerName $server7 | SELECT "SessionID","State","IPAddress","ClientName","WindowStationName","UserName"    
                             $session  
                            $s = Read-Host "Enter Session ID, if you want to log off any session"  
                            Get-TSSession -ComputerName $server7 -filter {$_.SessionID -eq $s} | Stop-TSSession ?Force  
                         }  
                         8  
                        {  
                            Write-Host "You have selected the option to get basic computer inventory" -ForegroundColor Yellow  
                            $server8 = Read-Host "Enter Remote Server Name"  
                            Get-WMIObject -Class "Win32_BIOS" -Computer $server8 | select SerialNumber  
                            get-wmiobject -computername  $server8 win32_computersystem                               
                        }  
                        9  
                        {  
                        Write-Host "You have selected the option to do a specific process status check on a selected server" -ForegroundColor Yellow  
                        Start-Sleep -Seconds 2  
                        $app9 = read-host "Enter the process name"  
                        $server9 = read-host "Enter the server name"  
                        Write-Host "Give details only if $app9 is not responding"  
                        $resp = Get-Process -Name $app9 -ComputerName $server9 | Where-Object -FilterScript {$_.Responding -eq $false} | write-host "Not responding"   
                        $resp  
                        }  
                        10  
                        {  
                        Write-Host "You have opted to do process resource utilization check on a server" -ForegroundColor Yellow  
                        $app10 = read-host "Enter the process name"  
                        $server10 = read-host "Enter the server name"  
                        Write-Host "Memory Consumption"  
                        $mem = (Get-Process -Name $app10 -ComputerName $server10 | sort workingset | select -last 1).workingset / 1024 /1024   
                        write-host "$mem MB is being utilized by $app10"  
                        Write-Host "CPU Consumption"  
                        $cpu = (get-process -Name $app10 -ComputerName $server10 | sort CPU | select -last 1).CPU / 1000  
                        Write-Host "$cpu % of CPU is being used by $app10"  
                        }  
                        11  
                         {  
                             Write-Host "You have selected the option to exit the tool, Thanks for using this !!!" -ForegroundColor Yellow      
                             exit  
                         }  
  
  
} 

