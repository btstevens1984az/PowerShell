# Purpose: Get-ForEach — General-purpose PowerShell utilities.
# Write-host is just used to either show progress while running or for testing during development

$qrdata = (import-csv c:\temp\TeamQR\qr.csv)
	foreach ($item in $qrdata) {
		$filename1 = $item.UserName
		$Number1 = $item.Number

		$filename = "C:\temp\teamqr\pngs\" + $filename1 + ".png"
		$Message = '"Tele:' + $Number1 + '"'
		# write-host "Number1  " "$Number1"
		Write-Host "Message:" "$Message"
		# write-host "FILENAME1 " "$fileName1"
		write-host "FileName:" "$fileName"
}
				
# to output the Double Quotes in the file r write-host - enclose them with a SINGLE quote				
				
#for each loop
#1. This imports the csv file and stores it in the variable $testcsv
#
#$testcsv = import-csv c:\scripts\test.csv
#
# 2.  This starts a "foreach loop" to process the csv file row by row.  The first variable, $test, can be named anything you want it to be.  I find it good practice to name it something relevent to the import-csv variable.  The second variable is the one we defined earlier for importing the csv file.
#
#foreach($test in $testcsv)
#
# 3. Start the loop with a {
#
#{
#
# 4.  This part is how we tie variables to the column headers in the csv file.  Again, name these what you want.  I like to name them after the column headers.  Set them equal to the $test variable dot (.) the column header they are tied to.
#
#$field1 = $test.field1
#$field2 = $test.field2
#
# 5.  This is the command we are going to run each row through.  Use the variables from the last step in the command.  Here we are telling powershell to echo field1 and field2.  Again, each row in the csv will run through this command.
#
#Echo "$field1, $field2"
#
# 6.  Close the foreach loop with one of these }
#
#}
#
#
# My csv called test.csv looks like this:
#
# Field1,Field2
# data1,data2
# data3,data3

