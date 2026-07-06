# Purpose: sccmclient — Configuration Manager collections and deployments.
# install configmgr client

# kerry kreitinger - 2-2-2010  not yet tested

$computers = import-csv c:\powershell2\CCMClient\reinstall.csv

# $MSI = "\\255.165.251.74\client$\ccmsetup.exe"

$MSI = \\255.165.251.74\SMS_ADC\Client\ccmsetup.exe"

$Params = "SMSSITECODE=ADC"


Foreach ($Computer in $Computers) {
([wmiclass]"\\$Computer\root\cimv2:Win32_Product").Install($MSI,$Params,$true)
}
