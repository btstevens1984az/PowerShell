# Purpose: Get-DHCPScopeLeases — Network diagnostics, DNS, DHCP, and connectivity.
# ——————————
# Retrieve Scopes from Server
# ——————————
$server = "140.15.56.135"
$lines = @()
$columns= @()
$rows = @()
$headers= @()

# Retrieve DHCP scopes on named server
$input = (netsh dhcp server $server show scope)

# Extract header row and rows containing scopes
foreach ($i in $input){

# Search for IP address
if ($i -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
$lines += $i
$b=0
$j=0

# Create associative array for scopes
$row = "" | select $headers

# Split row into columns and store in array
$columns | % {$row.($headers[$j]) = ($i.SubString($b,$_-$b)).Trim();$b=$_+1;$j++}
$rows+=$row
} 

if ($i -match "Scope Address"){
# Parse the header row and retrieve column positions
$eol = $i | measure-object –character | select -expandproperty characters
(Select-String -Pattern ([regex]’-‘) -InputObject $i -AllMatches).Matches | % {$columns += $_.Index}
$columns += $eol

# Next line is equivalent of $headers= "ScopeAddress","SubnetMask","State","ScopeName","Comment"
$columns | % {$headers+=(($i.SubString($b,$_-$b)).Trim()).Replace(" ","");$b=$_+1}
}
}

$scopes = $rows

# Output DHCP scopes
# $scopes | select * | ft
# ——————————
# Retrieve Leases for each Scope
# ——————————
# Parse all scopes. For each scope export DHCP leases
$scopes.GetEnumerator() | % {
$lines = @()
$columns = @()
$headers = @()
$rows = @()
$maxeol = 0
$eol = 0
$eoi = 0
$b = 0

# Extract leases from scopes
$input = (netsh dhcp server $server scope $_.ScopeAddress show clients 1)


# Extract header row and rows containing leases. Reformat lines into aligned columns
foreach ($i in $input){
$eoi = $i | measure-object –character | select -expandproperty characters; $maxeol = [math]::max($maxeol,$eoi)

# Search for IP address
if ($i -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){

# Search for MAC Address
if ($i -match "[0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}"){

# Reformat misaligned columns
$i = $i.Replace("-D- ", "-D -")
$i = $i.Replace("-U- ", " -U -")
$i = $i.Replace("-N- ", " -N -")
$i = $i.Replace("- INACTIVE", " -INACTIVE")
$i = $i.Replace("- NEVER EXPIRES", " -NEVER EXPIRES")
$lines += $i
}
} 
if ($i -match "IP Address"){

# This section should be the first line processed as it pertains to the Header row
# Reformat header to align columns: Replace "-Type -Name" with " – T – Name"
# IP Address – Subnet Mask – Unique ID – Lease Expires -Type -Name
# IP Address – Subnet Mask – Unique ID – Lease Expires -Typ- Name
$i = $i.Replace("-Type -Name", " -Typ- Name")
$eol = $i | measure-object –character | select -expandproperty characters
(Select-String -Pattern ([regex]’-‘) -InputObject $i -AllMatches).Matches | % {$columns += $_.Index}
$columns += $eol
$columns | % {$headers+=(($i.SubString($b,$_-$b)).Trim()).Replace(" ","");$b=$_+1}
}
}

# Set maximum length of row as maximum EOL (header row is shorter than data rows)
$columns[$columns.count-1] = $maxeol
foreach ($l in $lines){
$b=0
$j=0

# Create associative array for scopes
$row = "" | select $headers

# Increase length of line to length of longest dhcp-lease row within this scope using padding
$l=$l.PadRight($maxeol," ")

# Store dhcp leases into named values in hash table $row
$columns | % {$row.($headers[$j]) = ($l.SubString($b,$_-$b)).Trim();$b=$_+1;$j++}

# Add row to table
$rows+=$row
}
$leases += $rows
} # End – $scopes.GetEnumerator()
# Output all leases
$scopes | select * | export-csv -NoTypeInformation -Path c:\TempKK\dhcp-scopes-$server.csv
$leases | select * | export-csv -NoTypeInformation -Path c:\TempKK\dhcp-leases-$server.csv
# Destroy variables
$lines = $Null
$columns = $Null
$headers = $Null
$rows = $Null
$leases = $Null
$scopes = $Null