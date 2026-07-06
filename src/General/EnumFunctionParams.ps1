# Purpose: EnumFunctionParams — General-purpose PowerShell utilities.
enum OSVersions
{
    Windows7
    Windows8
    Windows81
    Windows10
    WindowsServer2008R2
    WindowsServer2012
    WindowsServer2012R2
    WindowsServer2016
}

Function Test-Enum
{
    param([OSVersions]$OS)
    "OS is $os"


}