# Purpose: Push-RestartFlag — General-purpose PowerShell utilities.
function Push-RestartFlag
{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$cn
    )

            
    }

    }

}




function Push-RestartFlagParallel
{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$InputObject
    )
    
    Invoke-Parallel -InputObject (get-content($InputObject)) -ScriptBlock {
            . "U:\Modules\Push-RestartFlag.ps1";
            Push-RestartFlag $_
    } -Throttle 500 -runspacetimeout 30
}