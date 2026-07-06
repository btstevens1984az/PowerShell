# Purpose: hashtable5 — General-purpose PowerShell utilities.
# create a Here-String
$hereString = @'
   Msg1 = The string parameter is required.
   Msg2 = Credentials are required for this command.
   Msg3 = The specified variable does not exist.
'@


# ConvertFrom-StringData 
$hashtable = $hereString | ConvertFrom-StringData
$hashtable
