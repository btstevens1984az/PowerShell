# -----------------------------------------------------------------------------------------
# Script: Invoke-RemoteWOL.ps1
# Date: April 24, 2015
# Version: 1.0
# Purpose: This script is used to do WOL
#------------------------------------------------------------------------------------------

<#
.SYNOPSIS
   Passes the Mac Addresses obtained from a DHCP server to a remote computer in an ip subnet that executes WOL
   for each MAX address in the list of Mac Addresses
.DESCRIPTION
  The main script copies the Invoke-WOL script to a computer in another ip subnet and uses Win32_Process wmi class to create a process
  that starts Powershell and executes the Invoke-WOL script. The Client Leases are passed to the Powershell process as an argument and 
  the Invoke-WOL script creates a WOL packet based on the MAC Addresses and broacats each packet on the ip subnet.
  
.PARAMETER InputObject
   A custom PSObject that has the details of the DHCP client leases
.PARAMETER Computer
  The remote computer that sends out the WOL packets
.PARAMETER UserName
  The user name that is used to start the powershell process that sends out the WOL packet
.PARAMETER Password
  The password

  Date: 5/18/2015
  Version: 1.0
   
#>
Function Invoke-RemoteWOL {
[Cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [PSObject[]]$InputObject,

        [Parameter(Mandatory=$true)]
        $Computer,

        [Parameter(Mandatory=$false)]
        $UserName,

        [Parameter(Mandatory=$false)]
        $Password
    )

#region Script Block

# This script block executes WOL for each MAC Adress in an array of Mac Addresses
$InvokeRemoteWOL = {

    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $MacAddress,
        [Parameter(Mandatory=$true)]
        $BroadCastAddress
    )

    # Based on http://viniciuscanto.blogspot.com/2010/01/wake-on-lan-powershell-waking-up.html
    function Execute-WOL {
        
        [Cmdletbinding()]
        Param(
            [Parameter(Mandatory=$true)]
            $MacAddress,
            [Parameter(Mandatory=$true)]
            $BroadCastAddress
        )


        # The number of times to send out the WOL packet for each MAC Address
        # This has to be sent out multiple times to work
        [int]$NumberPackets = 4

        # Create the UDP datagram ssocket
        $socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Dgram, [System.Net.Sockets.ProtocolType]::Udp)

        # Setup the connection information
	    $destination = [System.Net.IPAddress]::Parse($broadcastAddress)
	    $endpoint = New-Object System.Net.IPEndpoint($destination,0) 

        # Send the packet
        
        # Create the packet
	    [byte[]]$buffer = @(255,255,255,255,255,255) 
	    $buffer += (($MacAddress.split(':-') | foreach {[byte]('0x' + $_)}) * 16)
    
        # Send the packet. Need to send it a few times for it to work
        for ($i = 0; $i -le $NumberPackets; $i ++) {
             $sent = $socket.Sendto($buffer, $buffer.length, 0, $endpoint) 
             Start-Sleep 5
        }
	
        #"$sent bytes sent. The computer $macAddress may be initializing."


    }

    # Start of the Invoke-RemoteWOL Script

    # We get the broacast address of the remote ip subnet and invoke WOL
    # for each MAC Address in the array of MAC Addresses
    try {
    
         foreach ($Mac in $MacAddress) {
            
            if ($Mac -eq $null) {
                continue
            }

            Execute-WOL  -MacAddress $Mac -BroadCastAddress $BroadCastAddress
         }
    }
    catch {

        if ($_.Exception.InnerException) {
           $ExceptionMessage = $_.Exception.InnerException
        }
        else {
         $ExceptionMessage = $_.Exception.Message
        }
        
        $ExceptionMessage 

    }

    
}
#endregion Script Block

function Test-Online {

    Param (
        [PSObject]$InputObject
    )

    $objWOLInfo = [ordered]@{}
    $objWOLInfo.ClientIP = $InputObject.ClientIP
    $objWOLInfo.ClientName = $InputObject.ClientName
    $objWOLInfo.MacAddress = $InputObject.MacAddress
        
    if (Test-Connection -ComputerName $InputObject.ClientIP -BufferSize 16 -Count 1 -Quiet -ErrorAction SilentlyContinue) {

        $objWOLInfo.Online = $true
    }
    else {
        $objWOLInfo.Online = $false
    }

    $objWOLInfo
}

