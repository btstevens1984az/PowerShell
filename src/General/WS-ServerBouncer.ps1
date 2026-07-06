# Purpose: WS-ServerBouncer — General-purpose PowerShell utilities.
<#
SYNOPSIS:
   Scheduled OMP bouncer tool - diagnostics and automated logins
   James Wylde - admin@example.com
VERSION:
   0.1
FUNCTIONALITY:
   Check if up, uptime and logged on users, server performance, kick all titled applications and kick all logged on users, reboot all, log in three users per three servers.
#>


#----------------------------------------------------------------------------------------#
#   Modules

Clear-Host


#----------------------------------------------------------------------------------------#
#   Vars

#$ompM1222 = Server1
#$ompM1213 = Server2
#$ompM1214 = Server3


#----------------------------------------------------------------------------------------#
#   Landing


Write-Host "`n `r "
Read-Host -Prompt "    Connect to Servers... "


#----------------------------------------------------------------------------------------#
#   Menu bulk

function Show-Menu
{
     param (
           [string]$Title = "Server Bouncer 5000"
     )
     Clear-Host
     Write-Host "`n `r "
     Write-Host "    $Title"
     Write-Host "`n `r "
     Write-Host "    1 - Ping."
     Write-Host "    2 - Uptime and current users."
#     Write-Host " 3 - CPU and MEMORY"
     Write-Host "    3 - Kill all apps and kick all users." 
     Write-Host "    4 - Reboot." 
     Write-Host "    5 - Log in."
     Write-Host "`n `r "
     Write-Host "    Q - Quit."
     Write-Host "`n `r "
}

#----------------------------------------------------------------------------------------#
#   Functions


Function function1 {

     Write-Host "    Pinging: Server1"
     ping Server1
     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Pinging: Server2"
     ping Server2
     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Pinging: Server3"
     ping Server3
     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Pinging: Server4"
     ping Server4

     
}

Function function2 {

     Write-Host "    Logged on users and uptime: Server1"
     SystemInfo /s Server1 | find "Boot Time:"
     Write-Host "`n `r "
     query user /server:Server1

     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Logged on users and uptime: Server2"
     SystemInfo /s Server2 | find "Boot Time:"
     Write-Host "`n `r "
     query user /server:Server2 

     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Logged on users and uptime: Server3"
     SystemInfo /s Server3 | find "Boot Time:"
     Write-Host "`n `r "
     query user /server:Server3 

     Write-Host "`n `r "
     Write-Host "`n `r "

     Write-Host "    Logged on users and uptime: Server4"
     SystemInfo /s Server4 | find "Boot Time:"
     Write-Host "`n `r "
     query user /server:Server4


     Write-Host "`n `r "
}


Function function4 {

     Write-Host "`n `r "

     Write-Host "    #######################################################   " -ForegroundColor White -BackgroundColor Red
     Write-Host "    # PROCEEDING WILL EFFECT LIVE SERVERS - ARE YOU SURE? #   " -ForegroundColor White -BackgroundColor Red
     Write-Host "    #######################################################   " -ForegroundColor White -BackgroundColor Red

     Write-Host "`n `r "


     $input2 = Read-Host "    Close all applications and kick all users from, M1222, M1213, M1214? [y/n]" 
     switch($input2){
               y{     Write-Host "    Ending applications and kicking all users..."

               Invoke-Command -ComputerName 216.168.202.140 -ScriptBlock {Get-Process  -ComputerName 216.168.202.140 | Where-Object {$_.MainWindowTitle -ne ""} | Stop-Process}
          
               Invoke-Command -ComputerName 63.53.28.206 -ScriptBlock {Get-Process  -ComputerName 63.53.28.206 | Where-Object {$_.MainWindowTitle -ne ""} | Stop-Process}
          
               Invoke-Command -ComputerName 193.35.209.88 -ScriptBlock {Get-Process  -ComputerName 193.35.209.88 | Where-Object {$_.MainWindowTitle -ne ""} | Stop-Process}

#               Invoke-Command -ComputerName 81.146.80.17 -ScriptBlock {Get-Process  -ComputerName 193.35.209.88 | Where-Object {$_.MainWindowTitle -ne ""} | Stop-Process}
          
               Start-Sleep -Seconds 10
          
               Invoke-Command -ComputerName 216.168.202.140 -ScriptBlock { logoff 1 }
               Invoke-Command -ComputerName 216.168.202.140 -ScriptBlock { logoff 2 }
               Invoke-Command -ComputerName 216.168.202.140 -ScriptBlock { logoff 3 }
               Invoke-Command -ComputerName 216.168.202.140 -ScriptBlock { logoff 4 }
          
               Invoke-Command -ComputerName 63.53.28.206 -ScriptBlock { logoff 1 }
               Invoke-Command -ComputerName 63.53.28.206 -ScriptBlock { logoff 2 }
               Invoke-Command -ComputerName 63.53.28.206 -ScriptBlock { logoff 3 }
               Invoke-Command -ComputerName 63.53.28.206 -ScriptBlock { logoff 4 }
          
               Invoke-Command -ComputerName 193.35.209.88 -ScriptBlock { logoff 1 }
               Invoke-Command -ComputerName 193.35.209.88 -ScriptBlock { logoff 2 }
               Invoke-Command -ComputerName 193.35.209.88 -ScriptBlock { logoff 3 }
               Invoke-Command -ComputerName 193.35.209.88 -ScriptBlock { logoff 4 }

#               Invoke-Command -ComputerName 81.146.80.17 -ScriptBlock { logoff 1 }
#               Invoke-Command -ComputerName 81.146.80.17 -ScriptBlock { logoff 2 }
#               Invoke-Command -ComputerName 81.146.80.17 -ScriptBlock { logoff 3 }
#               Invoke-Command -ComputerName 81.146.80.17 -ScriptBlock { logoff 4 }
          
               Write-Host "    Done."
               }
               n{return}
         default{write-warning "    Y or N only."}
     }

}
#### add confirmation


