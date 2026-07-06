# Purpose: Connect-Azure PoWerShell — Microsoft Azure cloud resource management.


<#    


# Script      : Connect-Azure-PoWerShell.ps1
# Author(s)   : Casey.Dedeal 
# Date        : 01/10/2020 14:39:23 
# Org         : ETC Solutions
# File Name   : Connect-Azure-PoWerShell.ps1
# Comments    :
# Assumptions :

 
SYNOPSIS           : Connect-Azure-PoWerShell.ps1
DESCRIPTION        : O365 Azure PS connect
Acknowledgements   : Open license
Limitations        : None
Known issues       : None
Credits            : Please visit: 
                          https://simplepowershell.blogspot.com
                          https://msazure365.blogspot.com

.EXAMPLE

  .\Connect-Azure-PoWerShell.ps1


  MAP:

  -----------
  #(1)_.Check to see if any return for Valid cmdlet
  #(1.1)_.Connected to O365 Azure PowerShell Module
  #(1.2)_.Add Vars Modify $company Var
  #(2)_.Catch Errors

#>

 
function Connect-Azure-PoWerShell 
{
    

# Connect Azure PowerShell with MsolService if ! Connected
Try{

 #(1)_.Check to see if any return for Valid cmdlet
 $session  = Get-MsolDomain -EA SilentlyContinue
 if ($session) {
    #(1.1)_.Connected to O365 Azure PowerShell Module
    Write-Host 'ALREADY Connected: Azure PowerShell' -f Gray -b DarkGreen

   } else {

    #(1.2)_.Add Vars Modify $company Var
     $company   = '@CloudSec365.onmicrosoft.com'
     $adminUser = "$env:USERNAME"
     $UPN =  $adminUser + $company
     Write-Host 'Connecting: Azure PowerShell' -f Gray -b DarkCyan
     $cred  = Get-Credential -Credential $UPN -ErrorAction Stop
     Connect-MsolService -Credential $cred -ErrorAction Stop | Out-Null
          }
}Catch{

 #(2)_.Catch Errors
 Write-Host "ERROR FOUND:$($PSItem.ToString())"

}
}