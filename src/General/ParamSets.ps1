# Purpose: ParamSets — General-purpose PowerShell utilities.
Function Get-MyData
{
    [cmdletbinding(DefaultParameterSetName='Computer')]
    param(
            [alias('IPAddress','__Server','HostName')]
            [parameter(ParameterSetName='Computer',
                        Position = 0,
                        Mandatory,
                        ValueFromPipeLine=$true,
                        ValueFromPipeLineByPropertyName
                        )]
            [parameter(ParameterSetName='User',
                        Position = 1,
                        Mandatory=$false)]                
            [string[]]$computername = "localhost",
            [parameter(ParameterSetName='User',
                        Position = 0)]
            [string]$username)

   process
   {
    foreach($computer in $computername)
    {
        if($computer)
        {
            Write-Verbose "Getting Computer info for $computer"
            Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer |
                Select-Object CSName,Caption,LastBootUpTime
        }
    }

    If($username)
    {
        Get-aduser -Identity $username

    }

    }
}

<#
$computerlist = "dc2","vmhost5","testsrv3"
$computerlist | Get-MyData
#$computerlist | ForEach-Object {get-mydata -computername $_}

Import-csv .\computers.csv | Get-MyData
#Import-csv .\computers.csv |ForEach-Object {get-mydata -computername $_.computername}

Get-MyData -computername $computerlist -Verbose
Get-MyData -ipaddress dc4

#>



#Get-MyData dc2


<#
            

#>