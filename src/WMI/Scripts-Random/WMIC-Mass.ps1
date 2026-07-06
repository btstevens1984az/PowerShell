# Purpose: WMIC-Mass — PowerShell automation.
#   James Wylde

wmic product get name, version

product where version="171.154.12.33" call uninstall /y

product where name="8x8 Work"

wmic product where name="Cofense Reporter" call uninstall /y

wmic product where name="cape pack v2.15" call uninstall /y

wmic product where name="KASEMAKE 12.1" call uninstall /y

product get IdentifyingNumber, name, version | findstr /I /C:"Kase"
