# Purpose: checkNet36 — General-purpose PowerShell utilities.
filter Check-Online {
trap { continue }

. {
$obj = New-Object system.Net.NetworkInformation.Ping
$result = $obj.Send($_, 1000)
if ($result.status -eq 'Success') { $_ }
}
}

1..255 | % { "10.6.36.$_" } | Check-Online |
% { [system.Net.Dns]::Getaddress($_) }