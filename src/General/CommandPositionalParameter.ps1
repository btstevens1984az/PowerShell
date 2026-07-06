# Purpose: CommandPositionalParameter — General-purpose PowerShell utilities.
& {
  Set-StrictMode -Off

  $commands = @{}
  
  # get all commands available
  foreach($command in (Get-Command -CommandType Function, Cmdlet))
  {
    # add each unique command to a hash table
    $name = $command.Name
    if ($commands.ContainsKey($name) -eq $false)
    {
      $commands.Add($name, $command)
    }
  }

  # get all commands found in script
  $items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Command')
  $SplattedItems = @()
	
  # examine each command found in script
  :outer foreach($item in $items)
  { 
    $namedparameters = @{}
    $positionalparameters = @{}
    
    # get command name...
    $CommandName = $item.CommandElements[0].Extent.Text
    
    # ...is it known?
    if ($commands.ContainsKey($CommandName))
    {
      # yes, check parameter definitions
      $Command = $commands[$CommandName]
      if ($Command.Parameters -ne $null)
      {
        # identify parameters used in the command
        $position = 0
        $elements = $item.CommandElements.Count -1
        for($i=1; $i -le $elements; $i++)
        {
          $element = $item.CommandElements[$i]
          # is it a non-splatted parameter?
          if ($element -is [System.Management.Automation.Language.CommandParameterAst])
          {
            # look up the parameter in the parameter definition
            $parameterName = $element.ParameterName
            $ParameterObject = $null
            if ($command.Parameters.ContainsKey($parameterName) -eq $false)
            {
              # not found, is it a dynamic parameter?
              $ParameterName = ($command.Parameters.Values | Where-Object { $_.isDynamic -eq $false } | Select-Object -ExpandProperty Name) -like "$ParameterName*"
              if ($command.Parameters.ContainsKey($parameterName) -eq $false)
              { continue outer }
            }
            # static parameter
            $ParameterObject = $Command.Parameters[$ParameterName]
            if ($ParameterObject.SwitchParameter -eq $false)
            {
              # no switch parameter
              $namedparameters.Add($ParameterName, $item.CommandElements[$i+1])
              $i++
            }
            else
            {
              # switch parameter
              $namedparameters.Add($parameterName, $null)
            }
          }
          else
          {
            # is it a splatted parameter?
            if ($item.CommandElements[$i] -is [System.Management.Automation.Language.VariableExpressionAst] -and $item.CommandElements[$i].Splatted )
            {
              $SplattedItems += $position
            }
            $positionalparameters.Add($position, $item.CommandElements[$i])
            $position++
						
          }
      
        }
      }
      # identify the correct parameterset
      $validSets = :setloop foreach($set in $Command.ParameterSets)
      {
        # all named parameters must be in
        foreach($par in $namedparameters.Keys)
        {
          if ($set.Parameters.Name -contains $par -eq $false)
          {
            continue setloop
          }
        }
        $set
      }
    
      if ($validSets.Count -eq 0) { continue outer }
    
      :parameterSets foreach($set in ($validSets | Sort-Object { $_.IsDefault } -Descending))
      {
        # find positional parameters
        $changes = @()
        $shift = 0
        foreach($parameter in ($set.Parameters | Sort-Object -Property Position))
        {
        
          $position = $parameter.Position
          if ($position -ge 0)
          {
            $name = $parameter.Name
            if ($namedparameters.ContainsKey($name)) 
            { 
              $shift-- 
            }
            else
            {
              $realposition = $position + $shift
              
              # if a paremeter takes values from remaining arguments, then do not turn it into a named parameter
              if ($positionalparameters.ContainsKey($realposition) -and ($parameter.ValueFromRemainingArguments -eq $false -or ($positionalparameters.Count -lt 2)))
              {
                # does the data type fit?
                $skip = $false
                if ($validSets.Count -eq 1)
                {
                  # one set remaining, do always
                }
                elseif ($positionalparameters[$realposition].GetType() -eq [System.Management.Automation.Language.ScriptBlockExpressionAst])
                {
                  if ($parameter.ParameterType -ne [ScriptBlock] -and $parameter.ParameterType -ne [ScriptBlock[]])
                  {
                    $changes = @()
                    continue parameterSets
                  }
                }
                elseif ($positionalparameters[$realposition].GetType() -eq [System.Management.Automation.Language.StringConstantExpressionAst])
                {
                  if ($parameter.ParameterType -ne [String] -and $parameter.ParameterType -ne [String[]] -and $parameter.ParameterType -ne [Object] -and $parameter.ParameterType -ne [Object[]])
                  {
                    $changes = @()
                    continue parameterSets
                  }
                }
                elseif ($positionalparameters[$realposition].GetType() -eq [System.Management.Automation.Language.ParenExpressionAst])
                {
                  if ($parameter.ParameterType -ne [Object] -and $parameter.ParameterType -ne [Object[]])
                  {
                    $changes = @()
                    continue parameterSets
                  }
                }
                elseif ($positionalparameters[$realposition].GetType() -eq [System.Management.Automation.Language.ArrayLiteralAst])
                {
                  if ($parameter.ParameterType -ne [Object] -and $parameter.ParameterType -ne [Object[]])
                  {
                    $changes = @()
                    continue parameterSets
                  }
                }
                elseif ($positionalparameters[$realposition].GetType() -eq [System.Management.Automation.Language.VariableExpressionAst])
                {
                  if ($parameter.ParameterType -ne $positionalparameters[$realposition].StaticType -and $parameter.ParameterType.GetElementType() -ne $positionalparameters[$realposition].StaticType)
                  {
                    $changes = @()
                    continue parameterSets
                  }
                }
                else
                {
                  $i = 1  
                }
                if ($skip -eq $false)
                {
                  if ($SplattedItems -notcontains $realposition)
                  {
                    $changes += 1
                    $padding = ' '
                    $statement = $positionalparameters[$realposition].Parent
                    $offset = $positionalparameters[$realposition].Extent.StartOffset - $statement.Extent.StartOffset
                    if ($statement.Extent.Text.SubString($offset-1, 1) -eq ' ')
                    {
                      $padding = ''
                    }
                    $changes[$changes.Count-1] = @($positionalparameters[$realposition].Extent.StartOffset, $positionalparameters[$realposition].Extent.StartOffset, ($padding + '-' + $parameter.Name + ' ')) 
                  }
                }
              }
            }
          
          }
        }
        foreach($change in $changes)
        {
          [ISESteroids.SteroidsFixer.Helpers]::AddTextChange($change[0], $change[1], $change[2])
        }
        break
      }
    
    
    }
  
  
  }
  Invoke-SteroidsTextChange
}