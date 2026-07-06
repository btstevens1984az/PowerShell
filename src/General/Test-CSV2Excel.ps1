# Purpose: Test-CSV2Excel — General-purpose PowerShell utilities.
 # copy Selected CSV Files to one Excel WorkBook
 # script named Merge-CSV2Excel.ps1
 # Kerry K March 2018
 
 #function Release-Ref ($ref) { 
# ([System.Runtime.InteropServices.Marshal]::ReleaseComObject( 
# [System.__ComObject]$ref) -gt 0) 
 #[System.GC]::Collect() 
 #[System.GC]::WaitForPendingFinalizers()  
 #} 
 
 
 $xlPasteValues = -4163          # Values only, not formulas
 $xlCellTypeLastCell = 11        # to find last used cell
# open excel
$xl = new-object -comobject excel.application 
# set to false if you dont want excel to open
$xl.Visible = $True 
$xl.DisplayAlerts = $False

# set default workbook
$wb = $xl.Workbooks.Add() 

# delete 2 of the 3 default worksheets
$workbook.Worksheets.Item(3).Delete()
$workbook.Worksheets.Item(2).Delete()

# set counter to track number of worksheets
# $i = 1 
 
# Change the location of your CSV files here.

# $collection = Get-ChildItem C:\Temp\HPCAGroups\* -include *.csv  | select basename


# $length = 4

foreach ($item in $collection) {
#give the worksheet a name
$wksht= $workbook.Worksheets.Item(1)
$wksht.Name = "$item"
  
  $wb1 = $xl.Workbooks.Open("$item")
  $array = $item.ToString()
  $ws1 = $wb1.worksheets | where {$_.name -eq $item}
 
 
 Write-Host -foregroundcolor yellow $item
 $used = $ws1.usedRange
 $used.Select()
 $used.copy()
 $wb.Activate()
 $ws = $wb.Sheets.Add()
 $ws2 = $wb.worksheets | where {$_.name -eq $item}
 [void]$ws2.Range("A1").PasteSpecial(-4163) 
 #$ws2.name = $nsn
 #$i++ 

   
 }
#saving & closing the file
$outputpath = -Path "C:\Temp\HPCAGroups\merged.xlsx"

$workbook.SaveAs($outputpath)
 $wb1.Close()
 
