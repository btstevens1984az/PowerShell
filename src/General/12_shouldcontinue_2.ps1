# Purpose: 12 shouldcontinue 2 — General-purpose PowerShell utilities.
function New-EmployeeFile
{
    [cmdletbinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Username,
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$UserID,
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [datetime]$StartDate,
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$SalaryLevel,
        [switch]$Force
    )

    Begin
    {
        $ContinueYesToAll = $false
        $ContinueNoToAll = $false
    }
    Process
    {
        if ($Force -or $PSCmdlet.ShouldProcess($Username, "Create employee file"))
        {
            if ($StartDate -le (Get-Date) -or $PSCmdlet.ShouldContinue("Start date for $Username is in the future, should this record really be saved?", "Are you sure?", [ref]$ContinueYesToAll, [ref]$ContinueNoToAll))
            {
                $employeeData = new-object psobject -Property @{
                    "UserID"=$UserID;
                    "StartDate"=$StartDate;
                    "SalaryLevel"=$SalaryLevel
                }

                $employeeData | Export-CSV .\emp-f-$username.csv -NoTypeInformation -Confirm:$false
            }
        }
    }
}

$users = @()
$users += New-Object psobject -Property @{"Username"="tnolan";    "UserID"=64883;  "StartDate"="4/1/1997";  "SalaryLevel"="A5" }
$users += New-Object psobject -Property @{"Username"="mpunschke"; "UserID"=74985;  "StartDate"="2/23/2000"; "SalaryLevel"="A6" }
$users += New-Object psobject -Property @{"Username"="lmaguire";  "UserID"=103548; "StartDate"="8/17/2037"; "SalaryLevel"="A2" }
$users += New-Object psobject -Property @{"Username"="selliott";  "UserID"=85243;  "StartDate"="11/9/2005"; "SalaryLevel"="A3" }
$users += New-Object psobject -Property @{"Username"="jrosado";   "UserID"=54894;  "StartDate"="11/9/2042"; "SalaryLevel"="A1" }


# Add -Force (and define the parameter above) to skip over the confirmation.
$users | New-EmployeeFile -Force
dir