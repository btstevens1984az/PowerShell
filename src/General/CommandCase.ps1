# Purpose: CommandCase — General-purpose PowerShell utilities.
# Case-corrects command names

& {
  # array that holds all known command names:
  $commands = @{}
  
  # include all functions that are defined in the script
  $items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Function')
  
  # add each function that is defined in the script
  foreach($item in $items)
  { 
    $name = $item.Name
    if ($commands.ContainsKey($name) -eq $false)
    {
      $commands.Add($name, $name)
    }
  }
  
  # add all known commands from the powershell environment:
  foreach($command in (Get-Command -CommandType Alias, Function, Cmdlet, Application))
  {
    $name = $command.Name
    if ($commands.ContainsKey($name) -eq $false)
    {
      $commands.Add($name, $name)
    }
  }
  
  # add all application names without extension:
  foreach($command in (Get-Command -CommandType Application))
  {
    $name = $command.Name
    $name2 = [System.IO.Path]::GetFileNameWithoutExtension($name)
    if ($commands.ContainsKey($name2) -eq $false)
    {
      $commands.Add($name2, $name)
    }
  }
  
  # find all commands used in the current script:
  $items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Command')
  foreach($item in $items)
  { 
    $name = $item.CommandElements[0].Extent.Text

    # if the command is known...
    if ($commands.ContainsKey($name))
    {
      # ...replace command with the correctly cased command name:
      Add-SteroidsTextChange -PositionInfo $item.CommandElements[0].Extent -ReplacementText $commands.$name
    }
  }

  # finalize changes:
  Invoke-SteroidsTextChange
}