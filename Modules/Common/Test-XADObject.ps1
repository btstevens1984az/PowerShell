# Purpose: Test-XADObject — Reusable PowerShell function libraries.
function Test-XADObject() {
   
     [CmdletBinding(ConfirmImpact="Low")]
   
     Param (
   
        [Parameter(Mandatory=$true,
   
                   Position=0,
   
                   ValueFromPipeline=$true,
   
                   HelpMessage="Identity of the AD object to verify if exists or not."
   
                  )]
   
        [Object] $Identity
   
     )
   
     trap [Exception] {
   
        return $false
   
     }
   
     $auxObject = Get-ADObject -Identity $Identity
   
     return $true
 }