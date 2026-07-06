# Purpose: FirefoxVersionFromTextFile — Storage management and disk operations.
$devices = get-content "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\Chrome.txt"
foreach($device in $devices) {
    if(Test-Connection -ComputerName $device -count 1 -quiet){
        $firefox = "\\" + $device + "\C$\Program Files (x86)\Mozilla Firefox\firefox.exe"
        if(Test-Path $firefox) {
            $VersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($firefox)
            write-host $device  $VersionInfo.FileVersionRaw
        } else {
            write-host $device "has no firefox instance installed"
        }
    } else {
        write-host $device "offline"
    }
} 
