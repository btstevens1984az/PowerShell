# Purpose: MISC-OutlookProfileKill — 177.240.246.94 Online mailbox and mail flow administration.
#   James Wylde 2020

#----------------------------------------------------------------------------------------#
#   Modules


    Get-ChildItem $env:LOCALAPPDATA\Microsoft\Outlook\* -Include *.ost, *.nst, *.pst | Remove-Item
    Set-Location HKCU:
    $Profiles = Get-ChildItem 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Profiles' |ForEach-Object {
        Get-ChildItem $_.Name |ForEach-Object {
            Get-ChildItem -Path $_.Name
        } 
    }
     
    foreach($Profile in $Profiles){
        try{
            $AccountName = Get-ItemPropertyValue -Path $Profile.Name -Name 'Account Name' -ErrorAction Stop
            if($AccountName $AccountName -like '*@*'){
                'HKCU:\' + ($Profile.Name.Split('\')[1..7] -join '\') | Remove-Item -Recurse
            }
        }catch{
            Continue
        }
    }



    #   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules


$pcName = Read-Host "Asset number"
$userName = Read-Host "Username"

Invoke-Command -ComputerName $pcName -ScriptBlock {

Get-Process Lync* | Stop-Process -f
Stop-Process -Name Outlook -Force
taskkill /f /im ucmapi.exe
Remove-Item -Path "C:\Users\$using:userName\AppData\Local\Microsoft\Office\16.0\Lync*" 

Start-Sleep -S 5

Move-Item -Path "C:\Users\$using:userName\AppData\Local\Microsoft\Outlook\*" -Destination 'C:\temp\' -Force

Remove-Item -Path "C:\Users\$using:userName\AppData\Local\Microsoft\Outlook\*" 
}