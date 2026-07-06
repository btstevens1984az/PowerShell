# Purpose: SimpleXMLDemo — General-purpose PowerShell utilities.
[XML]$users = Get-Content .\Users.xml
#[System.Xml.XmlDocument]$users = Get-Content .\Users.xml
$users
$users.employees.user | FT -AutoSize
$ford = $users.employees.user | Where-Object {$_.givenname -eq "ford"}
$ford
$ford.SN = "Smith"
$users.employees.user | FT -AutoSize
$users | Get-Member
$users.Save("c:\temp\newXML.xml")
[xml]$newXML = Get-Content "c:\temp\newXML.xml"
$newXML.employees.user | FT -AutoSize

