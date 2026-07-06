# Purpose: MISC-WindowsCredsClear — Core infrastructure automation scripts.
#   James Wylde

for /F "tokens=1,2 delims=" %G in ('cmdkey /list ^| findstr Target') do cmdkey /delete %H

for /F "tokens=1,* delims=" %G in ('cmdkey /list ^| findstr Target') do cmdkey /delete %H

for /F "tokens=1,2 delims=" %G in ('cmdkey /list ^| findstr Onedrive*') do cmdkey /delete %H


for /F 'tokens=1,2 delims=' %%G in ('cmdkey /list ^| findstr Onedrive') do cmdkey /delete %%H