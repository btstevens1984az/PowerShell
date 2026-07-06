# Purpose: ReformatHashtable — PowerShell automation.
& {
	foreach($hashtable in [ISESteroids.SteroidsFixer.Helpers]::GetAST('Hashtable'))
	{
		if ($hashtable.Extent.Text.TrimStart().StartsWith('@') -eq $false -or $hashtable.KeyValuePairs.Count -eq 0) { continue }

		$sb = New-Object -TypeName System.Text.StringBuilder
		$null = $sb.AppendLine('@{')
		
		# find maximal length for keys
		$length = -1
		foreach($item in $hashtable.KeyValuePairs.Item1.Value) { if ($item.Length -gt $length) { $length = $item.Length } }
		
		$length = [Math]::Max($length, 0)
		foreach($KeyValuePair in $hashtable.KeyValuePairs)
		{
			$null = $sb.AppendLine('  ' + $KeyValuePair.Item1.ToString().PadRight($length) + ' = ' + $KeyValuePair.Item2)
		}
		$null = $sb.Append('}')
		Add-SteroidsTextChange -PositionInfo $hashtable.Extent -ReplacementText $sb.ToString()
	}

	Invoke-SteroidsTextChange
}
