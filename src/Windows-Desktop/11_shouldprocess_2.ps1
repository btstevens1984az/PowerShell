# Purpose: 11 shouldprocess 2 — Windows desktop configuration and management.
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

    Process
    {
        if ($Force -or $PSCmdlet.ShouldProcess($Username, "Create employee file"))
        {
            $employeeData = new-object psobject -Property @{
                "UserID"=$UserID;
                "StartDate"=$StartDate;
                "SalaryLevel"=$SalaryLevel
            }

            $employeeData | Export-CSV .\emp-d-$username.csv -NoTypeInformation -Confirm:$false
        }
    }
}

$users = @()
$users += New-Object psobject -Property @{"Username"="tnolan";    "UserID"=64883;  "StartDate"="4/1/1997";  "SalaryLevel"="A5" }
$users += New-Object psobject -Property @{"Username"="mpunschke"; "UserID"=74985;  "StartDate"="2/23/2000"; "SalaryLevel"="A6" }
$users += New-Object psobject -Property @{"Username"="lmaguire";  "UserID"=103548; "StartDate"="8/17/2037"; "SalaryLevel"="A2" }
$users += New-Object psobject -Property @{"Username"="selliott";  "UserID"=85243;  "StartDate"="11/9/2005"; "SalaryLevel"="A3" }

#ConfirmImpact is set to "High" so the prompt will always display by default
#$users | New-EmployeeFile

# Add -Force (and define the parameter above) to skip over the confirmation.
$users | New-EmployeeFile -Force
