# Purpose: ReplaceAliases — General-purpose PowerShell utilities.
# searches for Aliases and replaces them with the underlying
# original command

& {
  Set-StrictMode -Off
  # get access to the AST (abstract syntax tree):
  $info = Get-SteroidsAST
  
  # find commands in the script: 
  $Commands = $info.Ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)
  
  # get a list of all aliases:
  $Aliases = Get-Alias | 
    Group-Object -Property Name -AsHashTable -AsString
  
  # examine each command:
  foreach($command in $Commands)
  {
    # get the command name:
    $name = $command.CommandElements[0].Value
    
    # if there is a name... 
    if ($name -ne $null)
    {
      # try and get an alias with that name:
      if ($aliases.ContainsKey($name))
      {
        # yes, so replace the current command with the alias definition:
        Add-SteroidsTextChange -PositionInfo $command.CommandElements[0].extent -ReplacementText $aliases[$name].ResolvedCommand.Name
      }
    }
  }
  
  # finalize changes:
  Invoke-SteroidsTextChange
}
