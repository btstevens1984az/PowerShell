# Purpose: Powershell GUI Tool  for Server Health Checks — Standalone GUI applications and utilities.
######################################################################################################################################################## 
#                  Powershell GUI Tool for windows Administration###############                                                                                  
# Version:1.0                                                                                                                                           
#  Enter one or mutiple servers line by line under EnterServers box and click the buttons according to your requirement                                                                                                                                                                                       
#                                                                                                                                                       
# In this tool all are self explantory except below numbered items                                                                                                
# 1) Servic check                                                                                                                                       
# 2) Check Process                                                                                                                                      
# 3)Port check  #                                                                                                                                       
# 4) Search Event logs                                                                                                                                  
#                                                                                                                                                       
#  For checking Services                                                                                                                                
#  example in order to check the specfic service name just enter first 3 letter of service name in the Filter box and click in service check            
#   you will get the all the services list whih running with that words you mentioned                                                                   
#   note: if you do not specify any words it will display all the services                                                                              
#   For checking process                                                                                                                                
#  example in order to check the specfic process name just enter first 3 letter of processname in the Filter box and click in process check             
#   you will get the all the services list whih running with that words you mentioned                                                                   
#   note: if you do not specify any words it will display all the process                                                                               
#                                                                                                                                                       
#   For checking event logs                                                                                                                             
#           example: if you want to check the event logs system or applications select the log types and enter key words or Event ID in the filter box   
#
#     # Note: Please copy  "Lucida Sans Typewriter,9"  font in your server where this tool is running in order to get the out put in clearly                                                                                                                                                  
#                                                                                                                                                       
#                                                                                                                                                       
#                        @@@@@@@@@@@@@@@@@@@@@You can covert this script  to exe@@@@@@@@@@@@@@@@@@@@                                                   
######################################################################################################################################################## 
 
 
  
 
Add-Type -AssemblyName System.Windows.Forms 
 
$Form = New-Object system.Windows.Forms.Form 
$Form.Text = "Power-GUI Version 1.0 Created by username" 
$Form.TopMost = $true 
$Form.Width = 900 
$Form.Height = 598 
$Form.FormBorderStyle= "Fixed3D" 
$form.StartPosition ="centerScreen" 
$form.ShowInTaskbar = $true 
 
 
############# 
    
 
 
 
$InputBox = New-Object system.windows.Forms.TextBox 
$InputBox.Multiline = $true 
$InputBox.BackColor = "#A7D4F7" 
$InputBox.Width = 280 
$InputBox.Height = 132 
$InputBox.ScrollBars ="Vertical" 
$InputBox.location = new-object system.drawing.point(3,31) 
$InputBox.Font = "Microsoft Sans Serif,10,style=Bold" 
$Form.controls.Add($inputbox) 
 
 
$outputBox= New-Object System.Windows.Forms.RichTextBox 
$outputBox.Multiline = $true 
$outputBox.BackColor = "#FDFEFE" 
$outputBox.Width = 1200 
$outputBox.Height = 300 
$outputBox.ReadOnly =$true 
$outputBox.ScrollBars = "Both" 
$outputBox.WordWrap = $false 
$outputBox.location = new-object system.drawing.point(9,350) 
$outputBox.Font = "Lucida Sans Typewriter,9" 
$Form.controls.Add($outputBox) 
 
 
$label3 = New-Object system.windows.Forms.Label 
$label3.Text = "EnterServers" 
$label3.AutoSize = $true 
$label3.Width = 25 
$label3.Height = 10 
$label3.location = new-object system.drawing.point(4,9) 
$label3.Font = "Microsoft Sans Serif,10,style=Bold" 
$Form.controls.Add($label3) 
 
 
$filterbox= New-Object system.windows.Forms.TextBox 
$filterbox.Multiline = $true 
$filterbox.Width = 280 
$filterbox.Height = 77 
$filterbox.ScrollBars ="Vertical" 
$filterbox.location = new-object system.drawing.point(6,191) 
$filterbox.Font = "Microsoft Sans Serif,10" 
$Form.controls.Add($filterbox) 
 
$Filters = New-Object system.windows.Forms.Label 
$Filters.Text = "Filters" 
$Filters.AutoSize = $true 
$Filters.Width = 25 
$Filters.Height = 10 
$Filters.location = new-object system.drawing.point(7,170) 
$Filters.Font = "Microsoft Sans Serif,10,style=Bold" 
$Form.controls.Add($Filters) 
 
$Eventlb = New-Object system.windows.Forms.Label 
$Eventlb.Text = "Search Eventlogs" 
$Eventlb.AutoSize = $true 
$Eventlb.Width = 25 
$Eventlb.Height = 10 
$Eventlb.location = new-object system.drawing.point(7,280) 
$Eventlb.Font = "Microsoft Sans Serif,10,style=Bold" 
$Form.controls.Add($Eventlb) 
 
