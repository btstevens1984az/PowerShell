# Purpose: DoubleQuotes — General-purpose PowerShell utilities.
& {
	Set-StrictMode -Off
	# fixes double quoted strings that do not really need double quotes

	$Strings = [ISESteroids.SteroidsFixer.Helpers]::GetAST('DoubleQuotedString')

	foreach($string in $strings)
	{
		if ($string.Extent.Text -notmatch '[$`'']')
		{
			$text = $string.Extent.Text.SubString(1)
			$text = $text.SubString(0, $text.Length-1)
			Add-SteroidsTextChange -PositionInfo $string.extent -ReplacementText "'$text'"
		}
	}

	Invoke-SteroidsTextChange
}
