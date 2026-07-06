<#
    Developed by Steven Holtman in Powershell
    Website: https://StevenHoltman.com
    Get the latest scripts at https://github.com/stevenholtman
.Synopsis
.DESCRIPTION
    This script will use the supplied information to generate the XML file required for netsh to add the network to the computer
#>

# Wireless lan service
$WlanService = Get-Service -Name "wlansvc"
    
# Update the Below Variables for the First Wireless Network
$SSID = "Wireless Network Name" # Replace with the Wireless Network Name/SSID you need to connect to
$PassPhrase = "Wireless Passphrase" # Replace with the Wireless Network's passphrase you need to connect to

# Additional Variables for the Wireless Configuration
$profilefile = $SSID + ".xml"
$SSIDHEX = ($SSID.ToCharArray() | foreach-object { '{0:X}' -f ([int]$_) }) -join ''

if ($WlanService.Status -eq 'Running') {
    # Creating the first Wireless Profile XML File
    $xmlfile = "<?xml version=""1.0""?>
    <WLANProfile xmlns=""http://www.microsoft.com/networking/WLAN/profile/v1"">
        <name>$SSID</name>
        <SSIDConfig>
            <SSID>
                <hex>$SSIDHEX</hex>
                <name>$SSID</name>
            </SSID>
        </SSIDConfig>
        <connectionType>ESS</connectionType>
        <connectionMode>auto</connectionMode>
        <MSM>
            <security>
                <authEncryption>
                    <authentication>WPA2PSK</authentication>
                    <encryption>AES</encryption>
                    <useOneX>false</useOneX>
                </authEncryption>
                <sharedKey>
                    <keyType>passPhrase</keyType>
                    <protected>false</protected>
                    <keyMaterial>$PassPhrase</keyMaterial>
                </sharedKey>
            </security>
        </MSM>
    </WLANProfile>
    "
    
    # Output XML File and Add the Wireless Profile
    $XMLFILE > ($profilefile)
    netsh wlan add profile filename="$($profilefile)"
    netsh wlan connect name=$SSID # This is if you want to connect to the wireless automaticly after adding it
    
    # Writting Success Result
    Write-Verbose "Sucessfully created $SSID"
}
else { 
    Write-Verbose "No Wireless Adapter Identified, Exiting"
}