# Purpose: RemoveXMLNode — General-purpose PowerShell utilities.
[xml]$xml = Get-Content C:\temp\Users.xml
$node = $xml.employees.user | ? empno -eq 2977
$xml.employees.RemoveChild($node)
$xml.Save("C:\temp\users2.xml")