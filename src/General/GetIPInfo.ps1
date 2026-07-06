# Purpose: GetIPInfo — General-purpose PowerShell utilities.
# kerry k March 2011
# powershell2     GetIPInfo.PS1  
# Change path to a text file which contains names of machines you wish to query  

$server = gc c:\domaincontrollers.csv  
  
# Create Excel Spreadsheet and format  
$Excel = New-Object -Com Excel.Application  
$Excel.visible = $True  
$Excel = $Excel.Workbooks.Add()  
  
$Sheet = $Excel.WorkSheets.Item(1)  
$Sheet.Cells.Item(1,1) = �Server Name�  
$Sheet.Cells.Item(1,2) = �DNS Name�  
$Sheet.Cells.Item(1,3) = �DNS Domain�  
$Sheet.Cells.Item(1,4) = �IP Address v4 & v6�  
$Sheet.Cells.Item(1,5) = �Subnet Mask�  
$Sheet.Cells.Item(1,6) = �Default Gateway�  
$Sheet.Cells.Item(1,7) = �MAC Address�  
$Sheet.Cells.Item(1,8) = �DNS Domain Suffix Available�  
$Sheet.Cells.Item(1,9) = �DHCP Server�  
$Sheet.Cells.Item(1,10) = �WINS Server Primary�  
$Sheet.Cells.Item(1,11) = �WINS Server Secondary�  
$Sheet.Cells.Item(1,12) = �DNS Servers�  
  
$WorkBook = $Sheet.UsedRange  
$WorkBook.Interior.ColorIndex = 8  
$WorkBook.Font.ColorIndex = 11  
$WorkBook.Font.Bold = $True  
  
$intRow = 2  
  
# Retreive Info for each machine and populate Excel Spreadsheet  
  
foreach ($s in $server)  
{  
$colItems = Get-wmiObject Win32_networkadapterconfiguration -computername $s | Where-Object{$_.IPENabled -eq "True"}  
  
foreach ($objItem in $colItems) {  
$Sheet.Cells.Item($intRow,1) = $s  
$Sheet.Cells.Item($intRow,2) = $objItem.DNSHostName  
$Sheet.Cells.Item($intRow,3) = $objItem.DNSDomain  
$Sheet.Cells.Item($intRow,4) = $objItem.IPAddress  
$Sheet.Cells.Item($intRow,5) = $objItem.IPSubnet  
$Sheet.Cells.Item($intRow,6) = $objItem.DefaultIPGateway  
$Sheet.Cells.Item($intRow,7) = $objItem.MACAddress  
$Sheet.Cells.Item($intRow,8) = $objItem.DNSDomainSuffixSearchOrder  
$Sheet.Cells.Item($intRow,9) = $objItem.DHCPServer  
$Sheet.Cells.Item($intRow,10) = $objItem.WINSPrimaryServer  
$Sheet.Cells.Item($intRow,11) = $objItem.WINSSecondaryServer  
$Sheet.Cells.Item($intRow,12) = $objItem.DNSServerSearchOrder  
  
$intRow = $intRow + 1  
  
}  
}  
$WorkBook.EntireColumn.AutoFit()  
Clear 

