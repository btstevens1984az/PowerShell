# Purpose: 10 cmdletbinding 1 — Certification notes and learning materials.
function New-EmployeeFile
{
    Param (
        [string]$Username,
        [int]$UserID,
        [datetime]$StartDate,
        [string]$SalaryLevel
    )

    $employeeData = new-object psobject -Property @{
        "UserID"=$UserID;
        "StartDate"=$StartDate;
        "SalaryLevel"=$SalaryLevel
    }

    $employeeData | Export-CSV .\emp-a-$username.csv -NoTypeInformation
}

New-EmployeeFile -Username tnolan 64883 `
                 -StartDate "4/1/1997" -SalaryLevel "A5"

# Without cmdletbinding, the function call will succeed
New-EmployeeFile -Username mpunschke 78498 `
                 -StartDate "5/8/2002" -SalaryLevel "A9" `
                 -Phone "212-555-1212" -State "NY"