# Purpose: ConvertFromSecureToString — General-purpose PowerShell utilities.
Function ConvertSecureTo-String
{
    param(
    [parameter(Mandatory)]
    [System.Security.SecureString]$secureStringValue
    )
    [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureStringValue));

}