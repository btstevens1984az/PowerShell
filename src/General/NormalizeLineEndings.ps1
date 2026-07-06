# Purpose: NormalizeLineEndings — General-purpose PowerShell utilities.
# makes sure all lines end CRLF (ASCII code 13 and 10) 

& {
	# get access to editor:
	$Editor = Get-SteroidsEditor
  
	# RegEx pattern for various types of line endings:
	$pattern = '\r\n|\n\r|\n|\r'
  
	# find these line endings and replace them with a normalized line ending:
	[Regex]::Matches($Editor.text, $pattern) | Add-SteroidsTextChange  -ReplacementText "`r`n"
  
	# finalize changes:
	Invoke-SteroidsTextChange
}
