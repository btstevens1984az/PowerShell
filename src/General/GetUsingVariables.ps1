# Purpose: GetUsingVariables — General-purpose PowerShell utilities.
Function GetUsingVariables {
    Param ([scriptblock]$ScriptBlock)
    $ScriptBlock.ast.FindAll({$args[0] -is [System.Management.Automation.Language.UsingExpressionAst]},$True)    
}