# Purpose: Set-EnvVariable — General-purpose PowerShell utilities.
function  Set-EnvVariable {
    <#
	.SYNOPSIS
	Sets values ​​in one of the system / user variables (PATH, TMP, JAVA_HOME, ...)
	.DESCRIPTION
	Sets values ​​in one of the system / user variables (PATH, TMP, JAVA_HOME, ...)
	By default, it adds values ​​to the system PATH.
	.PARAMETER ComputerName
	Parameter specifying the machine list.
    . PARAMETER  VarName
    Optional parameter. 
    Specifies the name of the variable to modify. PATH, TMP, ...
    
    The default is PATH.
	
	, Parameter  Path
	List of paths to be added.
	
	.PARAMETER Scope
    Optional parameter. 
    Specifies whether user or system variables are modified.
    
    Possible values ​​are User / Machine. The default is Machine.
	
	. PARAMETER  Separator
    Optional parameter. 
    Indicates which character separates the paths. The default is a semicolon (;).
	
	.PARAMETER Replace
	Switch telling whether to keep the original values ​​or replace them with new ones. 
	
	.EXAMPLE
	Set-EnvVariable -Path 'C:\git','C:\temp' -ComputerName $b116 
	Adds paths entered on the system PATH on all machines in $ b116.
	.EXAMPLE
	Set-EnvVariable -Path 'C:\Program Files\Java\jdk1.8.0_74' -VarName JAVA_HOME -replace
	In the system variable JAVA_HOME, it replaces any existing path with a new one.
    It is possible to use the alias set-path or add-path
	Taken from Jason Morgan
	tips http://blogs.splunk.com/2013/07/29/powershell-profiles-and-add-path/
	
    #>

    [cmdletbinding(DefaultParameterSetName = 'Default')]
    Param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $True, ValueFromPipelineByPropertyName)]
        [string[]] $ComputerName = $env:COMPUTERNAME
        ,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Concat')]
        [string] $VarName = "PATH"
        ,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Concat')]
        [array] $Path
        ,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Concat')]
        [ValidateSet('Machine', 'User')]
        [string] $Scope = 'Machine'
        ,
        [Parameter(ParameterSetName = 'Concat')]
        [ValidateLength(0, 1)]
        [string] $Separator = ';'
        ,
        [Parameter(ParameterSetName = 'Concat')]
        [switch] $Replace
    )

    begin {
    }
    
    process {
        Invoke-Command2 -ComputerName $ComputerName -argumentList $Replace, $Path, $VarName, $Scope, $Separator -ScriptBlock {	
            param (
                $Replace,
                $Path,
                $VarName,
                $Scope,
                $Separator
            )

            $computer = $env:COMPUTERNAME
            $firstRun = 1

            foreach ($Value in $Path) {
                # I will convert the result to an array so I can use the contains method for exact match comparison
                $CurrentValue2 = @([Environment]::GetEnvironmentVariable($VarName, $Scope) -replace "$Separator$Separator", "$Separator" -split "$Separator")
                $CurrentValue = {$CurrentValue2}.invoke()
                # if I rewrite the existing values, then it makes no sense to check whether they are already there, I have to set everything again
                # I 'll reduce everything because contains is case sensitive
                if (!$Replace -and ($CurrentValue.tolower().Contains("$Value".tolower()))) { 
                    Write-Warning "Folder ""$Value"" is already in the path"
                    continue
                } 

                # I end the current values ​​with a separator
                $Current = $CurrentValue -join "$Separator"
                if ($Current) {
                    $Current = $Current + $Separator
                }
                
                if (!$Replace) {
                    # I will add more to the existing routes
                    [Environment]::SetEnvironmentVariable($VarName, ($Current + $Value), $Scope)
                } else {
                    # existing values ​​overwrite with new ones
                    
                    if ($Path.Count -gt 1) {
                        # I add more paths
                        if ($firstRun) {
                            # override the path of the new value
                            [Environment]::SetEnvironmentVariable($VarName, $Value, $Scope)
                        } else {
                            # I 'm adding more paths and this is the least second path added (the originals have already been deleted)
                            [Environment]::SetEnvironmentVariable($VarName, ($Current + $Value), $Scope)
                        }
                    } else {
                        # override the path of the new value
                        [Environment]::SetEnvironmentVariable($VarName, $Value, $Scope)
                    }

                }
            
                if ($? -eq $true) {
                    Write-Output "Na $computer OK."
                } else {
                    Write-Warning "Na $computer NOK."
                }

                $firstRun = 0
            }

        }
    }
    
    end {
        if ($VarName -ne "path") { Write-Warning "Projevi se pravdepodobne az po restartu" }
    }
}

set-alias Set-Path Set-EnvVariable
set-alias Add-Path Set-EnvVariable