Function function5 {

     Write-Host "`n `r "

     Write-Host "    #######################################################   " -ForegroundColor White -BackgroundColor Red
     Write-Host "    # PROCEEDING WILL EFFECT LIVE SERVERS - ARE YOU SURE? #   " -ForegroundColor White -BackgroundColor Red
     Write-Host "    #######################################################   " -ForegroundColor White -BackgroundColor Red

     Write-Host "`n `r "


     $input = Read-Host "    Reboot OMP servers Server1, Server2, Server3, Server4? [y/n]" 
     switch($input){
               y{
               Write-Host "    Restarting Server1..."
               Restart-Computer 10.199.208.191 216.168.202.140 -Force -Confirm:$false

               Write-Host "    Restarting Server2..."
               Restart-Computer 10.199.208.191 63.53.28.206 -Force -Confirm:$false

               Write-Host "    Restarting Server3..."
               Restart-Computer 10.199.208.191 193.35.209.88 -Force -Confirm:$false

#               Write-Host "    Restarting Server4..."
#               Restart-Computer 10.199.208.191 193.35.209.88 -Force -Confirm:$false

               }
               n{return}
         default{write-warning "    Y or N only."}
     }

}

function function6 {


cmdkey /generic:"Server1" /user:"user" /pass:"pass"
mstsc /v:Server1

Start-Sleep -Seconds 5

cmdkey /generic:"Server1" /user:"user" /pass:"pass"
mstsc /v:Server1

Start-Sleep -Seconds 5

cmdkey /generic:"Server1" /user:"user" /pass:"pass"
mstsc /v:Server1

Start-Sleep -Seconds 5



cmdkey /generic:"Server2" /user:"user" /pass:"pass"
mstsc /v:Server2

Start-Sleep -Seconds 5

cmdkey /generic:"Server2" /user:"user" /pass:"pass"
mstsc /v:Server2

Start-Sleep -Seconds 5

cmdkey /generic:"Server2" /user:"user" /pass:"pass"
mstsc /v:Server2

Start-Sleep -Seconds 5




cmdkey /generic:"Server3" /user:"user" /pass:"pass"
mstsc /v:Server3

Start-Sleep -Seconds 5

cmdkey /generic:"Server3" /user:"user" /pass:"pass"
mstsc /v:Server3

Start-Sleep -Seconds 5

cmdkey /generic:"Server3" /user:"user" /pass:"pass"
mstsc /v:Server3

Start-Sleep -Seconds 3




#cmdkey /generic:"Server4" /user:"g2-uk-nor3-dispatch" /pass:"pass"
#mstsc /v:Server4


}


#----------------------------------------------------------------------------------------#
#    Menu key bindings

#    Notes on ('NoEcho,IncludeKeyUp') - this is currently dead when ran via ISE - apparent dependent key combo for ISE. Run in PS itself

do
{
     Show-Menu
     #$keyPress = $host.UI.RawUI.ReadKey().character        Does not work in ISE
     $keyPress = Read-Host
     switch ($keyPress)
     {
           '1' {
                Clear-Host
                function1
            } '2' {
                Clear-Host
                function2    
            } '3' {
                Clear-Host
                function4
            } '4' {
                Clear-Host 
                function5
            } '5' {
                Clear-Host 
                function6
           } 'q' {
                return
           }
     }
     pause
}
until ($keyPress -eq 'q')



#----------------------------------------------------------------------------------------#
#   Scraps

#     $wmi_uptime = Get-WmiObject Win32_OperatingSystem -computer 216.168.202.140
#     [System.Math]::Round(($wmi_uptime.ConvertToDateTime($wmi_uptime.LocalDateTime) â€“ $wmi_uptime.ConvertToDateTime($wmi_uptime.LastBootUpTime)).Minutes,0)



#----------------------------------------------------------------------------------------##
#   CMDkeys
