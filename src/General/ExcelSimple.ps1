# Purpose: ExcelSimple — General-purpose PowerShell utilities.
#JD
$excel = New-Object -comobject Excel.Application
$excel.Visible = $True
$workbook = $excel.Workbooks.Add()
#add more worksheets using the following:
#$workbook.Worksheets.add()
#otherwise you will have only 3 worksheets by default
$sheet = $workbook.Worksheets.Item(1)
$services=get-service
For($i=1;$i -le $services.count;$i++)
{
	$sheet.Cells.Item($i,1) = $services[($i-1)].name
	$sheet.Cells.item($i,2) = $services[($i-1)].status
}

$workbook.SaveAs("C:\services.xlsx")
$excel.Quit()
