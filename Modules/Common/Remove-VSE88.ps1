# Purpose: Remove-VSE88 — Reusable PowerShell function libraries.
Function Remove-VSE88 {
    (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String[]]$ComputerName
    )
$script = { 
  invoke-expression "msiexec /qn /x '{072890D5-A7B6-4993-970F-0121FFF5B6CA}' "
  while($true)
  {
    if(Get-Process msiexec -ea 0)
    {
      sleep 1
    }
    else
    {
      return
    }
  }
}
Invoke-Command -computername 154.224.22.73 -scriptblock $script -ErrorAction SilentlyContinue
}