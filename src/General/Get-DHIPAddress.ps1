# Purpose: Get-DHIPAddress — General-purpose PowerShell utilities.
[CmdletBinding()]             
 Param              
   (                        
    [Parameter(Position=1, 
               ValueFromPipeline=$true, 
               ValueFromPipelineByPropertyName=$true)] 
    [String[]]$ComputerName = $env:COMPUTERNAME, 
    [Switch]$IPV6only, 
    [Switch]$IPV4only 
   )#End Param 
 
Begin             
{             
 Write-Verbose "`n Checking IP Address . . .`n" 
 $i = 0             
}#Begin           
Process             
{ 
    $ComputerName | ForEach-Object { 
        $HostName = $_ 
 
        Try { 
            $AddressList = @(([net.dns]::GetHostEntry($HostName)).AddressList) 
        } 
        Catch { 
            "Cannot determine the IP Address on $HostName" 
        } 
 
        If ($AddressList.Count -ne 0) 
        { 
            $AddressList | ForEach-Object { 
            if ($IPV6only) 
                { 
                    if ($_.AddressFamily -eq "InterNetworkV6") 
                        { 
                            New-Object psobject -Property @{ 
                                IPAddress    = $_.IPAddressToString 
                                ComputerName = $HostName 
                                } | Select ComputerName,IPAddress    
                        } 
                } 
            if ($IPV4only) 
                { 
                    if ($_.AddressFamily -eq "InterNetwork") 
                        { 
                              New-Object psobject -Property @{ 
                                IPAddress    = $_.IPAddressToString 
                                ComputerName = $HostName 
                               } | Select ComputerName,IPAddress    
                        } 
                } 
            if (!($IPV6only -or $IPV4only)) 
                { 
                      New-Object psobject -Property @{ 
                        IPAddress    = $_.IPAddressToString 
                        ComputerName = $HostName 
                       } | Select ComputerName,IPAddress 
                } 
        }#IF 
        }#Foreach-Object(IPAddress) 
    }#Foreach-Object(ComputerName) 
 
}#Process 
 }

