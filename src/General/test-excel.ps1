# Purpose: test-excel — General-purpose PowerShell utilities.
#open excel
$excel = New-Object -ComObject excel.application
$excel.visible = $True

#add a default workbook
$workbook = $excel.Workbooks.Add()

#remove worksheet 2 & 3
#$workbook.Worksheets.Item(3).Delete()
#$workbook.Worksheets.Item(2).Delete()

#give the remaining worksheet a name
#$newwksht= $workbook.Worksheets.Item(1)
#$newwksht.Name = 'WKSHTUsers'

# get list of csv file names
$collection = Get-ChildItem C:\Temp\HPCAGroups\* -include *.csv  | select basename
$csvfile = Get-ChildItem C:\Temp\HPCAGroups\* -include *.csv  | select Name

#$sourcepath=  "C:\Temp\HPCAGroups\HPCA_AGCH_PATCH.csv"
#$records = Import-Csv -Path $sourcepath

#seeing i used row 1 for the title then left a blank row & use row 3 for the column headers
# i chose to start with the data from row 4 hence the $i is set to 4
$i = 1 



foreach ($item in $csvfile) {
	write-host ITEM is now $item
$newwksht= $workbook.Worksheets.Item(1)
$newwksht.Name = '$Item'
$records = import-csv "C:\Temp\HPCAGroups\$item"
write-host RECORD IS  $records
# the .appendix to $record refers to the column header in the csv file 

# adds data from each csv file
			foreach($record in $records) 
				{ 
					$excel.cells.item($i,1) = $record.name

					$i++ 
 

					#adjusting the column width so all data's properly visible
					$usedRange = $newwksht.UsedRange	
					$usedRange.EntireColumn.AutoFit() | Out-Null
				}

}
# $collection = Get-ChildItem C:\Temp\HPCAGroups\* -include *.csv  | select basename
#saving & close the file
$outputpath = "C:\Temp\HPCAGroups\test\excelltestKK.xlsx"
$workbook.SaveAs($outputpath)

# remark quit statement to leave spreadsheet open
#$excel.Quit()
