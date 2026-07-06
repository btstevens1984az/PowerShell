# Purpose: AD-ChangePassword — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

$SearchUser = Read-Host -Prompt 'Search user'
    $Users = Get-Aduser -Filter "anr -like '$SearchUser'"
    if ($Users.count -gt 1){
        Write-Host 'Multiple users were found.' -ForegroundColor Red -BackgroundColor Yellow
        Write-Host 'Please select a user:' -ForegroundColor Red -BackgroundColor Yellow
        for($i = 0; $i -lt $Users.count; $i++){
            Write-Host "$($i): $($Users[$i].SamAccountName) | $($Users[$i].Name)"
        }
        $selection = Read-Host -Prompt 'Select user (0, 1, 2 etc.)'
        $ResultUser = $Users[$selection]
    }

Get-ADUser $ResultUser -Properties * | Select-Object Name, pass*

$Pass = Read-Host -Prompt 'New Password'

Set-ADAccountPassword -Identity $ResultUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force) | Unlock-ADAccount –Identity $ResultUser

