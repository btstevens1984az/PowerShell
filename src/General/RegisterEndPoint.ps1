# Purpose: RegisterEndPoint — General-purpose PowerShell utilities.
#can use jeatoolkit to generate SDDL
#https://gallery.technet.microsoft.com/JEA-Helper-Tool-20-6f9c49dd
Register-PSSessionConfiguration -Name Web_Admin -Path C:\JeaConfig\Web_Administration.pssc -SecurityDescriptorSddl "O:NSG:BAD:P(A;;GA;;;S-1-5-21-346706760-136867072-3382628191-91839)(A;;GA;;;S-1-5-21-346706760-136867072-3382628191-91840)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"