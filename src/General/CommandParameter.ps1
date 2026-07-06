# Purpose: CommandParameter — General-purpose PowerShell utilities.
# Case-correct command parameter names

& {
    # array that will hold all commands that are going to be fixed:
    $commands = @{}
  
    # get all functions and cmdlets (these command types use Powershell-style parameters):
    foreach($command in (Get-Command -CommandType Function, Cmdlet))
    {
        $name = $command.Name
        if ($commands.ContainsKey($name) -eq $false)
        {
            $commands.Add($name, $command)
        }
    }
  
    # get all commands used in the current script:
    $items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Command')
    foreach($item in $items)
    { 
        $name = $item.CommandElements[0].Extent.Text
    
        # is it a known command?
        if ($commands.ContainsKey($name))
        {
            # find command parameter names
            $command = $commands.$name
            # find used parameters
            $item.CommandElements | Where-Object { $_ -is [System.Management.Automation.Language.CommandParameterAst]} |
            ForEach-Object {
                $parameterAST = $_
                $ParameterName = $parameterAST.ParameterName
        
                # matching parameter
                if (($command.Parameters -ne $null) -and $command.Parameters.ContainsKey($ParameterName))
                {
                    # find the case-correct official parameter name
                    $RealParameterName = $Command.Parameters[$ParameterName].Name
          
                    # is there a difference in casing?
                    if ($ParameterName -cne $RealParameterName)
                    {
                        # yes, replace with case-corrected version:
                        # but make sure to add an argument if this was a switch parameter
                        if ($parameterAST.Extent.Text.Contains(':'))
                        {
                            if ($parameterAST.Argument -ne $null -and $parameterAST.Argument -ne '')
                            {
                                $RealParameterName += ':' + $parameterAST.Argument
                            }
                        }
                        Add-SteroidsTextChange -PositionInfo $_.Extent -ReplacementText "-$RealParameterName"
                    }
                }
                else
                # check for incomplete parameter
                {
                    # do we have a parameter that starts with the parameter used?
                    $RealParameterName = ($command.Parameters.Values | Where-Object { $_.isDynamic -eq $false } | Select-Object -ExpandProperty Name) -like "$ParameterName*"
          
                    # is it an unambiguous parameter?
                    if ($RealParameterName.Count -eq 1)
                    {
                        # yes, replace the abbreviated parameter with the full parameter
                        # but make sure to add an argument if this was a switch parameter
                        if ($parameterAST.Extent.Text.Contains(':'))
                        {
                            if ($parameterAST.Argument -ne $null -and $parameterAST.Argument -ne '')
                            {
                                $RealParameterName[0] += ':' + $parameterAST.Argument
                            }
                        }
                        Add-SteroidsTextChange -PositionInfo $_.Extent -ReplacementText "-$($RealParameterName[0])"
                    }
                }
            }
        }
    }
  
    # finalize changes:
    Invoke-SteroidsTextChange
}