$applicationbutton = New-Object system.windows.Forms.Button 
$applicationbutton.BackColor = "#F2FD48" 
$applicationbutton.Text = "Application Logs" 
$applicationbutton.Width = 100 
$applicationbutton.Height = 25 
$applicationbutton.location = new-object system.drawing.point(170,300) 
$applicationbutton.Font = "Microsoft Sans Serif,8" 
$applicationbutton.Add_Click({SAeventlogs}) 
$Form.controls.Add($applicationbutton) 
 
 
 
$sysbutton= New-Object system.windows.Forms.Button 
$sysbutton.BackColor = "#56ACF7" 
$sysbutton.Text = "System Logs" 
$sysbutton.Width = 100 
$sysbutton.Height = 25 
$sysbutton.location = new-object system.drawing.point(270,300) 
$sysbutton.Font = "Microsoft Sans Serif,8" 
$sysbutton.Add_Click({SAeventlogs}) 
$Form.controls.Add($sysbutton) 
 
$Setup= New-Object system.windows.Forms.Button 
$Setup.BackColor = "#125.167.1.246" 
$Setup.Text = "Setup Logs" 
$Setup.Width = 100 
$Setup.Height = 25 
$Setup.location = new-object system.drawing.point(370,300) 
$Setup.Font = "Microsoft Sans Serif,8" 
$Setup.Add_Click({SAeventlogs}) 
$Form.controls.Add($Setup) 
 
 
 
 
 
#Dropdown Box  
$Dropdown = New-Object system.windows.Forms.ComboBox  
$Dropdown.BackColor = "#e4f3fa" 
$Dropdown.Width = 150 
$Dropdown.Height = 20 
$Dropdown.location = new-object system.drawing.point(9,300) 
$Dropdown.Font = "Microsoft Sans Serif,10" 
 
$Form.controls.Add($Dropdown)  
 
$EVList=@("Application","System","Setup") 
 
foreach ($EV in $EVList) { 
                      $DropDown.Items.Add($EV) 
                              } 
 
 
##Dropdown Box End 
 
 
 
 
 
$Outputlb = New-Object system.windows.Forms.Label 
$Outputlb.Text = "Output" 
$Outputlb.AutoSize = $true 
$Outputlb.Width = 25 
$Outputlb.Height = 10 
$Outputlb.location = new-object system.drawing.point(12,330) 
$Outputlb.Font = "Microsoft Sans Serif,10,style=Bold,Italic" 
$Form.controls.Add($Outputlb) 
 
 
 
 
 
$Upbutton = New-Object system.windows.Forms.Button 
$Upbutton.BackColor = "#5bd22c" 
$Upbutton.Text = "Uptime" 
$Upbutton.Width = 80 
$Upbutton.Height = 22 
$Upbutton.location = new-object system.drawing.point(309,170) 
$Upbutton.Font = "Microsoft Sans Serif,8" 
$Upbutton.Add_Click({uptime}) 
$Form.controls.Add($Upbutton) 
 
$Serbutton = New-Object system.windows.Forms.Button 
$Serbutton.BackColor = "#5bd22c" 
$Serbutton.Text = "Servicecheck" 
$Serbutton.Width = 80 
$Serbutton.Height = 22 
$Serbutton.location = new-object system.drawing.point(309,50) 
$Serbutton.Font = "Microsoft Sans Serif,8" 
$Serbutton.Add_Click({Service}) 
$Form.controls.Add($Serbutton) 
 
$Biosbutton = New-Object system.windows.Forms.Button 
$Biosbutton.BackColor = "#5bd22c" 
$Biosbutton.Text = "Bios Details" 
$Biosbutton.Width = 80 
$Biosbutton.Height = 22 
$Biosbutton.location = new-object system.drawing.point(309,80) 
$Biosbutton.Font = "Microsoft Sans Serif,8" 
$Biosbutton.Add_Click({bios}) 
$Form.controls.Add($Biosbutton) 
 
$Listservicebutton = New-Object system.windows.Forms.Button 
$Listservicebutton.BackColor = "#5bd22c" 
$Listservicebutton.Text = "List Services" 
$Listservicebutton.Width = 80 
$Listservicebutton.Height = 22 
$Listservicebutton.location = new-object system.drawing.point(309,110) 
$Listservicebutton.Font = "Microsoft Sans Serif,8" 
$Listservicebutton.Add_Click({get-ser}) 
$Form.controls.Add($Listservicebutton) 
 
 
$InstalledAppsbutton = New-Object system.windows.Forms.Button 
$InstalledAppsbutton.BackColor = "#5bd22c" 
$InstalledAppsbutton.Text = "InstalledApps" 
$InstalledAppsbutton.Width = 80 
$InstalledAppsbutton.Height = 22 
$InstalledAppsbutton.location = new-object system.drawing.point(309,140) 
$InstalledAppsbutton.Font = "Microsoft Sans Serif,8" 
$InstalledAppsbutton.Add_Click({applist}) 
$Form.controls.Add($InstalledAppsbutton) 
 
