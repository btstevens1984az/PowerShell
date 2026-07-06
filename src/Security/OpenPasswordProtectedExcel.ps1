# Purpose: OpenPasswordProtectedExcel — Security auditing and compliance checks.
# ------------------------------------------------------------------
# OpenPasswordProtectedExcel.ps1
# ed wilson, msft, 6/17/2009
# 
# uses the open method from the workbooks object
# to open a password protected Excel SpreadSheet
#
# -------------------------------------------------------------------
$filename = "C:\fso\TestNumbersProtected.xls"
$updatelinks = 3
$readonly = $false
$format = 5
$password = "password"
$excel = New-Object -comobject Excel.Application
$excel.visible = $true
$excel.workbooks.open($fileName,$updatelinks,$readonly,$format,$password) |
Out-Null
