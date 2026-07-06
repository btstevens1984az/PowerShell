# Purpose: SimpleNoNewLine — General-purpose PowerShell utilities.
"This is" | Out-File .\Test.txt -NoNewline
" a test." | Add-Content .\Test.txt -NoNewline
Get-Content .\Test.txt