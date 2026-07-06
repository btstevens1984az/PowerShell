# Purpose: GetServerInfo2XLS — General-purpose PowerShell utilities.
$strComputer = Read-Host "Enter Machine Name"

$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()

$Sheet = $Excel.Worksheets.Item(1)
$Sheet.Cells.Item(1,1) = "Domain Name"
$Sheet.Cells.Item(1,2) = "Site Name"
$Sheet.Cells.Item(1,3) = "Dns Forest Name"
$Sheet.Cells.Item(1,4) = "Directory Service"
$Sheet.Cells.Item(1,5) = "Dns Controller"
$Sheet.Cells.Item(1,6) = "Dns Domain"
$Sheet.Cells.Item(1,7) = "Dns Forest"
$Sheet.Cells.Item(1,8) = "Global Catalog"
$Sheet.Cells.Item(1,9) = "Kerberos Distribution Center"
$Sheet.Cells.Item(1,10) = "Primary Domain Controller"
$Sheet.Cells.Item(1,11) = "Time Service"
$intRow = 2

$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 19
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True

$SheetolItems = Gwmi Win32_NTDomain -Comp $strComputer 
foreach ($objItem in $SheetolItems){
$Sheet.Cells.Item($intRow, 1) = $objItem.DomainName
$Sheet.Cells.Item($intRow, 2) = $objItem.DcSiteName
$Sheet.Cells.Item($intRow, 3) = $objItem.DnsForestName
$Sheet.Cells.Item($intRow, 4) = $objItem.DSDirectoryServiceFlag
$Sheet.Cells.Item($intRow, 5) = $objItem.DSDnsControllerFlag
$Sheet.Cells.Item($intRow, 6) = $objItem.DSDnsDomainFlag
$Sheet.Cells.Item($intRow, 7) = $objItem.DSDnsForestFlag
$Sheet.Cells.Item($intRow, 8) = $objItem.DSGlobalCatalogFlag
$Sheet.Cells.Item($intRow, 9) = $objItem.DSKerberosDistributionCenterFlag
$Sheet.Cells.Item($intRow, 10) = $objItem.DSPrimaryDomainControllerFlag
$Sheet.Cells.Item($intRow, 11) = $objItem.DSTimeServiceFlag

$intRow = $intRow + 1}
$WorkBook.EntireColumn.AutoFit()
Clear
