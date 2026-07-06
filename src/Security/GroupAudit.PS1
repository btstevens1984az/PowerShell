# Purpose: GroupAudit — Security auditing and compliance checks.
#       This script takes all of the groups within AD and places
#       them in the columns of an excel spreadsheet.
#       It then takes all of the users and placed them along the
#       rows.
#       It then places an 'x' every cross section where the user
#       is a member of that group

$erroractionpreference = "SilentlyContinue"
$xl = New-Object -comobject Excel.Application
$xl.visible = $True 

$wb = $xl.Workbooks.Add()
$s3 = $wb.Sheets | where {$_.name -eq "Sheet3"}
$s3.delete()
$ws = $wb.Worksheets.Item(1)

$wb.Sheets.Add()
$ws = $wb.Worksheets.Item(1)
$ws.Name = "AD Groups"

$groups = Get-QADGroup -SizeLimit 0
$intCol = 2
$grlook = @{}
foreach ($group in $groups)  {
$grlook.Add($group.dn, $intcol)
$ws.Cells.Item(1,$intCol) = $group.name
$intCol = $intCol + 1

}

$users = Get-QADUser -SizeLimit 500
$intRow = 2
$uslook = @{}
foreach ($user in $users) {

$uslook.Add($user.sid, $intRow)
$ws.Cells.item($intRow,1) = $user.name

$intRow = $intRow + 1

foreach ($usgr in $user.MemberOf) {

$grcol = $grlook.get_item($usgr)
$usrow = $uslook.get_item($user.sid)
$ws.Cells.item($usrow,$grcol) = "x"


}
}