# Purpose: SimpleCMS — General-purpose PowerShell utilities.
#Use certificate with document encryption EKUd
Protect-CmsMessage -Content "secret" -To publickkey.cer >secret.txt

#if Private key is installed
Unprotect-CmsMessage -Path .\secret.txt

