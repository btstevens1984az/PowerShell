# Purpose: GetGroupsCSV — General-purpose PowerShell utilities.
# PowerShell2
# Kerry k
# get list of distribution groups - save to csv
# use list to create csvs showing membership

connect-qadservice -service '108.45.123.69'

$strGroupPath = "H:\AD-Reports\DistroGroupsNames9132010.csv"
$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$root = $dom.GetDirectoryEntry()
$search = [System.DirectoryServices.DirectorySearcher]$root

get-QADGroup -SearchRoot '108.45.123.69/Distribution Group' -GroupType 'Distribution' -sizelimit 0 | Select-Object DN, Name, email | Export-Csv -Path $strGroupPath
 
$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()

$Sheet = $Excel.Worksheets.Item(1)
$Sheet.Cells.Item(1,1) = "Logon Name"
$Sheet.Cells.Item(1,2) = "Display Name"
$Sheet.Cells.Item(1,3) = "Disabled"
$Sheet.Cells.Item(1,4) = "Expired"
$Sheet.Cells.Item(1,5) = "Email"
$Sheet.Cells.Item(1,6) = "Phone"
$Sheet.Cells.Item(1,7) = "Distro Group"
$Sheet.Cells.Item(1,8) = "Group Email"
# $Sheet.Cells.Item(1,9) = "Kerberos Distribution Center"
# $Sheet.Cells.Item(1,10) = "Primary Domain Controller"
# $Sheet.Cells.Item(1,11) = "Time Service"
$intRow = 2

$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 19
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True

$SheetolItems = Import-CSV $strGroupPath
foreach ($DistroGroup in $SheetolItems){
$groupName = $DistroGroup.name
Get-QADGroupMember -identity $groupName | Select-Object LogonName, DisplayName, AccountIsDisabled, AccountIsExpired, Email,PhoneNumber
$Sheet.Cells.Item($intRow, 1) = $_.LogonName
$Sheet.Cells.Item($intRow, 2) = $_.DisplayName
$Sheet.Cells.Item($intRow, 3) = $_.AccountIsDisabled
$Sheet.Cells.Item($intRow, 4) = $_.AccountIsExpired
$Sheet.Cells.Item($intRow, 5) = $_.Email
$Sheet.Cells.Item($intRow, 6) = $_.Phone
$Sheet.Cells.Item($intRow, 7) = $groupName
$Sheet.Cells.Item($intRow, 8) = $groupName.email
# $Sheet.Cells.Item($intRow, 9) = $objItem.DSKerberosDistributionCenterFlag
# $Sheet.Cells.Item($intRow, 10) = $objItem.DSPrimaryDomainControllerFlag
# $Sheet.Cells.Item($intRow, 11) = $objItem.DSTimeServiceFlag

$intRow = $intRow + 1}
$WorkBook.EntireColumn.AutoFit()
Clear

