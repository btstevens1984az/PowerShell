# Purpose: CheckADuser — General-purpose PowerShell utilities.
Function Check-ADUser
{
Param ($Username)

    $Username = ($Username.Split("\")[1])
    $ADRoot = [ADSI]''
    $ADSearch = New-Object System.DirectoryServices.DirectorySearcher($ADRoot) 
    $SAMAccountName = "$Username"
    $ADSearch.Filter = "(&(objectClass=user)(sAMAccountName=$SAMAccountName))"
    $Result = $ADSearch.FindAll()

    If($Result.Count -eq 0)
    {
        Write-Host "No such user on the Server" | Out-Null
        $Status = "0"
    }
    Else
    {
        Write-Host "User exist on the Server" | Out-Null
        $Status = "1"
    }
    
    $Results = New-Object Psobject
    $Results | Add-Member Noteproperty Status $Status
    Write-Output $Results    
}