# Purpose: testCom — General-purpose PowerShell utilities.
#http://blogs.msmvps.com/richardsiddaway/2015/08/05/wmf-5-0-com-applications/
measure-command -Expression {
$xl = New-Object -comobject 'Excel.Application'
 $xl.visible = $true
 $xlbooks =$xl.workbooks
 $wkbk = $xlbooks.Add()
 $sheet = $wkbk.WorkSheets.Item(1)

## create headers
 $sheet.Cells.Item(1,1).FormulaLocal = 'Value'
 $sheet.Cells.Item(1,2).FormulaLocal = 'Square'
 $sheet.Cells.Item(1,3).FormulaLocal = 'Cube'
 $sheet.Cells.Item(1,4).FormulaLocal = 'Delta'

$row = 2

for ($i=1;$i -lt 25; $i++){

$f = $i*$i

$sheet.Cells.Item($row,1).FormulaLocal = $i
 $sheet.Cells.Item($row,2).FormulaLocal = $f
 $sheet.Cells.Item($row,3).FormulaLocal = $f*$i
 $sheet.Cells.Item($row,4).FormulaR1C1Local = '=RC[-1]-RC[-2]'

$row++
 }


}