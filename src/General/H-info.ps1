# Purpose: H-info — General-purpose PowerShell utilities.
Param($path="H:\",$file="H:\H-INFO-CHART.xlsx",[int]$Top=6)
Write-Host
Write-Host " - Collecting File Data from [$PATH]"
$MyArray = dir $path -Recurse -ea 0 | ?{!$_.PSIsContainer} `
                                    | Group-Object Extension `
                                    | select name,@{n="groupSize";e={($_.group | measure-object -sum Length).sum}} `
                                    | sort -desc groupSize `
                                    | select -first 6
Write-Host " - Creating Excel Object"
$Start = Get-Date
$Excel = new-Object -com "Excel.Application"
$Workbook = $Excel.Workbooks.Add()
$Worksheet = $Workbook.Worksheets.item(1)
Write-Host " - Adding Data to Excel"
$Worksheet.Cells.item(1,1) = "Type"
$Worksheet.Cells.item(1,2) = "Size"
$x = 2
for ($i=0;$i -lt $myarray.count;$i++)
{
    $Worksheet.Cells.item($x,1) = $myarray[$i].Name
    $Worksheet.Cells.item($x,2) = $myarray[$i].GroupSize
    $x++
}
$RangeString = '$A$2:$B$' + ($myarray.count + 1)
$Range = $Worksheet.Range($RangeString)
$Range.select() | Out-Null
Write-Host " - Creating Chart Object"
$colCharts = $Excel.Charts
$colCharts.Add() | Out-Null
$Chart = $colCharts.item(1)
$Chart.Activate() | Out-Null
Write-Host " - Filling out Chart"
$Chart.ChartType = 70
$Chart.Elevation = 30
$Chart.Rotation = 80
$Chart.ApplyDataLabels(3)
$Chart.PlotArea.Fill.Visible = $False
$Chart.PlotArea.Border.LineStyle = -4142
$Chart.ChartArea.Fill.ForeColor.SchemeColor = 49
$Chart.ChartArea.Fill.BackColor.SchemeColor = 23
$Chart.ChartArea.Fill.TwoColorGradient(1,1)
Write-Host " - Saving as [$file]"
$WorkBook.SaveAs($file)
Write-Host " - Quiting Excel"
$Excel.quit()
$procid = (Get-Process Excel | Where-Object{$_.StartTime -gt $Start}).ID
stop-process -id $procid
Write-Host " - Launching Excel"
& 'c:\Program Files\Microsoft Office\Office12\EXCEL.EXE' $file
Write-Host
 
#######################################