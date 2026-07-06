# Purpose: MISC-DirectAccess Resolver — General-purpose PowerShell utilities.
<#
SYNOPSIS:
   DirectAccess resolver with GUI for end-user resolution / troubleshooting.
   James Wylde
VERSION:
   0.1
FUNCTIONALITY:
   DirectAccess resolver with GUI. Stop / Start associated services [iphlpsvc & NcaSvc] > IPV6 release and forced reboot > Connection diagnosis > Recommended actions
#>

#----------------------------------------------------------------------------------------#

#  Execution policy

# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass


#----------------------------------------------------------------------------------------#

#   Lost and Found Vars

$newLine = Write-Host "`r`n"

$dest = "http://speed.transip.nl/10mb.bin"

$proxy = ([System.Net.WebRequest]::GetSystemWebproxy()).GetProxy($dest)

$service = Get-Service -Name iphlpsvc

$serviceStatus = $service.Status

$passCheck = net user $env:USERNAME /domain | find "Password expires"

$dateIs = Get-Date -f "dd/MM/yyyy, hh:MM:ss"



#----------------------------------------------------------------------------------------#

#   GUI objects

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

$mainForm = New-Object System.Windows.Forms.Form
$textBox = New-Object System.Windows.Forms.RichTextBox
$textBox2 = New-Object System.Windows.Forms.RichTextBox
$textBox3 = New-Object System.Windows.Forms.RichTextBox
$daResolver = New-Object System.Windows.Forms.Button
$daReboot = New-Object System.Windows.Forms.Button
$daDiagnostics = New-Object System.Windows.Forms.Button

#----------------------------------------------------------------------------------------#

#   Textbox OUT left

$textBox.Location = '15,10'
$textBox.AutoSize = $false 
$textBox.Size = '310,23'
$textBox.BackColor = [Drawing.Color]::White
$textBox.ReadOnly = $true
$textBox.Multiline = $true
$textBox.ForeColor = [Drawing.Color]::Blue
$textBox.Text = Write-Output " DirectAccess is currently $("$serviceStatus".ToUpper() )."
$textBox.Font = "Microsoft Sans Serif, 9pt"

#----------------------------------------------------------------------------------------#

#   Textbox OUT right

$textBox3.Location = '330,10'
$textBox3.AutoSize = $false 
$textBox3.Size = '135,23'
$textBox3.BackColor = [Drawing.Color]::White
$textBox3.ReadOnly = $true
$textBox3.Multiline = $true
$textBox3.ForeColor = [Drawing.Color]::Black
$textBox3.Text = Write-Output "  $dateIs"
$textBox3.Font = "Microsoft Sans Serif, 9pt"
#$textBox3.TextAlign = [HorizontaltAlignment]::MiddleRight


#----------------------------------------------------------------------------------------#


#   Textbox OUT bot

$textBox2.Location = '15,40'
$textBox2.AutoSize = $false 
$textBox2.Size = '450,110'
$textBox2.BackColor = [Drawing.Color]::White
$textBox2.ReadOnly = $true
$textBox2.Multiline = $true
#$textBox.ForeColor = [Drawing.Color]::Red
$textBox2.Text = Write-Output "> Select 'Resolver' to attempt a quick-fix."
$textBox2.Font = "Microsoft Sans Serif, 9pt"
$textBox2.appendText($newLine)
$textBox2.appendText($newLine)
$textBox2.appendText(">  Select 'Resolver + Reboot' to attempt a more thorough fix involving a machine restart. ")
$textBox2.appendText($newLine)
$textBox2.appendText($newLine)
$textBox2.appendText(">  Select 'Diagnostics' to attempt to troubleshoot wider issues.")


#----------------------------------------------------------------------------------------#

#   Button (M) DirectAccess Service Stop & Start

$daResolver.Text = 'Resolver'
$daResolver.Size = '140,23'
$daResolver.Font = "Microsoft Sans Serif, 9pt"
$daResolver.Location = '170,160'
$daResolver.Add_Click({
 

    $textBox2.Text = Write-Output "$newline"
    $textBox3.Text = Get-Date -f "  dd/MM/yyyy, hh:MM:ss"

    Start-Sleep -Seconds 1.5
    
    $textBox.Text = Write-Output "DirectAccess is now restarting..."

    Start-Sleep -Seconds 1.5


    Stop-Service iphlpsvc -Force
    Stop-Service NcaSvc

    Start-Sleep -Seconds 1.5

    Start-Service iphlpsvc
    Start-Service NcaSvc

    
    Start-Sleep -Seconds 45
    Clear-Host

    $textBox.Text = Write-Output "DirectAccess has finished restarting..."
   
############################################################


  # if ($serviceStatus -eq 'Stopped') {$textBox2.Text = Write-Output "DirectAccess is not running. Please run again or try 'Resolver + Restart'."}
  # else {$textBox2.Text = Write-Output "DirectAccess is now $("$serviceStatus".ToUpper() ). You can now close this application."}

   if ($serviceStatus -eq 'Running') {$textBox2.Text = Write-Output "DirectAccess is now $("$serviceStatus".ToUpper() ). You can now close this application."}
   else {$textBox2.Text = Write-Output "DirectAccess is not running - please try the 'Resolver + Reboot' option."}

############################################################

})

