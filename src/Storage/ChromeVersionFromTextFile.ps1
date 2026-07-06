# Purpose: ChromeVersionFromTextFile — Storage management and disk operations.
$devices = get-content "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\Chrome.txt"
foreach($device in $devices) {
    if(Test-Connection -ComputerName $device -count 1 -quiet){
        $Chrome = "\\" + $device + "\C$\Program Files (x86)\Google\Chrome\Application\Chrome.exe"
        if(Test-Path $Chrome) {
            $VersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Chrome)
            write-host $device  $VersionInfo.FileVersionRaw
        } else {
            write-host $device "has no Chrome instance installed"
        }
    } else {
        write-host $device "offline"
    }
} 