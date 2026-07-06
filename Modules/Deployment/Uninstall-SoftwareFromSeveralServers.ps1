# Purpose: Uninstall-SoftwareFromSeveralServers — Reusable PowerShell function libraries.
Function Uninstall-SoftwareFromSeveralServers {
# Get a list of computers
$computers = Get-Content "C:\Temp\Computers.txt"

# Although you can pass a list of computers to Get-WMIObject, to call the method, WMI need to be connected to the
# computer when calling it. So, we need to loop through each computer and connect
foreach ( $computer in $computers ) {
    # Now here, I would normally ping the computer prior to connecting, but we're doing a high-level example.
    # We connect to the computer with WMI and our Filter is being done in WMI, so it will only return a result if
    # a product name contains quicktime. You want to filter as soon as possible and only return what you need.
    $AdobeReader = Get-WMIObject -Class Win32_Product -Filter "Name Like '%Adobe Reader%'" -ComputerName $computer
    # Here, if you search a computer and Adobe Reader is not installed, $AdobeReader will be null.  So, we need to 
    # check if the object is null before we attempt to call the method
    if ($AdobeReader) {
        "Found {0} on {1}" -f $AdobeReader.Name, $computer
        # if you look at the documentation for Win32_Product, the UnInstall() method returns 0 for success and
        # any other code would be a failure (except may 3010 which is reboot required), so we check the return
        $result = $AdobeReader.Uninstall()
        if ($result -eq 0) {
            "Uninstall successful on {0}" -f $computer
        }
        else {
            "Uninstall failed on {0}" -f $computer
        }
    }
    else {
        "Adobe Reader is not found on {0}" -f $computer
    }
}
}