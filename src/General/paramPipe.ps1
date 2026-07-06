# Purpose: paramPipe — General-purpose PowerShell utilities.
function dd
{
param ([parameter(ValueFromPipeline=$true)]$indate)
process
{
    
    if ($indate -ne $null)
    {
        return (((Get-date) - (get-date $indate)).totaldays)
    }
 }   
}