# Purpose: transcript — General-purpose PowerShell utilities.
Function ST
{
	$date = get-date
	$datestring = "$($date.year)$($date.month)$($date.hour)$($date.minute)$($date.second)"
	start-transcript "s:\transcripts\PSH$datestring.txt" -noclobber
}