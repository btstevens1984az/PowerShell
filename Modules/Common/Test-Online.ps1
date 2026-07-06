# Purpose: Test-Online — Reusable PowerShell function libraries.
function Test-Online {
	<#
	.SYNOPSIS
	Test for connection status for one or more computers
	.DESCRIPTION
	Tests one or more computers for network connection. Two NoteProperties are added to the object(s) on their way through the pipeline:
		* OnlineStatus - will be $true if the computer is online, $false otherwise
		* IPV4Address - the IP address of the computer, if any
	Note this Cmdlet uses parallel processing techniques to test many computers at once, so results are returned very quickly, even for a large number of input objects.
	.PARAMETER Property
	The name of a property of InputObject that contains the name of the computer; required if InputObject is anything other than a string.
	.PARAMETER InputObject
	One or more objects to test for network connection
	.EXAMPLE
	'Computer1','Computer2' | Test-Online -Property Name | ? OnlineStatus -eq $true

	Tests 2 computers (named Computer1 and Computer2) and sends the names of those that are on the network down the pipeline.
	.INPUTS
	PSObject or string.
	.OUTPUTS
	Same as input, with two additional properties appended
	#Requires -Version 2.0
	#>
	[CmdletBinding(DefaultParameterSetName = 'ByString')]
	Param (
		[Parameter(Mandatory,ValueFromPipeline)] $InputObject,
		[Parameter(ParameterSetName='NotString',Mandatory,Position=0)]
			[ValidateNotNullOrEmpty()] [string] $Property
	)
	BEGIN {
		$Jobs = @{}
		$MaxJobs = 50
		$ProcessJobs = {
			Start-Sleep -Milliseconds 200
			$Keys = ($Jobs.Keys).Clone()
			foreach ($j in $Keys) {
				if ($Jobs[$j].State -eq 'Completed') {
					$Status = $false; $IPV4Address = '0.0.0.0'
					$Jobs[$j] | Receive-Job | ? StatusCode -eq 0 | Select-Object -First 1 | % {
						$x = $_
						$Status = $true
						$IPV4Address = try { $_.IPV4Address.PSObject.Properties | ? Name -eq 'IPAddressToString' | Select-Object -ExpandProperty Value } catch { $x.Address }
					}
					$Jobs[$j].InputObject | Add-Member -Force -PassThru -NotePropertyMembers @{
						OnlineStatus = $Status
						IPV4Address = $IPV4Address
					}
					try { Remove-Job $Jobs[$j]; $Jobs.Remove($j) } catch {}
				}
			}
		}
	}
	PROCESS {
		while ($Jobs.Count -gt $MaxJobs) { . $ProcessJobs }
		$CompName = switch ($PSCmdlet.ParameterSetName) {
			'ByString' { $InputObject.ToString() }
			'NotString' { $InputObject | Select-Object -Property $Property | % { $_.$Property } }
		}
		if ($CompName) {
			$Job = Test-Connection -Count 3 -ComputerName $CompName -AsJob -EA SilentlyContinue | Add-Member -NotePropertyName InputObject -NotePropertyValue $InputObject -PassThru
			try {
				$Jobs.Add($CompName, $Job)
			} catch {
				Stop-Job $Job
				Remove-Job $Job
			}
		} else {
			$InputObject | Add-Member -Force -PassThru -NotePropertyMembers @{
				OnlineStatus = $false
				IPV4Address = '0.0.0.0'
			}
		}
	}
	END { while ($Jobs.Count -gt 0) { . $ProcessJobs } }
}
