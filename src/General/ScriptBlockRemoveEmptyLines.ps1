# Purpose: ScriptBlockRemoveEmptyLines — General-purpose PowerShell utilities.
& {
	Set-StrictMode -Off
	# removes any empty (blank) line that is positioned
	# - between opening brace and content
	# - between content and closing brace

	$crlf = -join [Char[]](13,10)


	$items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('ScriptAndStatementblock')
	foreach($ScriptBlock in $items)
	{
		# are start and end on the same line (one-liner)?
		if ($ScriptBlock.Extent.StartLineNumber -eq $ScriptBlock.Extent.EndLineNumber) { continue }
  
		# get scriptblock content
		$text = $ScriptBlock.Extent.Text.Trim()
  
		# is the scriptblock enclosed by braces?
		# the top scriptblock in a script is not enclosed, to exit in this case:
		if ($text.StartsWith('{') -eq $false) { continue }
  
		# at this point, we have a scriptblock that may need reformatting
  
		# how many real lines are in this block?
		$nonwhitespace = $ScriptBlock.Extent.Text.SubString(1, $ScriptBlock.Extent.Text.Length-2) -replace '[^\S\n]' -split '\n' | Where-Object { $_.Trim() }
		$lines = $nonwhitespace.Count
		$linebreak = ''
		if ($lines -gt 1 )
		{ $linebreak = "`n" }
  
		# is there empty space between opening brace and content?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetNextNonWhitespaceToken($ScriptBlock.Extent.StartOffset, $ScriptBlock.Extent.EndOffset, 'Forward')
		if ($token -ne $null)
		{
			$start = $ScriptBlock.Extent.StartOffset + 1
			$end = $token.Extent.StartOffset
			if ($start -ne $end)
			{
				[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $linebreak)
			}
		}
  
		# is there empty space between content and closing brace?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetNextNonWhitespaceToken($ScriptBlock.Extent.EndOffset-1, $ScriptBlock.Extent.StartOffset+1, 'Backwards')
		if ($token -ne $null)
		{
			# is this a regular comment token? In this case, brace cannot be moved
			$isComment = (($token.Kind -eq 'Comment') -and ($token.Extent.Text.StartsWith('<#') -eq $false))
    
			$start = $token.Extent.EndOffset
			$end = $ScriptBlock.Extent.EndOffset - 1
      
			# if the token is a classic comment, add one linebreak or else the brace will be in the comment line (thus commented out)
			$addText = ''
			if ($isComment -or $Lines -gt 1) { 
				$addText = $crlf 
			}
			if ($start -ne $end)
			{
				[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $addText)
			}
    
		}
	}
	Invoke-SteroidsTextChange
}

