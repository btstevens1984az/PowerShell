# Purpose: CreateObjsForGetOS — General-purpose PowerShell utilities.
$hash = @{
computer="scvmm2012"
prop2= "somethingelse"
}
$hash2 = @{
computer="kms"
prop2= "somethingelse"
}
$hash3 = @{
computer="dc2"
prop2= "somethingelse"
}
$obj1 = @()
$obj1 += New-Object PSobject  -property $hash
$obj1 += New-Object PSobject -property $hash2
$obj1 += New-Object PSobject -property $hash3