$Pingbutton = New-Object system.windows.Forms.Button 
$Pingbutton.BackColor = "#5bd22c" 
$Pingbutton.Text = "Ping" 
$Pingbutton.Width = 80 
$Pingbutton.Height = 22 
$Pingbutton.location = new-object system.drawing.point(309,21) 
$Pingbutton.Font = "Microsoft Sans Serif,8" 
$Pingbutton.Add_Click({pingInfo})  
$Form.controls.Add($Pingbutton) 
 
$diskbutton = New-Object system.windows.Forms.Button 
$diskbutton.BackColor = "#5bd22c" 
$diskbutton.Text = "Drive Useage" 
$diskbutton.Width = 80 
$diskbutton.Height = 22 
$diskbutton.location = new-object system.drawing.point(400,21) 
$diskbutton.Font = "Microsoft Sans Serif,8" 
$diskbutton.Add_Click({disk}) 
$Form.controls.Add($diskbutton) 
 
 
$cpubutton = New-Object system.windows.Forms.Button 
$cpubutton.BackColor = "#5bd22c" 
$cpubutton.Text = "Cpu Utlization"  
$cpubutton.Width = 80 
$cpubutton.Height = 22 
$cpubutton.location = new-object system.drawing.point(400,50) 
$cpubutton.Font = "Microsoft Sans Serif,8" 
$cpubutton.Add_Click({cpu}) 
$Form.controls.Add($cpubutton) 
 
$HWSbutton = New-Object system.windows.Forms.Button 
$HWSbutton.BackColor = "#5bd22c" 
$HWSbutton.Text = "Get-HWSerial" 
$HWSbutton.Width = 80 
$HWSbutton.Height = 22 
$HWSbutton.location = new-object system.drawing.point(400,140) 
$HWSbutton.Font = "Microsoft Sans Serif,9" 
$HWSbutton.Add_Click({Get-hwserial}) 
$Form.controls.Add($HWSbutton) 
 
$Membutton = New-Object system.windows.Forms.Button 
$Membutton.BackColor = "#5bd22c" 
$Membutton.Text = "Memmoryuse" 
$Membutton.Width = 80 
$Membutton.Height = 22 
$Membutton.location = new-object system.drawing.point(400,80) 
$Membutton.Font = "Microsoft Sans Serif,8" 
$Membutton.Add_Click({Memmoryuse}) 
$Form.controls.Add($Membutton) 
 
$OSVbutton = New-Object system.windows.Forms.Button 
$OSVbutton.BackColor = "#5bd22c" 
$OSVbutton.Text = "OsVersion" 
$OSVbutton.Width = 80 
$OSVbutton.Height = 22 
$OSVbutton.location = new-object system.drawing.point(490,140) 
$OSVbutton.Font = "Microsoft Sans Serif,8" 
$OSVbutton.Add_Click({get-osv}) 
$Form.controls.Add($OSVbutton) 
 
 
$Process = New-Object system.windows.Forms.Button 
$Process.BackColor = "#5bd22c" 
$Process.Text = "Check Process" 
$Process.Width = 80 
$Process.Height = 22 
$Process.location = new-object system.drawing.point(400,110) 
$Process.Font = "Microsoft Sans Serif,8" 
$Process.Add_Click({proc}) 
$Form.controls.Add($Process) 
 
$commgmtbutton = New-Object system.windows.Forms.Button 
$commgmtbutton.BackColor = "#55e72c" 
$commgmtbutton.Text = "Compmgmt" 
$commgmtbutton.Width = 80 
$commgmtbutton.Height = 22 
$commgmtbutton.location = new-object system.drawing.point(400,170) 
$commgmtbutton.Font = "Microsoft Sans Serif,8" 
$commgmtbutton.Add_Click({sysmgmt})  
$Form.controls.Add($commgmtbutton) 
 
 
 
$LAdminbutton = New-Object system.windows.Forms.Button 
$LAdminbutton.BackColor = "#5bd22c" 
$LAdminbutton.Text = "Get-localadmins" 
$LAdminbutton.Width = 89 
$LAdminbutton.Height = 22 
$LAdminbutton.location = new-object system.drawing.point(490,21) 
$LAdminbutton.Font = "Microsoft Sans Serif,8" 
$LAdminbutton.Add_Click({Localadmins}) 
$Form.controls.Add($LAdminbutton) 
 
$DSAbutton = New-Object system.windows.Forms.Button 
$DSAbutton.BackColor = "#5bd22c" 
$DSAbutton.Text = "DSA.MSC" 
$DSAbutton.Width = 80 
$DSAbutton.Height = 22 
$DSAbutton.location = new-object system.drawing.point(490,50) 
$DSAbutton.Font = "Microsoft Sans Serif,8" 
$DSAbutton.Add_Click({dsamsc}) 
$Form.controls.Add($DSAbutton) 
 
