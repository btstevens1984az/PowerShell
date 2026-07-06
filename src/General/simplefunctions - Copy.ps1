# Purpose: simplefunctions - Copy — General-purpose PowerShell utilities.
﻿function GetOS
{
     param ($computer= "localhost")
     (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer).caption
}

Function Get-OS
{
	param ([parameter(Mandatory=$false,ValueFromPipeline=$True,Position = 0,HelpMessage="An array of computer names.")] 
	[String[]] $Computer = "localhost")
    Process
    {
        #Write-host "$($computer):"(Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer).caption
        Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer | 
		Select-Object @{label="ComputerName";Expression={$computer}},@{label="OperatingSystem";Expression={$_.caption}}        
    }
}

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
	param(
	[parameter(Mandatory=$false,ValueFromPipeline=$True,Position = 0,HelpMessage="An array of computer names.", 
	ValueFromPipelineByPropertyName=$True)]
	[Alias("ComputerName","Server","__Server","PSComputer")]
	[String[]] $Computer = "localhost")
	Process
    {
       Write-Verbose "Getting OS info for: $computer"
        Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer | 
		Select-Object @{label="ComputerName";Expression={$computer}},@{label="OperatingSystem";Expression={$_.caption}}        
		Write-Debug "OS information retrieved for: $computer"
    }
}
Function GetUpComputers
{
	Import-Module ActiveDirectory
	$comp = Get-ADcomputer -filter * | %{$_.name}
	$UpComp = $comp | %{ If (Test-Connection -count 2 -quiet -ComputerName $_) { $_}}
	$UpComp
}

#Use jobs to make the above function much faster
Function GetUpComputersJobs
{
	Import-Module ActiveDirectory
	$comp = Get-ADcomputer -filter * | %{$_.name}
	$Jobs = $comp | %{Start-Job -Name $_ -InputObject $_ -scriptblock {Test-Connection -count 2 -quiet -ComputerName $input}} | Wait-Job -Timeout 600
	$UpComp = $jobs | %{if ((Receive-Job -Job $_)){$_.name}}
	$jobs | Remove-Job -Force
	$UpComp
}
#Workflow is faster and doesn't have the memory overhead of creating a bunch of jobs.
workflow WFGetUpComputers {

   param([string[]]$computers)

   foreach –parallel ($computer in $computers){

    If (Test-Connection -ComputerName $computer -Count 1 -Quiet)
    {$computer}

   }

}
#$computers = (Get-ADComputer -Filter *).name
#$results = WFGetUpComputers -computers $computers
#$results

Function GetUpServers
#returns all servers queried from Active Directory that responded to a ping
#Uses Jobs
{
	Import-Module ActiveDirectory
	$comp = Get-ADComputer -Filter {Operatingsystem -like "*Server*"} | %{$_.name}
	$Jobs = $comp | %{Start-Job -Name $_ -InputObject $_ -scriptblock {Test-Connection -count 2 -quiet -ComputerName $input}} | Wait-Job -Timeout 600
	$UpComp = $jobs | %{if ((Receive-Job -Job $_)){$_.name}}
	$jobs | Remove-Job -Force
	$UpComp
}
copy Function:\prompt function:\prompt2
Function prompt
#changes prompt function to have the current time
{
	$date = Get-Date
	$day = ([string]($date.date)).split()[0]
	$time= (([string]($date.TimeofDay)).split("."))[0]
	$shortDate = $day +"::"+$time
	$(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 'PS ' +"$time "+$(Get-Location) + $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

Function GetDateStringForFiles
{
	$date = Get-Date
	$day = ([string]($date.date)).split()[0]
	$time= (([string]($date.TimeofDay)).split("."))[0]
	$shortDate = "$day$time"
	$shortDate = $shortDate -replace "/"
	$shortDate = $shortDate -replace ":"
	$shortDate
}

Function GetCPUTime
#Calculates CPUtime for a process
{
	#Does not account for multiple processes with the same name
	param([string]$processName,$computername="localhost")
	$processString = '\Process('+$processName+')\% Processor Time'
	Write-Debug $processString
	$procTime = ((Get-Counter -Counter $processString -ComputerName $computername).countersamples)[0].Cookedvalue
	$numProcessors = (Get-WmiObject -ComputerName $computername -Class Win32_Processor).NumberOfCores
	$processorTime = $procTime/$numProcessors
#	"{0:N2}" -f $processorTime
#	"{0:P2}" -f ($processorTime/100)
	$processorTime
}
#$processes = Get-Process | Add-Member scriptproperty CPUTIME {$(GetCPUTime -processname $this.name)} -passthru
#$processes = Get-Process -ComputerName $serverArray | Add-Member scriptproperty CPUTIME {$(GetCPUTime -processname $this.name -computername $this.machinename)} -passthru
#$processes = Get-Process | Add-Member -membertype scriptproperty -name CPUTIME -value {$(GetCPUTime -processname $this.name)} -passthru
