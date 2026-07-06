# Purpose: hashtable4 — General-purpose PowerShell utilities.
$capitals = @{}  # create an empty hashtable

$capitals.BZ=$BZstates
$capitals.OZ=$OZstates
$capitals.DE=$DEstates

$capitals.OZ
$capitals.OZ.SA
$capitals.OZ["NSW"]
$capitals.DE.'Lower Saxony'
$capitals.BZ.Tocantins
