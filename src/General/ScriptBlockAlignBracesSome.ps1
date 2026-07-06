# Purpose: ScriptBlockAlignBracesSome — General-purpose PowerShell utilities.
& {
	# purpose is to reformat scriptblocks
	# scriptblocks are a common element in many PowerShell structures
	# and can also be used standalone

	# to improve readability, this unit identifies the opening and 
	# closing braces and makes sure these braces exist on individual lines
	# separated from other content (to improve brace alignment)

	# if a scriptblock is a "one-liner" (start and end brace exist on same line),
	# then no optimization is done because one-liner are often desired.

	# the unit also determines whether or not the scriptblock is a parameter 
	# argument. If a scriptblock is a parameter argument, then the opening 
	# brace must be on the same line with the parameter

	$crlf = -join [Char[]](13,10)

	$items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('ScriptAndStatementblock')
	foreach($ScriptBlock in $items)
	{
		# are start and end on the same line (one-liner)?
		if ($ScriptBlock.Extent.StartLineNumber -eq $ScriptBlock.Extent.EndLineNumber) { continue }

		# get scriptblock content
		$text = $ScriptBlock.Extent.Text.Trim()

		# is the scriptblock enclosed by braces?
		# the top scriptblock is not
		if ($text.StartsWith('{') -eq $false) { continue }
  
		# at this point, we have a scriptblock that may need reformatting
		if ($ScriptBlock.Parent -ne $null)
		{
			$parentStructure = $ScriptBlock.Parent.GetType().Name
		}
		else
		{
			$parentStructure = ''
		}

		# INSERT LINEBREAK BEFORE OPENING BRACE?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetTokenUntilLineBreak($ScriptBlock.Extent.StartOffset, 'Backwards')
		if ($token.Count -gt 0 -and $parentStructure -ne 'ScriptBlockExpressionAst')
		{
			$start = $ScriptBlock.Extent.StartOffset
			$end = $ScriptBlock.Extent.StartOffset
			[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $crlf)
   
		}
		# INSERT LINEBREAK AFTER OPENING BRACE?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetTokenUntilLineBreak($ScriptBlock.Extent.StartOffset,'Forward')
		if ($token.Count -gt 0)
		{
			# add crlf after opening brace
			$start = $ScriptBlock.Extent.StartOffset+1
			$end = $ScriptBlock.Extent.StartOffset+1
			[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $crlf)
   
		}

		# INSERT LINEBREAK BEFORE CLOSING BRACE?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetTokenUntilLineBreak($ScriptBlock.Extent.EndOffset-1, 'Backwards')
		if ($token.Count -gt 0)
		{
			# add crlf before closing brace
			$start = $ScriptBlock.Extent.EndOffset-1
			$end = $ScriptBlock.Extent.EndOffset-1
			[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $crlf)
		}
  
		# INSERT LINEBREAK AFTER CLOSING BRACE?
		$token = [ISESteroids.SteroidsFixer.Helpers]::GetTokenUntilLineBreak($ScriptBlock.Extent.EndOffset-1, 'Forward')
		if ($token.Count -gt 0 -and $parentStructure -ne 'ScriptBlockExpressionAst')
		{
			if (-not($token.Kind -eq 'Pipe' -or $token.Kind -eq 'Comment' -or $token.Kind -eq 'LineContinuation' -or $token.Kind -eq 'Parameter'))
			{
      
				$start = $ScriptBlock.Extent.EndOffset
				$end = $ScriptBlock.Extent.EndOffset
				[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, $crlf)
			}
		}
  

	}
	Invoke-SteroidsTextChange
}

