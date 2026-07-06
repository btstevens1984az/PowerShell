# Purpose: Citrix Copy Files — Storage management and disk operations.
$scriptbasename = $MyInvocation.Mycommand.name.substring(0, $MyInvocation.Mycommand.name.lastindexof('.'))
if ($scope -ne '') {$credsplain = select-MiCredential -scope $scope -plain}
#### Original and Destination ####
if (![bool]$source) {
	Append-Richtextbox -ComputerName $computername -Source $scriptbasename -Message 'Fill in the requested fields from the command console' -MessageColor $css.richtextcolorwarning -logfile 'ps1command.log'
	$source = read-host "Original folder?"
}
if (![bool]$destination) {$destination = read-host "Original Destination?"}
if (![bool]$files) {$files = read-host "Files?"}

##########################
if ($scope -ne '') {
	$cmdkeyadd = "cmdkey.exe /add:" + $computername + " /user:" + $credsplain.username + " /pass:'" + $credsplain.password + "'"
	invoke-expression $cmdkeyadd
}
$robocommand = 'robocopy "{0}" "\\{1}\{2}" "{3}" /w:1 /r:1 /xo /e /tee /np /LOG+:".\logs\Copy_Robocopy Original Destination.log"' -f $source, $computername, ($destination -replace (':', '$')), $files
invoke-expression $robocommand
if ($lastexitcode -gt 8) {$color = $css.richtextcolorERR; $premsg = 'Error'}
else {$color = $css.richtextcolorOK; $premsg = 'Exit'}
Append-Richtextbox -ComputerName $computername -Source $scriptbasename -Message "$premsg copy $source to $destination"  -MessageColor $color -logfile 'ps1command.log'
if ($scope -ne '') {
	$cmdkeydelete = "cmdkey.exe /delete:" + $computername
	invoke-expression $cmdkeydelete
}
