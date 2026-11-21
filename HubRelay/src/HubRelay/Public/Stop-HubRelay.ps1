function Stop-HubRelay {
    <#
    .SYNOPSIS
        Stops the HubRelay HTTP listener and cleans up the background runspace.
    #>
    [CmdletBinding()]
    param()

    if (-not $script:HubRelayState.IsRunning -and -not $script:HubRelayState.Listener) {
        Write-Verbose 'HubRelay is not running.'
        return
    }

    if ($script:HubRelayState.StopFlag) {
        $script:HubRelayState.StopFlag.Stop = $true
    }

    $listener = $script:HubRelayState.Listener
    if ($listener) {
        try {
            if ($listener.IsListening) { $listener.Stop() }
        }
        catch { Write-Verbose "Listener stop: $($_.Exception.Message)" }
        try { $listener.Close() } catch { }
    }

    $ps = $script:HubRelayState.PowerShell
    if ($ps) {
        try {
            if ($script:HubRelayState.AsyncHandle) {
                $null = $ps.EndInvoke($script:HubRelayState.AsyncHandle)
            }
        }
        catch { Write-Verbose "Runspace end: $($_.Exception.Message)" }
        try { $ps.Dispose() } catch { }
    }

    $rs = $script:HubRelayState.Runspace
    if ($rs) {
        try { $rs.Close() } catch { }
        try { $rs.Dispose() } catch { }
    }

    $script:HubRelayState.Listener = $null
    $script:HubRelayState.PowerShell = $null
    $script:HubRelayState.Runspace = $null
    $script:HubRelayState.AsyncHandle = $null
    $script:HubRelayState.IsRunning = $false
    $script:HubRelayState.StopFlag = $null
    $script:HubRelayState.TokenHash = $null
    $script:HubRelayState.Prefix = $null

    Write-Host 'HubRelay stopped.'
}
