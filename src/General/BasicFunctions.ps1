# Purpose: BasicFunctions — General-purpose PowerShell utilities.
Function GetOS
{
    (Get-WmiObject -Class Win32_OperatingSystem).caption
}
#Positional Parameter using $args
Function GetOS2
{
    (Get-WmiObject -Class Win32_OperatingSystem -computer $args[0]).caption

}
#NamedParameter
Function GetOS3
{
param($computername)
    (Get-WmiObject -Class Win32_OperatingSystem -computer $computername).caption

}

Function GetOS3
{
param($computername="localhost")
    (Get-WmiObject -Class Win32_OperatingSystem -computer $computername).caption
 }

Function GetOS4
{
param([string]$computername="localhost")
    (Get-WmiObject -Class Win32_OperatingSystem -computer $computername).caption

}

#Type Constrain parameter
Function GetOS5
{
param([string]$computername="localhost")
    #(Get-WmiObject -Class Win32_OperatingSystem -computer $computername).caption
    $computername.gettype()
    $computername
}
function typeTest
{
    param([int]$num)
    $num
}

#Accept Arrays
Function GetOS6
{
param([string[]]$computername="localhost")
    (Get-WmiObject -Class Win32_OperatingSystem -computer $computername).caption
    #$computername.gettype()
}

$computers = "Vmhost4","vmhost5","win7test","win28r2file"

#Return Objects
Function GetOS7
{
param([string[]]$computername="localhost")
    $propComputerName = @{
                            label="ComputerName"
                            expression = {$_.__server}
                        }
     $propOS=           @{
                            label="OperatingSystem"
                            expression = {$_.caption}
                        }
    Get-WmiObject -Class Win32_OperatingSystem -computer $computername | 
    Select-Object $propComputerName,$propOS,ServicePackMajorVersion,OSArchitecture
 
}

#Make it pipeable
function Get-os8
{
    begin{}
    process{
        $propComputerName = @{
                                label="ComputerName"
                                expression = {$_.__server}
                            }
         $propOS=           @{
                                label="OperatingSystem"
                                expression = {$_.caption}
                            }
        Get-WmiObject -Class Win32_OperatingSystem -computer $_ | 
        Select-Object $propComputerName,$propOS,ServicePackMajorVersion,OSArchitecture
    }
    end{}
 
}
$computers | Get-os8 #this now works!
get-os8 $computers #but this does not...

