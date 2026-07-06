# Purpose: Looping-ForEach — General-purpose PowerShell utilities.
# Looping-FOREACH.PS1
#
# ForEeach example 
#   showing the use of ARRAYS
#   showing the use of FORMAT strings
#   showing the use of CULTURE info
#   showing the use of new-oject

Get-WinHomeLocation | FT -autosize

$money = 12345678.99
$today = Get-Date

$cultureNames  = "ar-SA","da-DK","de-CH","de-DE","en-AU","en-GB","en-IN"
$cultureNames += "en-US","es-AR","es-ES","es-MX","fi-FI","fr-FR","ig-NG"
$cultureNames += "ja-JP","nn-NO","pt-BR","ru-RU","se-SE","th-TH","zh-HANS"

# note: use the ISE to ensure fonts are displayed correctly

ForEach ($cultureName in $cultureNames) {
  $cultureInfo=New-Object Globalization.CultureInfo($cultureName)
  write-output "$cultureName : $($cultureInfo.Displayname)"
  $money.ToString("c",$cultureInfo) #currency
  $money.ToString("n",$cultureInfo) #numeric
  $today.ToString("D",$cultureInfo) #date
  $today.ToString("t",$cultureInfo) #time
  write-output "--------------"
}


#### foreach disk in Get-Disk...

ForEach ($disk in Get-CIMinstance Win32_LogicalDisk) {
  $drive=$disk.DeviceID
  $vol=$disk.VolumeName
  $type=[enum]::GetValues([System.IO.DriveType])[$disk.drivetype]
  $size=($disk.size / 1Gb)
  $free=($disk.FreeSpace / 1Gb)
  write-output "$drive '$vol' : $type : $($size.ToString('N2')) ($($free.ToSTring('N2')) free)"
}
