# Purpose: Remove move to onedrive context menu — Microsoft 365 tenant administration.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}
Clear-Host

Write-Output "Remove OneDrive from context menu, please confirm before going ahead."
""
pause
""
""
Invoke-Command {reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{CB3D0F55-BC2C-4C1A-85ED-23ED75B5106B}" /t reg_sz /f}
""
Write-Output "Refreshed screen to apply."
Stop-Process -name explorer -Force
Write-Output "Done."
""
pause