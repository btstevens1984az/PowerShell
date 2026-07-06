# Purpose: SimpleProperties — General-purpose PowerShell utilities.
class ComputerInfo 
{
    [string]$ComputerName = "Localhost"
    [string]$OSName
    #Can Use Variable Validation
    [ValidateRange(1,640)]
    [int]$NumberOfLogicalProcessors
}