$portbutton = New-Object system.windows.Forms.Button 
$portbutton.BackColor = "#5bd22c" 
$portbutton.Text = "Port check" 
$portbutton.Width = 80 
$portbutton.Height = 22 
$portbutton.location = new-object system.drawing.point(490,80) 
$portbutton.Font = "Microsoft Sans Serif,8" 
$portbutton.Add_Click({Get-portstatus}) 
$Form.controls.Add($portbutton) 
 
 
$Remoteshutbutton = New-Object system.windows.Forms.Button 
$Remoteshutbutton.BackColor = "#e3211d" 
$Remoteshutbutton.Text = "RemoteShutdown" 
$Remoteshutbutton.Width = 88 
$Remoteshutbutton.Height = 22 
$Remoteshutbutton.location = new-object system.drawing.point(490,110) 
$Remoteshutbutton.Font = "Microsoft Sans Serif,7" 
$Remoteshutbutton.Add_Click({poweroff}) 
$Form.controls.Add($Remoteshutbutton) 
 
 
 
$Hotfixbutton= New-Object system.windows.Forms.Button 
$Hotfixbutton.BackColor = "#5bd22c" 
$Hotfixbutton.Text = "Hotfix" 
$Hotfixbutton.Width = 80 
$Hotfixbutton.Height = 22 
$Hotfixbutton.location = new-object system.drawing.point(490,170) 
$Hotfixbutton.Font = "Microsoft Sans Serif,8" 
$Hotfixbutton.Add_Click({Get-update}) 
$Form.controls.Add($Hotfixbutton) 
 
 
$exitbutton = New-Object system.windows.Forms.Button 
$exitbutton.BackColor = "#5bd22c" 
$exitbutton.Text = "Exit" 
$exitbutton.Width = 80 
$exitbutton.Height = 22 
$exitbutton.location = new-object system.drawing.point(600,20) 
$exitbutton.Font = "Microsoft Sans Serif,8" 
$exitbutton.Add_Click({$form.close()}) 
$Form.controls.Add($exitbutton) 
 
 
 
 
###################This function is to dispaly the progress############################ 
Function Progressbar 
{ 
Add-Type -AssemblyName system.windows.forms 
$Script:formt = New-Object System.Windows.Forms.Form 
$Script:formt.Text = 'Please Wait' 
$Script:formt.TopMost = $true 
$Script:formt.StartPosition ="CenterScreen" 
$Script:formt.Width = 500 
$Script:formt.Height = 20 
$Script:formt.MaximizeBox = $false 
$Script:formt.MinimizeBox = $false 
$Script:formt.Visible = $false 
 
 
} 
 
############################################## End of Progressbar function############# 
 
 
 
############################################## PingFunction############# 
 
function pingInfo { 
progressbar 
$outputBox.Clear() 
$outputBox.text= "Pining the servers please wait" 
$computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
 $infping =@() 
foreach ($computer in $computers) 
{ 
 
$Script:formt.text="Working on $computer" 
$infping +=ping  $computer -n 3  
$pingResult=$infping| ft | out-string 
} 
$outputBox.Appendtext("{0}`n" -f $pingResult + "`n $ct") 
$Script:formt.close() 
} 
                      
####################end pingInfo######################################## 
 
 
 
####################################Uptime function start#################################### 
 
function get-uptime { 
 param( 
 $computername =$env:computername 
 ) 
 
 $os = Get-WmiObject win32_operatingsystem -ComputerName $computername -ea silentlycontinue 
 if($os){ 
 $lastbootuptime =$os.ConvertTodateTime($os.LastBootUpTime) 
 
 $LocalDateTime =$os.ConvertTodateTime($os.LocalDateTime) 
 
 $up =$LocalDateTime - $lastbootuptime 
 
 $uptime ="$($up.Days) days, $($up.Hours)h, $($up.Minutes)mins" 
 
 $results =new-object psobject 
 
 $results |Add-Member noteproperty LastBootUptime $LastBootuptime 
 $results |Add-Member noteproperty ComputerName $computername 
 $results |Add-Member noteproperty uptime $uptime 
 
 
 #Display the results 
 
 $results | Select-Object computername,LastBootuptime,Uptime 
 
 } 
 
 
 else 
 
 { 
 
 $results =New-Object psobject 
 
 $results =new-object psobject 
 $results |Add-Member noteproperty LastBootUptime "Na" 
 $results |Add-Member noteproperty ComputerName $computername 
 $results |Add-Member noteproperty uptime "Na" 
 
 #display the results 
 
 $results | Select-Object computername,LastBootUptime,Uptime 
 
 
 
 
 } 
 
 
 
 } 
 
 $infouptime =@() 
 
 
 foreach($allserver in $allservers){ 
 
 $infouptime += get-uptime $allserver 
 } 
 
 $infouptime 
 
 
 
