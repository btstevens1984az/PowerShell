# Purpose: printinstallusingDelegation — General-purpose PowerShell utilities.
function install-driver {
       Param ( 
                     $ComputerName = ".",
                     $DrvName,
                     $DrvSupPlat = "Windows NT x86",
                     $DrvVer = 3,
                     $DrvInf, 
                     $DrvPath  
                     )
       
       Write-Host "$ComputerName`r`n $DrvName`r`n $DrvSupPlat`r`n $DrvVer`r`n $DrvInf`r`n $DrvPath"

       $driverclass                             = [wmiclass]"\\$ComputerName\ROOT\cimv2:Win32_PrinterDriver"
	   $driverobj                              = $driverclass.createinstance()
       	$driverclass.psbase.scope.options.Impersonation = "delegate"
		$driverclass.psbase.Scope.Options.Authority = "kerberos:kaylos.lab\$ComputerName"
	  
	   #The below doesn't work since CreateInstance is not defined directly on the Win32_printerdriver class.
	 #$driverobj = Invoke-WmiMethod -Path Win32_PrinterDriver -Name CreateInstance -EnableAllPrivileges -Authority "kerberos:kaylos.lab\$ComputerName" -ComputerName $ComputerName

	 
       $driverobj.name                          = $DrvName
       $driverobj.SupportedPlatform                    = $DrvSupPlat        # "Windows NT x86"
       $driverobj.Version                       = $DrvVer            # 3
       $driverobj.DriverPath                           = $DrvPath           # "\\23.244.105.230\PublicIT\drivers\printers\hp\lj2420"
       $driverobj.Infname                       = $DrvInf            # "\\23.244.105.230\PublicIT\drivers\printers\hp\lj2420\hpc24x0c.inf"
              
       $ret = $driverclass.AddPrinterDriver($driverobj)
       if ($ret.ReturnValue -eq 0){
              $ret = $driverclass.Put()
       }      Else {
              $o = $ret | fl | Out-String
              $ret = $driverclass.Put()
              Write-Host "`r`nUnable to load Driver$o" 
       }
}

cls

#$srv = "."
$srv = "prn1"
$d = "PCL6 Driver for Universal Print"
$e = "Windows x64"
$v = 3
$i= "\\190.113.222.206\share\z48483L6\64bit\oemsetup.inf"
#$i = "c:\drivers\z48483L6\64bit\oemsetup.inf"
$h = $i.Substring(0 ,$i.LastIndexOf("\"))

Install-driver -ComputerName $srv -DrvName $d -DrvInf $i -DrvPath $h -DrvSupPlat $e -DrvVer 3
