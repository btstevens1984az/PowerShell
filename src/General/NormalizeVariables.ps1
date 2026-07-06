# Purpose: NormalizeVariables — General-purpose PowerShell utilities.
& {
  $variables = [ISESteroids.SteroidsFixer.Helpers]::GetAST('VariableExpression')
  $lookup = @{}


  foreach($variable in $variables)
  {
    if ($variable.Extent.Text.StartsWith('$') -or $variable.Extent.Text.StartsWith('@'))
    {
      $name = $variable.VariablePath.toString()
      if ($variable.Splatted)
      {
        $prefix = '@'
      }
      else
      {
        if ($variable.Extent -like '$using:*')
        {
          $prefix = '$using:'
        }
        else
        {
          $prefix = '$'
        }
      }
    
      if ($lookup.ContainsKey($name))
      {
        if ($name -cne $lookup[$name])
        { 
          Add-SteroidsTextChange -PositionInfo $variable.Extent -ReplacementText ($prefix + $lookup[$name]) 
        }
      }
      else
      {
        $lookup.Add($name, $variable.Extent.Text.Substring(1))
      }
    }
  }

  Invoke-SteroidsTextChange

}
