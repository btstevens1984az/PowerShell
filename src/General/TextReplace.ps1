# Purpose: TextReplace — General-purpose PowerShell utilities.
#search for all .txt files in a directory and replace
#text in all files
$files = dir c:\temp\*.txt
$find = "127.0.0.1"
$replace = "127.0.0.2"
foreach ($file in $files)
{
	$text = Get-Content $file
	$text = $text -replace $find,$replace
	Set-Content -Path $file.fullname -Value $text
}