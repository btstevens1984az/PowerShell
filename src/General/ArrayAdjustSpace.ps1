# Purpose: ArrayAdjustSpace — General-purpose PowerShell utilities.
& {
	# get all ArrayLiteralASTs
	$items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Array')
	foreach($item in $items)
	{
		$tokenlist = [ISESteroids.SteroidsFixer.Helpers]::GetToken($item.Extent.StartOffset, $item.Extent.EndOffset)
		$tokenCount = $tokenlist.Count
		for($i=0; $i-lt$tokenCount-1;$i++)
		{
			$token = $tokenlist[$i]
			# do we have a comma that is not at the beginning?
			if ($token.Kind -eq 'Comma' -and $i -gt 0)
			{
				# remove space between comma and preceeding token
				$previoustoken = $tokenList[$i-1]
				$start = $previoustoken.Extent.EndOffset
				$end = $token.Extent.StartOffset
				if ($end-$start -gt 1)
				{
					[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, '', $false)
				}
				# make sure there is exactly one space after each comma
				$nexttoken = $tokenList[$i+1]
				$start = $token.Extent.EndOffset
				$end = $nexttoken.Extent.StartOffset
				if ($end-$start -ne 1)
				{
					[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, ' ', $false)
				}
			}
   
		}
  
	}

	Invoke-SteroidsTextChange
}

