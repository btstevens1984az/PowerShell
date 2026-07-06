# Purpose: IllegalCharacters — General-purpose PowerShell utilities.
# Replaces individual ASCII and UNICODE characters

# use this to change illegal characters
# illegal characters may be introduced when scripts are copied from
# web pages or text editors, and typographic changes were made

& {
	# get access to the editor:
	$Editor = Get-SteroidsEditor
  
	# get script content:
	$text = $Editor.Text
  
	# this table controls character replacements
	# the KEY is the hexadecimal value of the character to replace
	# four-digit numbers represent UNICODE characters
	# the VALUE is the character that is used as replacement
	$replacementTable = @{
    
		# UNICODE characters to replace:
		'2013' = '-'
		'2014' = '-'
		'2015' = '-'
		'201C' = '"'
		'201D' = '"'
		'201E' = '"'
		'2018' = "'"
		'2019' = "'"
		'201A' = "'"
		'201B' = "'"
		'2033' = '"'
		'00BB' = '"'
		'02BA' = '"'
		'02BB' = "'"
		'02BC' = "'"
		'02BD' = "'"
		'02DD' = '"'
		'02EE' = '"'
		'02F5' = '"'
		'02F6' = '"'
		'030B' = '"'
		'030F' = '"'
		'0312' = "'"
		'0313' = "'"
		'0314' = "'"
		'0315' = "'"
    
		# ASCII Codes to replace:
		'0001' = ''
		'0002' = ''
		'0003' = ''
		'0004' = ''
		'0005' = ''
		'0006' = ''
		'0007' = ''
		'0008' = ''
		'000B' = ''
		'000C' = ''
		'000E' = ''
		'000F' = ''
	}
  
	# loop through the characters that need replacements
	foreach($UnicodeChar in $replacementTable.Keys)
	{
		# find the instances using a regular expression
		# the return value is always a pair of two:
		# - a MatchCollection returned by Match()
		# - and a string containing the desired replacement character
    
		[Regex]::Matches($text, "\u$UnicodeChar") | Add-SteroidsTextChange -ReplacementText $replacementTable[$UnicodeChar]
	}
  
	# finalize all changes:
	Invoke-SteroidsTextChange  
}

