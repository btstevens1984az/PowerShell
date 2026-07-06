# Purpose: ImportStartMenu — Network diagnostics, DNS, DHCP, and connectivity.
#ImportStartMenu.ps1
Copy-Item -Path $PSScriptRoot'\LayoutModification.xml' -Destination $env:SystemDrive'\Users\Default\AppData\Local\Microsoft\Windows\Shell'
Copy-Item -Path $PSScriptRoot'\Internet Explorer.lnk' -Destination $env:SystemDrive'\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories'




