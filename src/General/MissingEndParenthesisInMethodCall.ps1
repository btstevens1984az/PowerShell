# Purpose: MissingEndParenthesisInMethodCall — General-purpose PowerShell utilities.

param($StartOffset,$Length,$Ast)

# is the error at the very end of the file? 
$isEnd = $Ast.Extent.EndOffset - ($StartOffset + $Length) -lt 1
# then move the insertion point one to the right
if ($isEnd)  { $StartOffset++ }
# add a closing parenthesis
return New-Object -TypeName ISESteroids.PSSharper.FixInformation($StartOffset, ')')
