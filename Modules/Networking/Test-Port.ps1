# Purpose: Test-Port — Network diagnostics, DNS, DHCP, and connectivity.
function Test-Port
{
    Param(
        [parameter(ParameterSetName='ComputerName', Position=0)]
        [string]
        $ComputerName,

        [parameter(ParameterSetName='IP', Position=0)]
        [System.Net.IPAddress]
        $IPAddress,

        [parameter(Mandatory=$true , Position=1)]
        [int]
        $Port,

        [parameter(Mandatory=$true, Position=2)]
        [ValidateSet("TCP", "UDP")]
        [string]
        $Protocol
        )

    $RemoteServer = If ([string]::IsNullOrEmpty($ComputerName)) {$IPAddress} Else {$ComputerName};

    If ($Protocol -eq 'TCP')
    {
        $test = New-Object System.Net.Sockets.TcpClient;
        Try
        {
            Write-Host "Connecting to "$RemoteServer":"$Port" (TCP)..";
            $test.Connect($RemoteServer, $Port);
            Write-Host "Connection successful";
        }
        Catch
        {
            Write-Host "Connection failed";
        }
        Finally
        {
            $test.Dispose();
        }
    }

    If ($Protocol -eq 'UDP')
    {
        Write-Host "UDP port test functionality currently not available."
        <#
        $test = New-Object System.Net.Sockets.UdpClient;
        Try
        {
            Write-Host "Connecting to "$RemoteServer":"$Port" (UDP)..";
            $test.Connect($RemoteServer, $Port);
            Write-Host "Connection successful";
        }
        Catch
        {
            Write-Host "Connection failed";
        }
        Finally
        {
            $test.Dispose();
        }
        #>
    }
}