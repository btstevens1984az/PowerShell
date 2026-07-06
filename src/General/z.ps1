# Purpose: z — General-purpose PowerShell utilities.
for /F %%x in ('type c:\powershell2\ipc.txt') do (dsquery computer -samid %%x$) |write-host