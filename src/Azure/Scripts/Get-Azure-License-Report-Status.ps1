# Purpose: Get-Azure License Report Status — Microsoft Azure cloud resource management.


<#     

# Script      : Get-Azure-License-Report-Status.ps1 
# Author(s)   : Casey.Dedeal  
# Date        : 01/06/2020 08:53:36  
# Org         : ETC Solutions 
# File Name   : Get-Azure-License-Report-Status.ps1 
# Comments    : Get-Azure-License-Report-Status.ps1 
# Assumptions : 

SYNOPSIS           : Get-Azure-License-Report-Status.ps1 
DESCRIPTION        : Get-Azure-License-Report-Status.ps1 
Acknowledgements   : Open license 
Limitations        : None
Known issues       : None 
Credits            : None 

.EXAMPLE
  .\Get-License-Status.ps1 

  MAP:
  -----------
  #(1)_.Function-EXO-MSOL-Connect-V1
  #(1.0)_.Connect Azure PowerShell with MsolService if ! Connected
  #(1.1)_.Check to see if any return for Valid cmdlet
  #(1.2)_.Connected to O365 Azure PowerShell Module
  #(1.3)_.Add Vars Modify $company Var
  #(1.4)_.Catch Errors
  #(2)_.Function-Get-TimeStamp
  #(3)_.Run Function-Get-License-Status-Report
  #(4)_.Run License Status Report
#> 


#(1)_.Function-EXO-MSOL-Connect-V1
function Connect-Azure-PoWerShell 
{

#(1.0)_.Connect Azure PowerShell with MsolService if ! Connected
Try{

 #(1.1)_.Check to see if any return for Valid cmdlet
 $session  = Get-MsolDomain -EA SilentlyContinue
 if ($session) {
    #(1.2)_.Connected to O365 Azure PowerShell Module
    Write-Host 'ALREADY Connected: Azure PowerShell' -f Gray

   } else {

    #(1.3)_.Add Vars Modify $company Var
     $company   = '@.onmicrosoft.com'
     $adminUser = "$env:USERNAME"
     $UPN =  $adminUser + $company
     Write-Host 'Connecting: Azure PowerShell' -f Gray -b DarkCyan
     $cred  = Get-Credential -Credential $UPN -ErrorAction Stop
     Connect-MsolService -Credential $cred -ErrorAction Stop | Out-Null
          }
}Catch{

 #(1.4)_.Catch Errors
 Write-Host "ERROR FOUND:$($PSItem.ToString())"
}}


#(2)_.Function-Get-TimeStamp
function Function-Get-TimeStamp {
    
  return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

#(3)_.Run Function-Get-License-Status-Report
function Function-Get-License-Status-Report
{
 Connect-Azure-PoWerShell
 $Options =@(

'AccountName',
'AccountSkuID',
'ActiveUnits',
'ConsumedUnits',
'SuspendedUnits',
'WarningUnits'
)
 $status = Get-MsolAccountSku -ErrorAction Stop | Select $Options

Write-host '++++++++++++++++++++++++++++++++++++++++' -f DarkGray -b DarkGreen
write-host 'O365 License status Summary Report'
Write-Host 'Report run:' -NoNewline; Function-Get-TimeStamp
Write-host '----------------------------------------' -f Yellow
$status | ft -AutoSize
Write-host '++++++++++++++++++++++++++++++++++++++++' -f DarkGray -b DarkGreen
Read-host 'Press <ENTER> to open report in GridView'
$status | Out-GridView   
}


#(4)_.Run License Status Report
Function-Get-License-Status-Report 