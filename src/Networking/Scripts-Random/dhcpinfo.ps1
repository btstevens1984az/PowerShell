# Purpose: dhcpinfo — Network diagnostics, DNS, DHCP, and connectivity.
# Testing dhcp export

$a = (netsh dhcp server 140.15.56.135 show scope)

$lines = @()
#start by looking for lines where there is IP present
foreach ($i in $a){
    if ($i -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
            $lines += $i.Trim()
    }
}

$csvfile = @()
$lines2 = @()
foreach ($l in $lines){
    $Row = "" | select Subnet,SubNetMask,ScopeStart,ScopeEnd,Location
    $l = $l + "`n"
    $l = $l -replace '-Active',''
    $l = $l -replace '-',','
    $l = $l -replace '\s',''
    $Row.Subnet = ($l.Split(","))[0]
    $c = $Row.Subnet
    $Row.SubNetMask = ($l.Split(","))[1]
    $Row.Location = ($l.Split(","))[2]
    $b = (netsh dhcp server 50.49.250.103 scope $c show iprange)
    foreach ($i2 in $b){
        if ($i2 -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" -and $i2 -notmatch 'Changed the current scope context to' `
            -and $i2 -notmatch 'No of IP Ranges : 1 in the Scope'){
            $lines2 += $i2.Trim()
        }
    }
    Foreach ($l2 in $lines2){
        $l2 = $l2 -replace '-',','
        $l2 = $l2 -replace '\s',''
        $Row.ScopeStart = ($l2.Split(","))[0]
        $Row.ScopeEnd = ($l2.Split(","))[1]
    }
    $csvfile += $Row
}    
$csvfile | sort-object Subnet | Export-Csv "C:\TempKK\DHCPExport.csv"