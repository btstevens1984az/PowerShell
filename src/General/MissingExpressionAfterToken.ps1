# Purpose: MissingExpressionAfterToken — General-purpose PowerShell utilities.

param($StartOffset,$Length,$Ast)

# is the error at the very end of the file? 
$isEnd = $Ast.Extent.EndOffset - ($StartOffset + $Length) -lt 1
# then move the insertion point one to the right
if (!$isEnd)  { $StartOffset-- }

# is it inside a hash?
$hash = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.HashtableAst] -and $args[0].Extent.StartOffset -lt $StartOffset -and $args[0].Extent.EndOffset -gt $StartOffset }, $true)

if ($hash.Count -gt 0)
{
  return New-Object -TypeName ISESteroids.PSSharper.FixInformation($StartOffset, 1, ';')
  
}
else
{

  return New-Object -TypeName ISESteroids.PSSharper.FixInformation($StartOffset, 1)
}