try {
    
    # Check that the computer that we will use for WOL is online
    if (-not (Test-Connection -ComputerName $Computer -BufferSize 16 -Count 2 -Quiet)) {
         $ErrorMessage = $Computer + " is offline"
         $jsonresult = '{'
         $jsonresult += " 'Error' :"
         $jsonresult += $ErrorMessage | ConvertTo-Json
         $jsonresult += '}'
         $jsonresult | Out-String
         return
     }

    $MacAddress = $null

    # Convert the MAC addresses in the DHCP client leases to a comma delimted string of mac addresses
    foreach($mac in $InputObject.MacAddress) {
        $MacAddress += $mac + ","
    }

    # Calculate the broadcast address
    $network = [net.ipaddress]::Parse($InputObject.ClientIP[0])
    $subnet = [net.ipaddress]::Parse($InputObject.SubnetMask[0])
    $broadcast = New-Object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $subnet.address -bor $network.address))
    

    if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {
            
        $secpassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $secpassword
        $networkCred = $cred.GetNetworkCredential()
    }

    # Create a file and write the command to be executed to the file
    $filename = "Invoke-WOL.ps1"
    $file = New-Item -type file $filename -Force
    Add-Content $file $InvokeRemoteWOL

    # Copy over the powershell script to the remote computer
    $remotehost = "\\$Computer\admin`$"
    $destPath = $remotehost + "\temp\"

    if ($networkCred) {

        $remoteuser = $networkCred.Domain.ToString() + "\" + $networkCred.UserName.ToString()
        net use $remotehost $networkCred.Password /USER:$remoteuser | Out-Null
        Copy-Item -Path $file  -Destination $destPath -ErrorAction Stop
        net use $remotehost /delete | Out-Null
    }
    else {

        Copy-Item -Path $file  -Destination $destPath -ErrorAction Stop
    }

    # Use WMI to start the process on the remote computer
    $processstartcmd = "cmd /c `"powershell.exe -ExecutionPolicy RemoteSigned -command `"C:\WINDOWS\temp\$filename -MacAddress $MacAddress -BroadCastAddress $broadcast`"`""
    #$processstartcmd

    $rpparameters = @{

        'ComputerName' = $Computer;
        'Class' = 'Win32_Process';
        'Name' =  'Create';
        'ArgumentList' = $processstartcmd;
        'ErrorAction' = 'Stop'
    }

    if ($cred) {

        $rpparameters.Credential = $cred
    }
    
    $remoteprocess = Invoke-WmiMethod @rpparameters
    #$remoteprocess

    if ($remoteprocess.returnvalue -ne 0) {
        $ExceptionMessage = "Failed to launch $processstartcmd on $Computer. Return value is " + $remoteprocess.returnvalue
        $jsonresult = '{'
        $jsonresult += " 'Error' :"
        $jsonresult += $ExceptionMessage | ConvertTo-Json
        $jsonresult += '}'
        $jsonresult | Out-String 
        return
    }

    # Wait for the process to finish
    # based on http://stackoverflow.com/questions/18341767/powershell-check-on-remote-process-if-done-continue

    $waitparameters = @{
        'ComputerName' = $Computer;
        'Class' = 'Win32_Process';
        'Filter' = "ProcessId=`"$($remoteprocess.ProcessId)`"";
        'ErrorAction' = 'SilentlyContinue'
    }

    if ($cred) {

        $waitparameters.Credential = $cred
    }

    $runningCheck = { Get-WmiObject @waitparameters | ? { ($_.ProcessName -eq 'cmd.exe') } }

    while ($null -ne (& $runningCheck)) {
        Start-Sleep -m 250
    }
    
    $WOLStatus = @()

    # Check which computers are online
    foreach($obj in $InputObject) {

        $WOLStatus += Test-Online -InputObject $obj
    }

    $jsonresult = "{"
    $jsonresult += "'Data':"
    $jsonresult += $WOLStatus| ConvertTo-Json
    $jsonresult += "}"
    $jsonresult | Out-String

}
catch {
    
    $ExceptionMessage = $_ | format-list -force

    $jsonresult = '{'
    $jsonresult += " 'Error' :"
    $jsonresult += $ExceptionMessage | ConvertTo-Json
    $jsonresult += '}'
    $jsonresult | Out-String 
}
}
