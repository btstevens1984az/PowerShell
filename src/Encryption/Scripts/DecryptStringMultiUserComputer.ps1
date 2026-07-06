# Purpose: DecryptStringMultiUserComputer — PowerShell automation.
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

$encryptPassword = Read-Host "encryptKey" -AsSecureString
[byte[]]$salt = 10,20,30,40,50,60,70,80,90,100
#add-type -AssemblyName System.Security.Cryptography
$encryptKey = New-Object -TypeName "System.Security.Cryptography.Rfc2898DeriveBytes" -ArgumentList $encryptPassword,$salt,10
$secureString = Get-Content C:\temp\encyptpassword.txt | ConvertTo-SecureString -Key $encryptKey.GetBytes(32)
$secureString | ConvertFrom-SecureStringtoString

#Create Credential using decrypted secure string
#New-Object -TypeName PSCredential -ArgumentList "Contoso\username",$secureString
