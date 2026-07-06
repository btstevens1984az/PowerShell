# Purpose: Export-EDMRadiaFiles — HP Radia client automation and satellite servers.
Function Export-EDMRadiaFiles{
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
        [String[]]$ComputerName
     )
       Set-Location "C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent"
    $ComputerName = $cn

 Foreach ($cn in $ComputerName) {
    Start-Process -NoNewWindow "C:\Windows\system32\cmd.exe" | Invoke-Command ".\nvdkit.exe obj2csv "\\$cn\C:\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Lib\SAP.EDM" 'C:\Temp\EDMTest.csv'"
    }
}