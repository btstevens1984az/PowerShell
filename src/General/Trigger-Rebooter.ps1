# Purpose: Trigger-Rebooter — General-purpose PowerShell utilities.
function Trigger-Rebooter{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName
    )

    Foreach($cn in $ComputerName)
    {
        {
            get-service -name "DHDeviceManager" -ComputerName $cn | Set-Service -Status Stopped
            get-service -name "DHDeviceManager" -ComputerName $cn | Set-Service -Status Running  
            Write-Debug "$cn writing x64"
        }
        {
            get-service -name "DHDeviceManager" -ComputerName $cn | Set-Service -Status Stopped
            get-service -name "DHDeviceManager" -ComputerName $cn | Set-Service -Status Running   
            Write-Debug "$cn writing x32"
        }
    else
        {
            Write-Debug "$cn No device manager found"
        }
       
    }
}


function Trigger-RebooterParallel
{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$InputObject
    )
    
    Invoke-Parallel -InputObject (get-content($InputObject)) -ScriptBlock {
            . "U:\Modules\Trigger-Rebooter.ps1";
            Trigger-Rebooter $_
    } -Throttle 500 -runspacetimeout 30
}