#----------------------------------------------------------------------------------------#

#   Button (R) iphlpsvc & NcaSvc Service Stop & Start, IPV6 release and forced reboot

$daReboot.Size = '140,23'
$daReboot.Location = '325,160'
$daReboot.text = 'Resolver + Reboot'
$daReboot.Font = "Microsoft Sans Serif, 9pt"
$daReboot.Add_Click({

    $textBox.Text = Write-Output "DirectAccess services are now restarting and IPV6 being released..."

    Start-Sleep -Seconds 0.75

    $textBox2.Text = Write-Output  "$newline"
    $textBox3.Text = Get-Date -f "  dd/MM/yyyy, hh:MM:ss"

    Start-Sleep -Seconds 0.75


    Stop-Service iphlpsvc -Force
    Stop-Service NcaSvc

    Start-Sleep -Seconds 1

    Start-Service iphlpsvc
    Start-Service NcaSvc

    Start-Sleep -Seconds 1

    ipconfig.exe /release6

    Start-Sleep -Seconds 2

    ipconfig.exe /renew6

    Start-Sleep -Seconds 25
    Clear-Host

    $textBox.Text = Write-Output "Preparing to shut down..."

    $textBox2.ForeColor = [Drawing.Color]::Red
    $textBox2.Text = Write-Output "Your machine will SHUTDOWN in 60 seconds. Please save all work."
    $textBox2.appendText($newLine)
    $textBox.appendText($newLine)
    Start-Sleep -Seconds 30

    $textBox2.appendText( "Your machine will SHUTDOWN in 30 seconds. Please save all work.")
    $textBox2.appendText($newLine)
    $textBox2.appendText($newLine)
    Start-Sleep -Seconds 15

    $textBox2.appendText( "Your machine will SHUTDOWN in 15 seconds. Please save all work.")
    $textBox2.appendText($newLine)
    $textBox2.appendText($newLine)
    Start-Sleep -Seconds 14

    $textBox2.appendText( "Shutting down...")


    Restart-Computer 131.230.190.167
})

#----------------------------------------------------------------------------------------#

#   Button (L) Run 10mb download speedtest and WIFI signal strength

$daDiagnostics.Text = 'Diagnostics'
$daDiagnostics.Size = '140,23'
$daDiagnostics.Font = "Microsoft Sans Serif, 9pt"
$daDiagnostics.Location = '15,160'
$daDiagnostics.Add_Click({

    $textBox.Text = Write-Output "Running diagnostics..."

    Start-Sleep -Seconds 1.50


    $textBox2.Text = Write-Output  "$newline"


    Start-Sleep -Seconds 1.50

# 	$wc = New-Object net.webclient; "{0:N2} Mbit/sec" -f ((10/(Measure-Command {$wc.Downloadfile('http://speed.transip.nl/10mb.bin',"c:\speedtest.test")}).TotalSeconds)*8); del c:\speedtest.test
	$speedTest = "{0:N2} Mbit/sec" -f ((10/(Measure-Command {$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest http://speed.transip.nl/10mb.bin -Proxy $proxy -ProxyUseDefaultCredentials -UseBasicParsing|Out-Null}).TotalSeconds)*8)


    $signalTest = (netsh wlan show interfaces) -Match '^\s+Signal' -Replace '^\s+Signal\s+:\s+',''

    $textBox.Text = Write-Output "Diagnostics results..."
    $textBox3.Text = Get-Date -f "  dd/MM/yyyy, hh:MM:ss"

     $textBox2.Text = Write-Output  "$passCheck "
     $textBox2.appendText($newLine)
     $textBox2.appendText("Internet speed:                  $speedTest")
     $textBox2.appendText($newLine)
     $textBox2.appendText( "WIFI signal strength:         $signalTest" )
     $textBox2.appendText($newLine)
     $textBox2.appendText($newLine)
     $textBox2.appendText( "For optimal DirectAccess performance we recommend a speed result of 10MB+ and a WIFI signal strength of 80% or higher. Please consider environmental factors to improve these should you not meet the minimum scores." )



})

#----------------------------------------------------------------------------------------#

#   Main form

$mainForm.Text = 'SK - DirectAccess Hotfix'
$mainForm.Size = "485,220"
$mainForm.FormBorderStyle = 'FixedDialog'  
$mainForm.Font = "Microsoft Sans Serif, 9pt" 


$mainForm.Controls.Add($textBox)
$mainForm.Controls.Add($textBox2)
$mainForm.Controls.Add($textBox3)
$mainForm.Controls.Add($daResolver)
$mainForm.Controls.Add($daReboot)
$mainForm.Controls.Add($daDiagnostics)  


#----------------------------------------------------------------------------------------#

#   GUI OUT

#$mainForm.ShowDialog()

[system.windows.forms.application]::run($mainform)

#----------------------------------------------------------------------------------------#

#  TBD

