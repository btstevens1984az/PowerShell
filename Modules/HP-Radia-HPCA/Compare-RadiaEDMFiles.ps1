# Purpose: Compare-RadiaEDMFiles — HP Radia client automation and satellite servers.
Function Compare-RadiaEDMFiles{
$ComputerName1=[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null  
$ComputerName1= [Microsoft.VisualBasic.Interaction]::InputBox("Enter Computername 1")
$ComputerName2=[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null  
$ComputerName2= [Microsoft.VisualBasic.Interaction]::InputBox("Enter Computername 2")
$CompDir1 = Get-ChildItem -Recurse -Path '\\$ComputerName1\C$\Program Files (x86)\Hewlett-Packard\HPCA\Agent' -Filter *.edm -Force
$CompDir2 = Get-ChildItem -Recurse -Path '\\$ComputerName2\C$\Program Files (x86)\Hewlett-Packard\HPCA\Agent' -Filter *.edm -Force
[string]$Data = Compare-Object -ReferenceObject $CompDir2 -DifferenceObject $CompDir1 -Property Name,LastWriteTime | Sort-Object Name | Out-String
}