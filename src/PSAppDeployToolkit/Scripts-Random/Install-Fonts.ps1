# Purpose: Install-Fonts — PowerShell automation.
#Font Locations
#Network Location
$NetworkPath = "\\192.179.149.99\Fonts"
#Local Location (temp place to store fonts)
$LocalPath= "C:\Users\Public\Fonts\"
 
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
 
New-Item $LocalPath -type directory -Force
Copy-Item "$NetworkPath\*" $LocalPath
 
$Fontdir = dir $LocalPath
foreach($File in $Fontdir)
{
  if ((Test-Path "C:\Windows\Fonts\$File") -eq $False)
    {
    $objFolder.CopyHere($File.fullname,0x10)
    }
}