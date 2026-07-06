# Purpose: Get-RadiaServices — HP Radia client automation and satellite servers.
function Get-RadiaServices
{
	param
	(
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[String[]]$Computername
	)
	{
		$Computers = Get-Content C:\Users\$env:USERNAME\Desktop\Radia\HostsNotInPatchReport.txt
		$GetRadiaServices = Get-Service -ServiceName Radstgms, Radexecd, Radsched, RpcSs, wuauserv -ComputerName $Computername -ErrorAction SilentlyContinue
		Foreach ($Computername in $Computers)
		{
			#Ping Test. If PC is shut off, script will stop for the current PC in pipeline and move to the next one.
			if (Test-Connection -ComputerName $Computername -Count 1 -Quiet)
			{
				Write-Host "$Computername $GetRadiaServices | Select-Object -Property DisplayName, ServiceName, StartType, Status | Sort-Object -Property ServiceName | Format-Table -AutoSize" -ForegroundColor Cyan
			}
			else
			{
				Write-Host "$Computername is not Online" -ForegroundColor Red
			}
		}
	}
} #get-service -ServiceName Radstgms,Radexecd,Radsched,RpcSs,wuauserv -ComputerName $cn -ErrorAction SilentlyContinue | Select-Object -Property DisplayName, ServiceName, StartType, Status | Sort-Object -Property ServiceName | Format-Table -AutoSize