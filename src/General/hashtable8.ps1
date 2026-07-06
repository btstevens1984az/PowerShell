# Purpose: hashtable8 — General-purpose PowerShell utilities.
# using the Type Accelerator from v3.0 onward

$obj = [PSCustomObject] @{
          Division = 'IT'
          Laptop   = 'Surface'
          Ferrari  = $false
         }
$obj | Format-List -Property *

# using the earlier v2.0 syntax

$props = @{
          Division = 'IT'
          Laptop   = 'Surface'
          Ferrari  = $false
          }

$object = New-Object psobject -Property $props
$object | Format-List -Property *