function uptime { 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Uptime Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date = Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
 $infouptime = @() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $infouptime +=  get-uptime $computer  
 
 $res =$infouptime | ft -AutoSize | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $res +"`n $ct"  )  
  
  $Script:formt.close()  
 } 
 
 
    
 
####################################Uptime function end#################################### 
 
 
 
 
#####################################Disk Functions start############################################ 
    Function Dinfo ($ComputerName=$ENV:ComputerName) {  
  
 foreach ($disk in $ComputerName){ 
Get-WmiObject win32_logicaldisk -ComputerName $ComputerName -Filter "Drivetype=3"  | 
 Select-Object @{Label = "ServerName";Expression = {$_.__Server}},   
@{Label = "Drive Letter";Expression = {$_.DeviceID}},   
@{Label = "Total Capacity (GB)";Expression = {"{0:N1}" -f( $_.Size / 1gb)}},   
@{Label = "Free Space (GB)";Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) }},   
@{Label="FreeSpace%"; Expression={"{0:N0}" -F (($_.Freespace/$_.Size)*100)}}  
} 
} 
    
 
 function disk { 
 progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Drive  status Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
 $infod=@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $infod +=  Dinfo  $computer  
$dpres= $infod | ft -AutoSize | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $dpres +"`n $ct"  )  
 
  
 $Script:formt.close()  
  
} 
 
    
 
#####################################Disk Functions start############################################ 
  
 
 
 ###############################Remote shutdown##################################### 
function poweroff{ 
 
$po=shutdown -i 
Write-Host $po 
} 
 
 
function sysmgmt{ 
$outputBox.Text ="opening mmc console for computer management Please wait" 
$cm= compmgmt.msc 
Write-Host $cm 
} 
 
 
function dsamsc{ 
$outputBox.Text ="opening DSA.MSC console for computer management Please wait" 
$cm= DSA.msc 
Write-Host $cm 
} 
 
 ###############################Remote shutdown END ##################################### 
 
 
 
 
 
##################################Service function################################# 
 
function Service{ 
progressbar 
 
$outputBox.Clear() 
$outputBox.Text = "Getting Service status please wait" 
$computers=$InputBox.lines.Split("`n") 
$sname =$filterbox.text 
$date =Get-Date 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
  $infserv =@() 
foreach ($computer in $computers) 
{ 
$Script:formt.text="Working on $computer" 
#$s= Get-Service -ComputerName $computer -Name $sname|  Select-Object MachineName,Name,Status | ft -AutoSize | Out-String 
$infserv +=Get-WmiObject -Class win32_service  -ComputerName $computer   -Filter "Name Like '%$sname%'" |  Select-Object PSComputerName,Name,StartMode,State  
$s = $infserv| ft -AutoSize | Out-String 
} 
$outputBox.Appendtext("{0}`n" -f $s+"`n $ct") 
$Script:formt.close()  
 
} 
 
 
##################################Service function end ################################# 
 
 
  
  
####################################################memmoryFunctions ###start#########################   
  
   
 
    
                Function Get-MemmoryUtlizatio ($ComputerName=$ENV:ComputerName) { 
                Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName |  
                Select @{Name="Servername";Expression =  {$_.__Server}},  
                @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}},  
                @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}}, 
                @{Name = "PercentFree%"; Expression = {[math]::Round(($_.FreePhysicalMemory/$_.TotalVisibleMemorySize)*100,2)}}  
                }  
 
  
 
  
 
  
function Memmoryuse { 
 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Memmory Useage Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
$Script:formt.Visible=$true 
 $infoms =@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $infoms +=  Get-MemmoryUtlizatio $computer 
 $mres = $infoms |ft -AutoSize | Out-String   
  } 
 $outputBox.Appendtext("{0}`n" -f   $mres  + "`n $ct"  )  
 
 $Script:formt.close()  
 } 
 
####################################memmory function end##################################################### 
 
 
####################################################Installed Appst########################################## 
  
 
 
function Get-InstalledApps 
{ 
   [CmdletBinding()] 
   [OutputType([int])] 
   Param 
   ( 
       
      [Parameter(Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true, 
      Position=0)] 
      $computer 
   ) 
  
   Begin 
   { 
   } 
  
   Process 
   { 
      $win32_product = @(get-wmiobject -class ‘Win32_Product’   -computer $computer) 
  
      foreach ($app in $win32_product){ 
         $applications = New-Object PSObject -Property @{ 
         Name = $app.Name 
         Version = $app.Version 
         InstallDate=$app.InstallDate 
         Computername=$app.PSComputerName  
         } 
  
         Write-Output $applications | Select-Object Computername,Name,Version, InstallDate 
      } 
   } 
  
   End 
   { 
   } 
} 
 
 
 
 
function Applist { 
 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Installed appliations Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $m =  Get-InstalledApps $computer |Out-String 
 Write-Host $m | ft -AutoSize 
   
 $outputBox.Appendtext("{0}`n" -f $m +"`n $ct"  )  
  $Script:formt.close()  
 } 
 
 
   }   
