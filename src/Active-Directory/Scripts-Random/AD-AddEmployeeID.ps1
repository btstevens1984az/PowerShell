# Purpose: AD-AddEmployeeID — Active Directory user, group, and domain administration.
#   James Wylde #

#----------------------------------------------------------------------------------------#
#   Modules
Import-Module ActiveDirectory

Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '**ENSURE RELEVANT PERMISSIONS HAVE BEEN SOUGHT BEFORE PROCEEDING**' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Write-Host - '******************************************************************' -ForegroundColor White -BackgroundColor Red
Read-Host -Prompt "Press ENTER to continue...."

$SearchUser = Read-Host -Prompt 'Search user'
    $Users = Get-Aduser -Filter "anr -like '$SearchUser'"
    if ($Users.count -gt 1){
        Write-Host 'Multiple users were found.' -ForegroundColor Red -BackgroundColor Yellow
        Write-Host 'Please select a user:' -ForegroundColor Red -BackgroundColor Yellow
        for($i = 0; $i -lt $Users.count; $i++){
            Write-Host "$($i): $($Users[$i].SamAccountName) | $($Users[$i].Name) | $($Users[$i].EmployeeID)"
        }
        $selection = Read-Host -Prompt 'Select user (0, 1, 2 etc.)'
        $ResultUser = $Users[$selection]
    }

Write-Host - ' '
$CurrentEmployeeNo = Get-ADUser $ResultUser -Properties employeeid | Select-Object employeeID
Write-Host - 'Current employee number:' $CurrentEmployeeNo

$EID = Read-Host -Prompt 'New employee number:'
    if ($EID) { 
        Write-Host = "Employee ID change successful." -ForegroundColor White -BackgroundColor Green
    } 
    else { 
        Write-Host = "Employee ID change unsuccessful." -ForegroundColor White -BackgroundColor Red
    }

Set-ADUser $ResultUser -EmployeeID $EID

