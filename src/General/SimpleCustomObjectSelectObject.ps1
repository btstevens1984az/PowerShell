# Purpose: SimpleCustomObjectSelectObject — General-purpose PowerShell utilities.
Function get-MyOSinfo
{param($computername)
$hash =  @{label="Operating System";Expression={$_.caption}}
$hash2 = @{name="Service Pack";Expression={$_.CSDVersion}} 
$hash3 = @{l="Computer Name";E={$_.__server}}        
$OsInfo= Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computername |
 Select-Object $hash3,$hash,OSArchitecture,$hash2 
 $OsInfo
 }

 get-MyOSinfo kms