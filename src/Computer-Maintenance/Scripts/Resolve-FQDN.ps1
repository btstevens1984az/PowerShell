Function Resolve-FQDN {
<#
.SYNOPSIS
    Resolves a hostname or IPv4 address to a fully qualified domain name
.DESCRIPTION
    Resolves a hostname or IPv4 address to a fully qualified domain name
.PARAMETER Computer
    Either the hostname or IPv4 address of the computer you want resolved to FQDN
.EXAMPLE
    Resolve-FQDN -Computer $env:computername
    Display the FQDN of this computer
.EXAMPLE
    Resolve-FQDN -Computer "174.190.143.120"
    Display the FQDN of the computer whose IPv4 address is 174.190.143.120
.EXAMPLE
    Resolve-FQDN .
    Display the FQDN of this computer
.EXAMPLE
    "174.190.143.120" | Resolve-FQDN
    Display the FQDN of the computer whose IPv4 address is 174.190.143.120
.EXAMPLE
    $DomainController = (($env:logonserver).Substring(2))
    Resolve-FQDN $DomainController
    Display the FQDN of the Active Directory Domain Controller that you authenticated against when you logged onto Windows.
.EXAMPLE
    PS C:\> Resolve-FQDN -Computer "NonExistentPC"
    The computer "NonExistentPC" does not have an entry in DNS so the function will return the value $False
Attempting to resolve a FQDN for a system that does not have an entry in DNS will be slow, and will take 1-5 seconds to return a value of $False
#>
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeLine=$True,ValueFromPipeLineByPropertyName=$True,Mandatory=$True)]
        [Alias("host")]
        [string] $Computer
    )
    Process {
        if ($Computer -eq '.') {
            $Computer = $env:computername
        }
        Try {
            $FQDN = [System.Net.Dns]::GetHostEntry($Computer).HostName
            write-output $FQDN
        } Catch {
            Write-Output $False
        }
    }
} #EndFunction Resolve-FQDN


if (-not (test-path Variable:AliasesToExport)) {
    $AliasesToExport = @()
}
if (-not (test-path Variable:VariablesToExport)) {
    $VariablesToExport = @()
}
#$AliasesToExport += 'AliasName'
#$VariablesToExport += 'VariableName'
