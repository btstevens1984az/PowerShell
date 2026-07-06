# Purpose: Install-SoftwareRemotely — PowerShell automation.
function installSoftware { 
{
foreach ($computer in $strComputers) {
write-output "######################################################"
write-output " "
write-output "Will now Install Software on $computer"
write-output " "
write-output "######################################################"
  executeRemoteInstall $computer
}
}

  function executeRemoteInstall {
  param ($computerName)
   $product = [WMICLASS]"\\$computerName\ROOT\CIMV2:win32_product"
  #You must add the *.msi to the directory below and uncomment the execution line 43.
  #$product.install("c:\TEMP\IE8.msi")
  }
}