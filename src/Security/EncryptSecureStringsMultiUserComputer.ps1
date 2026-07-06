# Purpose: EncryptSecureStringsMultiUserComputer — Security auditing and compliance checks.
$encryptPassword = Read-Host "Type Encryption Key" -AsSecureString
[byte[]]$salt = 10,20,30,40,50,60,70,80,90,100
#add-type -AssemblyName System.Security.Cryptography
$encryptKey = New-Object -TypeName "System.Security.Cryptography.Rfc2898DeriveBytes" -ArgumentList $encryptPassword,$salt,10
$test = Read-Host "Enter Password to encrypt" -AsSecureString
$encryptedString = $test | ConvertFrom-SecureString -key $encryptKey.GetBytes(32)
$encryptedString | Out-File c:\temp\encyptpassword.txt

function ConvertFrom-SecureStringtoString
{
    param(
    [parameter(Mandatory=$true, 
               ValueFromPipeline=$true)]
    [System.Security.SecureString]$secureString)
    process
    {
    $BSTR =[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    $PlainString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 
    $PlainString
    }
}