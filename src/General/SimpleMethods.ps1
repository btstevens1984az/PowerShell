# Purpose: SimpleMethods — General-purpose PowerShell utilities.
class ComputerInfo 
{
    [bool]GetStatus()
    {
       [int]$Result =  Test-Connection -ComputerName $this.computername -Count 2 -Quiet
       return $Result
    }
    #Overload
    [bool]GetStatus([string]$ComputerName)
    {
       [int]$Result =  Test-Connection -ComputerName $ComputerName -Count 2 -Quiet
       return $Result
    }
}