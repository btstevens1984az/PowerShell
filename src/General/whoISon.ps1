# Purpose: whoISon — General-purpose PowerShell utilities.
$erroractionpreference = "SilentlyContinue" 

$a = New-Object -comobject Excel.Application
$a.visible = $True 

$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1) 

$c.Cells.Item(1,1) = "Machine Name"
$c.Cells.Item(1,2) = "Ping Status"
$c.Cells.Item(1,3) = "File Name"
$c.Cells.Item(1,4) = "Version"
$c.Cells.Item(1,5) = "Report Time Stamp" 

$d = $c.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True 

$intRow = 2 

$colComputers = gc c:\ps2\sys.txt

foreach ($strComputer in $colComputers)
{
$c.Cells.Item($intRow,1) = $strComputer.ToUpper() 

Function PingComputer
{
$ping = new-object System.Net.NetworkInformation.Ping
$Reply = $ping.send($strComputer)
if($Reply.status -eq �SUCCESS�) 
{
$c.Cells.Item($intRow, 2) = �Online� 

Function GetFileInfo
{
$OSVersion = (gwmi -class Win32_OperatingSystem -computer $strComputer).version
if ($OSVersion -le 5.1)
{
$Path = "\\"+ $strComputer + "\C$\Program Files\Microsoft Office\Office12\OUTLOOK.EXE"
}
else
{
$Path = "\\"+ $strComputer + "\C$\Program Files\Microsoft Office\Office12\OUTLOOK.EXE"
} 

$File = get-item $Path 

$c.Cells.Item($intRow,3) = $File.Name
$c.Cells.Item($intRow,4) = $File.VersionInfo.Productversion
} 

GetFileInfo 

}
else 
{
$c.Cells.Item($intRow, 2).Interior.ColorIndex = 3
$c.Cells.Item($intRow, 2) = "Offline"
}
}
PingComputer 

$c.Cells.Item($intRow,5) = Get-date 

$ping.status = $null
$intRow = $intRow + 1
} 

$d.EntireColumn.AutoFit()
  