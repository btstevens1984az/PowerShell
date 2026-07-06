# Purpose: Get-IPAddress — Reusable PowerShell function libraries.
Function Get-IPAddress {
Get-Content "C:\Users\$env:USERNAME\Desktop\05162018.txt" | ForEach {

    $details = Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue

    if ($details) {

        $props = @{
            ComputerName = $_
            IP = $details.IPV4Address.IPAddressToString
        }

        New-Object PsObject -Property $props
    }

    Else {    
        $props = @{
            ComputerName = $_
            IP = 'Unreachable'
        }

        New-Object PsObject -Property $props
    }

} | Sort ComputerName | Export-Csv  "C:\Users\$env:USERNAME\Desktop\05162018.csv" -NoTypeInformation -Append
}