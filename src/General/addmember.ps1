# Purpose: addmember — General-purpose PowerShell utilities.
$filename = $Args[0]
$TheFile = Get-Content $filename
#create empty array
$Array = @()
foreach ($Line in $TheFile)
{
        #Get WMI Information + Discard information we don't want
                $mydata = Get-WMIObject win32_OperatingSystem -computername $Line | select CSName, caption, CSDVersion
                $bios = Get-WmiObject Win32_BIOS -ComputerName $Line
                                
                #Combine 2 objects into 1 custom object
                Add-Member -InputObject $mydata noteproperty BiosManufacturer $bios.manufacturer
                Add-Member -InputObject $mydata noteproperty BiosVersion $bios.SMBIOSBIOSVersion
                                
                #Dump the object in array
                $array = $array + $mydata
}
#Export array into csv
$array | Export-Csv output.csv -NoTypeInformation

#Open csv file in default application
invoke-item output.csv

