# Purpose: RemoveSemicolon — General-purpose PowerShell utilities.
& {
	$info = Get-SteroidsAST

	$Tokens = $info.TokenList 
	$i = $Tokens.Count
	for($x=0; $x -lt $i; $x++)
	{
		# is this a semicolon?
		if ($Tokens[$x].Kind -eq 'Semi')
		{
			# is this token inside a structure where semicolons are useful?
			$DoReplace = Test-SteroidsTextChange -Extent $Tokens[$x].Extent -Ast $info.Ast -IllegalParent ForStatementAst, HashtableAst -ExpectedParent StatementBlockAst 
    
			if ($DoReplace)
			{
				# is there a token following on same line?
				if ($Tokens[$x].Extent.EndLineNumber -eq $Tokens[$x+1].Extent.StartLineNumber -and $Tokens[$x+1].Kind -ne 'NewLine' -and $Tokens[$x+1].Kind -ne 'EndOfInput')
				{
        
        
					Add-SteroidsTextChange -PositionInfo $Tokens[$x].Extent -ReplacementText "`r`n"
        
				}
				else
				{
					Add-SteroidsTextChange -PositionInfo $Tokens[$x].Extent 
				}
			}
		}
  
	}
	Invoke-SteroidsTextChange

}

