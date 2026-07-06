# Purpose: misc — General-purpose PowerShell utilities.
$dsc = Find-DscResource -Repository psgallery
$dsc1 = Find-DscResource -Repository psgallery -Tag DSCResourceKit
$dsc | ogv
$dsc[0] | select *
