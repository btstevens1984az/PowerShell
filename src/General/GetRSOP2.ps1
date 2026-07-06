 <#
.SYNOPSIS
Get-MyRSOP will return GPO RSOP for target computers.
.DESCRIPTION
Get-MyRSOP will return GPO RSOP for target computers.
.PARAMETER ComputerName
One or more target computers
.PARAMETER FilePath
Directory to store RSOP reports
.PARAMETER user
What local user to target for RSOP
.PARAMETER PipelineVariable
.EXAMPLE
PS C:\> Get-MyRSOP
Get-MYRSOP -computerName 216.168.202.140 -user administrator -filepath c:\temp\GPOReports
NAME        :  Get-MyRSOP
LAST UPDATED:  1/16/2015
.LINK
Get-GPResultantSetOfPolicy 
.INPUTS
None
.OUTPUTS
None
#> 
function Get-MyRSOP
{
    param(
    [Parameter(
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Mandatory = $true)]
    [string[]]$ComputerName,
    [ValidateScript({Test-Path -Path $_})]
    [string]$FilePath = "c:\temp\GPOReports",
    [string]$user = "administrator"
    )
    Foreach ($computer in $computerName)
    {
    try {
        $RSOPParams = @{
                            path = "$FilePath\$computer"
                            computer = $computer
                            user = "$computer\$user"
                            ReportType = "HTML"
                            ErrorAction = "stop"
                        }
        $result = Get-GPResultantSetOfPolicy @RSOPParams
        Write-Verbose "RSOP complete with userinfo for $computer"
        }
    catch [System.ArgumentException],[System.Security.Principal.IdentityNotMappedException]
        {
            if ($_.exception.message -like "*no RSoP logging data  for that user on that computer*" -or $_.exception.message -like "*identity references could not be translated*")
            {
                Write-Verbose $_.exception.message
                Write-Verbose "Running RSOP without user info"
                Write-Debug $_.exception.message
                $RSOPParams.Remove("user")
                $RSOPParams.Remove("erroraction")
                $result = Get-GPResultantSetOfPolicy @RSOPParams
            }
        }
    }
}
