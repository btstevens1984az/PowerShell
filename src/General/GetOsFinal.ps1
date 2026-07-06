
function Get-OS {
<#
		.SYNOPSIS
			The Get-OS function returns operating system information.

		.DESCRIPTION
			The Get-OS function returns operating system information using WMI.

		.PARAMETER  Computer
			Specify one or more computer names to retrieve operating system info from.

		.EXAMPLE
			PS C:\> Get-OS
			This command returns operating system information from the local computer

		.EXAMPLE
			PS C:\> Get-OS -computer "remoteComputer"
			This command returns operating system information from a remote computer

		.EXAMPLE
			PS C:\> $computers = Get-Content .\computers.txt
			PS C:\>	$computers | Get-OS
			These commands retrieve operating system information from the list of computer names in computers.txt.
		.EXAMPLE
			PS C:\> $computers = Get-ADcomputer -filter * | select-object -expandproperty name
			PS C:\>	$computers | Get-OS
			These commands retrieve operating system information from all computers in the current domain that are available.
		
		.INPUTS
			System.String

		.OUTPUTS
			System.Management.ManagementObject

			Additional information about the Get-OS can go here.

		.LINK
			Get-WmiObject

		.LINK
			about_comment_based_help

#>
	[CmdletBinding()]
	[OutputType([System.Management.ManagementObject])]
	param
    (
	    [parameter( Mandatory=$true,
                    Position = 0,
                    HelpMessage="An array of computer names.",
                    ValueFromPipeline=$True, 
	                ValueFromPipelineByPropertyName=$True)]
	    [Alias("ComputerName","Server","__Server","PSComputer","IPAddress")]
	    [String[]] $Computer = "localhost"

    )
	Process
    {
        Foreach ($comp in $computer) #allows for input if its not piped into the function
        {
            Write-Progress "Getting OS info for: $comp"
            Write-Verbose "Getting OS info for: $comp"
            Write-Debug "OS information retrieved for: $comp"
            Get-WmiObject -Class Win32_OperatingSystem -ComputerName $comp | 
		    Select-Object @{label="ComputerName";Expression={$comp}},
                            @{label="OperatingSystem";Expression={$_.caption}}        

        }
    }
}


$computers = "vmhost5","dc4","kms"
Get-OS -Computer $computers -Verbose
Get-OS -Debug
$OtherObjs = Get-WmiObject Win32_computersystem -ComputerName $computers
$OtherObjs | Get-OS

