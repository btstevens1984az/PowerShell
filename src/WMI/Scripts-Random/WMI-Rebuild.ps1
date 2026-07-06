# Purpose: WMI-Rebuild — PowerShell automation.
net stop ccmexec /y
net stop VMAuthdService /y
net stop winmgmt /y
c:
cd %systemroot%\system32\wbem
rd /S /Q repository
regsvr32 /s %systemroot%\system32\scecli.dll
regsvr32 /s %systemroot%\system32\userenv.dll
mofcomp cimwin32.mof
mofcomp cimwin32.mfl
mofcomp rsop.mof
mofcomp rsop.mfl
for /f %%s in (‘dir /b /s *.dll’) do regsvr32 /s %%s
for /f %%s in (‘dir /b *.mof’) do mofcomp %%s
for /f %%s in (‘dir /b *.mfl’) do mofcomp %%s
winmgmt /resetrepository
net start winmgmt
net start VMAuthdService
net start ccmexec