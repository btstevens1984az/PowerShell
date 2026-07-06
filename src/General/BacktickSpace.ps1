# Purpose: BacktickSpace — General-purpose PowerShell utilities.
# makes sure all lines end CRLF (ASCII code 13 and 10) 

& {
  # makes sure all lines end CRLF (ASCII code 13 and 10) 
  
  & {
    # get access to editor:
    $Editor = Get-SteroidsEditor
    
    # RegEx pattern for various types of line endings:
    $pattern = '(?m)\`\s{1,}$'
    
    # find these line endings and replace them with a normalized line ending:
    [Regex]::Matches($Editor.text, $pattern) | Add-SteroidsTextChange  -ReplacementText '`'
    
    # finalize changes:
    Invoke-SteroidsTextChange
  }
  
}
