# Purpose: CreateDemoEnumUser — General-purpose PowerShell utilities.

#$num = Get-Random -Minimum 101 -Maximum 1000
$UserPath = (Get-ADDomain).userscontainer
$password = "P@ssword!" | ConvertTo-SecureString -Force -AsPlainText
$userName = "TestEnumDemo"
try{
    if (Get-ADUser $userName )
    {
        Get-aduser $UserName -Properties UserAccountControl | Set-ADUser -Replace @{UserAccountControl = 514} 
        Get-aduser $UserName -Properties UserAccountControl 
    
    }
}
catch
{
    New-ADUser -Name $userName -Path $UserPath -AccountPassword $password -PassThru | get-aduser -Properties UserAccountControl
}