# Purpose: PipelineBreakAfterPipe — General-purpose PowerShell utilities.
& {
	$crlf = -join [Char[]](13,10)

	$items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Pipeline')
	foreach($item in $items)
	{ 
		# do optimization only with 3 or more pipeline elements
		if ($item.PipelineElements.Count -le 2) { continue }
		$tokenList = [ISESteroids.SteroidsFixer.Helpers]::GetToken($item.Extent.StartOffset, $item.Extent.EndOffset)
		$tokenCount = $tokenlist.Count
		for($i=0; $i-lt$tokenCount-1;$i++)
		{
			$token = $tokenlist[$i]
			# do we have a comma that is not at the beginning?
			if ($token.Kind -eq 'Pipe' -and $i -gt 0)
			{
				$nexttokens = [ISESteroids.SteroidsFixer.Helpers]::GetTokenUntilLineBreak($Token.Extent.EndOffset-1, 'Forward')
      
				if ($nexttokens.Count -gt 0 )
				{
					$start = $token.Extent.EndOffset
					$end = $nexttokens[0].Extent.StartOffset
					[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $crlf)
        
				}
			}
		}
	}
	Invoke-SteroidsTextChange
}
