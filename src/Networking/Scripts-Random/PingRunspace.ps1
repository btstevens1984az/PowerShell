# Purpose: PingRunspace — Network diagnostics, DNS, DHCP, and connectivity.
Function Get-UpComputersRunPool
{
    param
    (
        [int]$throttleLimit = 200,
        $computers = (Get-ADcomputer -filter * | %{$_.name})
    )
    $iss = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    $Pool = [runspacefactory]::CreateRunspacePool(1, $throttleLimit, $iss, $Host)
    $pool.ApartmentState = "STA"
    $Pool.Open()

    $scriptBlock = {
        param ($computer)
        if (Test-Connection -Count 2 -Quiet -ComputerName $computer)
            {
                $computer
            }
        }
    $threads = @()
    $handles = foreach ($computer in $computers)
    {
    	$powershell = [powershell]::Create().AddScript($ScriptBlock).AddArgument($computer)
	    $powershell.RunspacePool = $Pool
	    $powershell.BeginInvoke()
        $threads += $powershell

    }
    do { 
          $i = 0
          $done = $true
          foreach ($handle in $handles) {
            if ($handle -ne $null) {
  	          if ($handle.IsCompleted) {
                #the following will return the computer names of online computers for each runspace
                $threads[$i].EndInvoke($handle)
                $threads[$i].Dispose()
                $handles[$i] = $null
              } else {
                $done = $false
              }
            }
            $i++ 
          }
          if (-not $done) { Start-Sleep -Milliseconds 1000 }
        } until ($done) 
        $pool.Dispose()
}
	#Import-Module ActiveDirectory
	#$comps = Get-ADcomputer -filter * | %{$_.name}
#$start = get-date
#$computers = Get-UpComputersRunPool # -computers $comps -throttleLimit 500
#$finish =Get-Date
#$computers
#$timespan = $finish - $start
#$timespan