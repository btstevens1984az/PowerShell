# Purpose: getem — General-purpose PowerShell utilities.
$datetime = Get-Date -Format "yyyyMMddhhmmss";
$strCategory = "computer";

# Create a Domain object. With no params will tie to computer domain
$objDomain = New-Object System.DirectoryServices.DirectoryEntry;

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher; # AD Searcher object
$objSearcher.SearchRoot = $objDomain; # Set Search root to our domain
$objSearcher.Filter = ("(objectCategory=$strCategory)"); # Search filter

$colProplist = "name";
foreach ($i in $colPropList)
{
$objSearcher.PropertiesToLoad.Add($i);
}

$colResults = $objSearcher.FindAll();


# Add column headers
Add-Content "$Env:USERPROFILE\softwareaudit $datetime.csv" "Computer,Caption,Description,Identifying Number,Installation Date,Installation Date 2,Installation Location,Installation State,Name,Package Cache,SKU Number,Vendor,Version";

foreach ($objResult in $colResults)
{
$objComputer = $objResult.Properties;
$computer = $objComputer.name;

$ipAddress = $pingStatus.ProtocolAddress;
# Ping the computer
$pingStatus = Get-WmiObject -Class Win32_PingStatus -Filter "Address = '$computer'";

if($pingStatus.StatusCode -eq 0)
{
Write-Host -ForegroundColor Green "Ping Reply received from $computer.";

write-host "Connecting to $computer..."

$colItems = get-wmiobject -class "Win32_Product" -namespace "root\CIMV2" `
-computername $computer

write-host "#############################"
write-host "Computer: " $computer
write-host "#############################"
write-host
write-host

foreach ($objItem in $colItems)
{
write-host "Caption: " $objItem.Caption
$caption = $objItem.Caption
write-host "Description: " $objItem.Description
$description = $objItem.Description
write-host "Identifying Number: " $objItem.IdentifyingNumber
$identifier = $objItem.IdentifyingNumber
write-host "Installation Date: " $objItem.InstallDate
$installdate = $objItem.InstallDate
write-host "Installation Date 2: " $objItem.InstallDate2
$installdate2 = $objItem.InstallDate2
write-host "Installation Location: " $objItem.InstallLocation
$installlocation = $objItem.InstallLocation
write-host "Installation State: " $objItem.InstallState
$installstate = $objItem.InstallState
write-host "Name: " $objItem.Name
$name = $objItem.Name
write-host "Package Cache: " $objItem.PackageCache
$packagecache = $objItem.PackageCache
write-host "SKU Number: " $objItem.SKUNumber
$skunumber = $objItem.SKUNumber
write-host "Vendor: " $objItem.Vendor
$vendor = $objItem.Vendor
write-host "Version: " $objItem.Version
$version = $objItem.Version
write-host

# Need to add in a special character for " as some of the values from the WMI query has commers in them that mess up the csv file
$sc = [char]34

Add-Content "$Env:USERPROFILE\softwareaudit $datetime.csv" "$sc$computer$sc,$sc$caption$sc,$sc$description$sc,$sc$identifier$sc,$sc$installdate$sc,$sc$installdate2$sc,$sc$installlocation$sc,$sc$installstate$sc,$sc$name$sc,$sc$packagecache$sc,$sc$skunumber$sc,$sc$vendor$sc,$sc$version$sc"
}
}
else
{
Write-Host -ForegroundColor Red "No Ping Reply received from $computer.";
}

}

