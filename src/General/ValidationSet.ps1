# Purpose: ValidationSet — General-purpose PowerShell utilities.
Function New-MyUserAccount
{
    param(
            [parameter(Mandatory)]
            [string]$username,
            [validateSet('Contoso','NwTraders','FourthCoffee')]
            [string]$Domainname="Contoso",
            [switch]$force)

            "New User $username created in:$Domainname"
    
}
New-MyUserAccount -username jeff -Domainname FourthCoffee2

#[validateSet('Contoso','NwTraders','FourthCoffee')]$whatever =$test
#$whatever = "test"