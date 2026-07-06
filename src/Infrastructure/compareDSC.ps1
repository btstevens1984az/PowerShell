# Purpose: compareDSC — Core infrastructure automation scripts.
$DSc51 = get-command -Module PSDesiredStateConfiguration
$dsc5 = icm -ScriptBlock { Get-Command -Module PSDesiredStateConfiguration } -ComputerName 139.97.83.154
#create-commandcompare function located in scripts\misc\comparecommandsparams.ps1
$r = Create-CommandCompare -CommandSource $DSC5 -Commanddifference $dsc51 -CommandSourcePrefix DSC5 -CommandDiffPreFix DSC51 
$r | select name,dsc* | ogv

#compare 5 vs 5.1
$PSH51 = get-command -CommandType function,cmdlet |   Where-Object {$_.parameters.keys.count}
$PSH5 = icm -ScriptBlock { Get-Command  -CommandType function,cmdlet |  Where-Object {$_.parameters.keys.count}} -ComputerName 139.97.83.154
$r = Create-CommandCompare -CommandSource $PSH5 -Commanddifference $PSH51 -CommandSourcePrefix PSH5 -CommandDiffPreFix PSH51 
$r | select name,PSH*,modulename | ogv