####################################################Installed Appstend#############################################  
 
######################################################################   
# Powershell script to get the the Services on remote servers   
# It will give the services status  
# Customized script useful to every one   
# Please contact  btstevens1984az@gmail.com for any suggestions#   
#########################################################################   
  
 
 
function Get-servies 
{ 
   [CmdletBinding()] 
   [OutputType([int])] 
   Param 
   ( 
       
      [Parameter(Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true, 
      Position=0)] 
      $computer 
   ) 
  
   Begin 
   { 
   } 
  
   Process 
   { 
      $win32_product = @(get-wmiobject -class  ‘win32_service’   -computer $computer)  
  
      foreach ($app in $win32_product){ 
         $applications = New-Object PSObject -Property @{ 
         Name = $app.Name 
        StartMode = $app.StartMode  
         State=$app.State 
         Computername=$app.PSComputerName  
         } 
  
         Write-Output $applications | Select-Object Computername,Name,StartMode, State 
      } 
   } 
  
   End 
   { 
   } 
} 
 
 
 
 
function Get-ser { 
 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Services status Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
 $infser =@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
$infser +=  Get-servies $computer  
$sl = $infser| ft -AutoSize |Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $sl +"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 
    
 
   ####function end### 
 
 
 
#########################################HOTFIX################################ 
function Get-hotfixes 
{ 
   [CmdletBinding()] 
   [OutputType([int])] 
   Param 
   ( 
       
      [Parameter(Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true, 
      Position=0)] 
      $computer 
   ) 
  
   Begin 
   { 
   } 
  
   Process 
   { 
      $win32_product = @(get-wmiobject -class  ‘Win32_QuickfixEngineering’   -computer $computer)  
  
      foreach ($app in $win32_product){ 
         $applications = New-Object PSObject -Property @{ 
         Name = $app.Name 
        Description  = $app.Description  
         HotFixID=$app.HotFixID 
         InstalledBy=$app.InstalledBy 
         InstalledOn=$app.InstalledOn 
         Computername=$app.PSComputerName  
         } 
  
         Write-Output $applications | Select-Object Computername,HotFixID ,InstalledBy, InstalledOn 
      } 
   } 
  
   End 
   { 
   } 
} 
 
 
function Get-update { 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting windows updates list Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $m =  Get-hotfixes  $computer | ft -AutoSize|Out-String 
  
   
 $outputBox.Appendtext("{0}`n" -f $m +"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 
   }  
 
#########################################HOTFIXEND################################ 
 
 
 
############################################OSTYPE##################################### 
 
function Get-ostype 
{ 
   [CmdletBinding()] 
   [OutputType([int])] 
   Param 
   ( 
       
      [Parameter(Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true, 
      Position=0)] 
      $computer 
   ) 
  
   Begin 
   { 
   } 
  
   Process 
   { 
      $win32_product = @(get-wmiobject -class  ‘ Win32_OperatingSystem ’   -computer $computer)  
  
      foreach ($app in $win32_product){ 
         $applications = New-Object PSObject -Property @{ 
         Name = $app.Name 
        caption = $app.caption  
         OSArchitecture=$app.OSArchitecture 
         ServicePackMajorVersion=$app.ServicePackMajorVersion 
          Computername=$app.PSComputerName  
         } 
  
         Write-Output $applications | Select-Object Computername, caption,OSArchitecture, ServicePackMajorVersion 
      } 
   } 
  
   End 
   { 
   } 
} 
 
 
function Get-osv { 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting OS version Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
 $osver =@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $osver +=  Get-ostype $computer  
 $osvr = $osver | ft -AutoSize|Out-String 
 } 
 $outputBox.Appendtext("{0}`n" -f $osvr+"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 
    
 
############################################OSTYPE##################################### 
 
 
 
 
 
 
####################serial start#################################################################### 
 
 function get-serial { 
 param( 
 $computername =$env:computername 
 ) 
 
 $os = Get-WmiObject Win32_bios -ComputerName $computername -ea silentlycontinue 
 if($os){ 
 
 $SerialNumber =$os.SerialNumber 
 
 $servername=$os.PSComputerName  
  
 
  
 
 $results =new-object psobject 
 
 $results |Add-Member noteproperty SerialNumber  $SerialNumber 
 $results |Add-Member noteproperty ComputerName  $servername 
  
 
 
 #Display the results 
 
 $results | Select-Object computername,SerialNumber 
 
 } 
 
 
 else 
 
 { 
 
 $results =New-Object psobject 
 
 $results =new-object psobject 
 $results |Add-Member noteproperty SerialNumber "Na" 
 $results |Add-Member noteproperty ComputerName $servername 
 
 
  
 #display the results 
 
 $results | Select-Object computername,SerialNumber 
 
 
 
 
 } 
 
 
 
 } 
 
 $infserial =@() 
 
 
 foreach($allserver in $allservers){ 
 
$infserial += get-serial $allserver  
 } 
 
 $infserial  
 
 
function Get-hwserial { 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Serialnumbers Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
 $infserial =@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $infserial +=  Get-serial $computer  
 $res = $infserial | ft -AutoSize | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $res +"`n $ct"  )  
  $Script:formt.close()  
  
 } 
 
 
    
 
 
####################serial start############################################################### 
 
 
#############Bios start####################################################################### 
function get-Bios { 
 param( 
 $computername =$env:computername 
 ) 
 
 $os = Get-WmiObject Win32_bios -ComputerName $computername -ea silentlycontinue 
 if($os){ 
 
   $SerialNumber =$os.SerialNumber 
   $servername=$os.PSComputerName  
   $Name= $os.Name 
   $SMBIOSBIOSVersion=$os.SMBIOSBIOSVersion 
   $Manufacturer=$os.Manufacturer 
 
 
 
 
 $results =new-object psobject 
 
 $results |Add-Member noteproperty SerialNumber  $SerialNumber 
 $results |Add-Member noteproperty ComputerName  $servername 
 $results |Add-Member noteproperty Name  $Name 
 $results |Add-Member noteproperty SMBIOSBIOSVersion  $SMBIOSBIOSVersion 
 $results |Add-Member noteproperty Manufacture   $Manufacture 
  
 
 
 #Display the results 
 
 $results | Select-Object computername,SMBIOSBIOSVersion,Name,Manufacture ,SerialNumber 
 
 } 
 
 
 else 
 
 { 
 
  
 $results =new-object psobject 
 
 $results |Add-Member noteproperty SerialNumber "Na" 
 $results |Add-Member noteproperty ComputerName $servername 
  $results |Add-Member noteproperty Name  $Name 
 $results |Add-Member noteproperty SMBIOSBIOSVersion  $SMBIOSBIOSVersion 
 $results |Add-Member noteproperty Manufacture   $Manufacture 
 
 
  
 #display the results 
 
 
 $results | Select-Object computername,SMBIOSBIOSVersion,Name,Manufacture ,SerialNumber 
 
 
 
 
 } 
 
 
 
 } 
 
 $infbios =@() 
 
 
 foreach($allserver in $allservers){ 
 
 $infbios += get-Bios $allserver  
 } 
 
 $infbios 
 
 
 
 function bios { 
 progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Bios details Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
  $infbios =@() 
 foreach ($computer in $computers) 
 { 
  $Script:formt.text="Working on $computer" 
 $infbios +=  get-Bios $computer  
 $res =  $infbios | ft -AutoSize | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $res +"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 
 
 
 
#############################Bios start####################################################################### 
 
###############################################pstart########################################### 
 
function checkport { 
 param( 
 $computername =$env:computername 
 ) 
  $sname =$filterbox.text 
 $os = Test-NetConnection -ComputerName $computername -port $sname -ea silentlycontinue 
 if($os){ 
 
 $TcpTestSucceeded =$os.TcpTestSucceeded 
 
 $servername=$os.ComputerName 
  
 
  
 
 $results =new-object psobject 
 
 $results |Add-Member noteproperty TcpTestSucceeded  $TcpTestSucceeded 
 $results |Add-Member noteproperty ComputerName  $servername 
  
 
 
 #Display the results 
 
 $results | Select-Object computername,TcpTestSucceeded 
 
 } 
 
 
 else 
 
 { 
 
 $results =New-Object psobject 
 
 $results =new-object psobject 
 $results |Add-Member noteproperty TcpTestSucceeded "Na" 
 $results |Add-Member noteproperty ComputerName $servername 
 
 
  
 #display the results 
 
 $results | Select-Object computername,TcpTestSucceeded 
 
 
 
 
 } 
 
 
 
 } 
 
 $infoport =@() 
 
 
 foreach($allserver in $allservers){ 
 
$infoport += checkport $allserver  
 } 
 
 $infoport 
 
 
function Get-portstatus { 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Checking  Port status Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
  $infoport =@() 
 foreach ($computer in $computers) 
 { 
  $Script:formt.text="Working on $computer" 
 $infoport +=  checkport $computer  
 $pres=  $infoport| ft -AutoSize  | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $pres +"`n $ct")  
 $Script:formt.close() 
 } 
 
 
    
 
 
###############################################pstartend########################################### 
 
 
function exit{ 
  $global:QUIT = $true 
   
  $objForm.Close() 
} 
 
 
 
 
############local admin start########### 
 
function get-localadmin {   
param ($computerName)   
   
$admins = Gwmi win32_groupuser –computer $computerName    
$admins = $admins |? {$_.groupcomponent –like '*"Administrators"'}   
   
$admins |% {   
$_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul   
$matches[1].trim('"') + “\” + $matches[2].trim('"')   
}   
} 
 
 
 $inflocaladmin =@() 
 
 
 foreach($allserver in $allservers){ 
 
 $inflocaladmin += get-localadmin  $allserver  
 } 
 
  $inflocaladmin 
 
 
function Localadmins{ 
progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Local admins list Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
 $Script:formt.Visible=$true 
  $inflocaladmin =@() 
 foreach ($computer in $computers) 
 { 
 $Script:formt.text="Working on $computer" 
 $inflocaladmin +=  get-localadmin  $computer 
$infres = $inflocaladmin|  ft -AutoSize|Out-String 
} 
 $outputBox.Appendtext("{0}`n" -f $infres +"`n $ct"  )  
  
  $Script:formt.close()  
 } 
 
    
 
   ############local admin function ends########### 
 
 
 
 
 
 
################CPU Function Start############################################# 
 
 
 
 
 
 
function Get-Cpu{  
                 param(  
                 $computername =$env:computername  
                 )  
                 $os = gwmi win32_perfformatteddata_perfos_processor -ComputerName $computername| ? {$_.name -eq "_total"} | select -ExpandProperty PercentProcessorTime  -ea silentlycontinue  
                 if(($os -match '\d+') -or ($os -eq '0')){  
                 $results =new-object psobject  
                 $results |Add-Member noteproperty Cputil  $os  
                 $results |Add-Member noteproperty ComputerName  $computername   
                 $results | Select-Object computername,Cputil  
                 }  
                 else{  
                 $results =new-object psobject  
                 $results |Add-Member noteproperty Cputil  "Na"  
                 $results |Add-Member noteproperty ComputerName  $computername   
                 $results | Select-Object computername,Cputil  
                 }  
                 }   
 
 
 
  function cpu { 
  progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting cpu details Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
  $infcpu =@() 
 foreach ($computer in $computers) 
 
 { 
 $Script:formt.text="Working on $computer" 
 $infcpu +=  get-Cpu  $computer  
 $res =  $infcpu | ft -AutoSize | Out-String 
  } 
 $outputBox.Appendtext("{0}`n" -f $res +"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 ################CPU Function end############################################# 
 
 
##################Processfunction Start######################################## 
 
 Function Processutil ($computerName=$env:COMPUTERNAME) { 
 
              if ($osp = Get-wmiobject win32_process -ComputerName $ComputerName | where{$_.name -like "*$sname*"}  | Sort ws -desc | ft Pscomputername,Name,ProcessId,@{Name="Mem Useage (MB)";Expression={[math]::round($_.ws / 1mb)}} -AutoSize ) 
                  { 
                  $osp 
                 } 
                 else 
                  { 
                  $outputbox.text = "Server offlne or no process running" 
                  } 
                  } 
 
  
 function proc { 
 
 progressbar 
 $outputBox.Clear() 
 $outputBox.Text ="Getting Process info  Please wait" 
 $computers=$InputBox.lines.Split("`n") 
 $date =Get-Date 
 $sname =$filterbox.text 
 $ct = "Task Completed @ " + $date 
  $Script:formt.Visible=$true 
 $infproc =@() 
 foreach ($computer in $computers) 
  { 
 $Script:formt.text="Working on $computer" 
 $infproc +=  Processutil  $computer  
 $pres = $infproc| ft -AutoSize | Out-String 
 } 
 $outputBox.Appendtext("{0}`n" -f $pres +"`n $ct"  )  
 $Script:formt.close()  
 } 
 
 
  
##################Processfunction Start######################################## 





 
function SAeventlogs{ 
progressbar 
$outputBox.Clear() 
$outputBox.text= "Getting Eventlogs please wait" 
$date=Get-Date 
$computers=$InputBox.lines.Split("`n") 
$evs =$Dropdown.SelectedItem.ToString() 
$app= $evs
$args = @{}
$args.Add("StartTime", ((Get-Date).AddHours(-24)))
$args.Add("EndTime", (Get-Date))
$args.Add("LogName", $app)
$ct = "Task Completed @ " + $date 
$sname =$filterbox.text 
$Script:formt.Visible=$true 
$infev =@() 
foreach ($computer in $computers) 
{ 
$Script:formt.text="Working on $computer" 
$infev += Get-winevent   -FilterHashtable $args -ComputerName $computer| Where-Object {($_.Message -match "$sname") -or ($_.ID -match "$sname")} |Select-Object Machinename,ID,Timecreated,Message 
$evResult =$infev | ft -AutoSize | Out-String 
} 
$outputBox.Appendtext("{0}`n" -f $evResult + "`n $ct") 
$Script:formt.close() 
} 
 
 
 
[void]$Form.ShowDialog() 
$Form.Dispose()