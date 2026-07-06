# Purpose: MakeSnippet — General-purpose PowerShell utilities.
$text = @'
function Get-Function 
{
    param($param1, $param2)
    return $param1 + $param2
}
'@

New-IseSnippet -Description "Simple Function" -Text $text -Title "Simple Function" -Author Jeff