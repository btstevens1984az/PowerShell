# Purpose: MISC-WindowsClean — General-purpose PowerShell utilities.
Get-AppxPackage *3dbuilder* | Remove-AppxPackage #3D Builder
Get-AppxPackage *windowsalarms* | Remove-AppxPackage #Alarms and Clock: 
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage #Calendar and Mail: 
Get-AppxPackage *windowscamera* | Remove-AppxPackage #Camera: 
Get-AppxPackage *officehub* | Remove-AppxPackage #Get Office: 
Get-AppxPackage *skypeapp* | Remove-AppxPackage #Get Skype: 
Get-AppxPackage *getstarted* | Remove-AppxPackage #Get Started:
Get-AppxPackage *zunemusic* | Remove-AppxPackage #Groove Music
Get-AppxPackage *windowsmaps* | Remove-AppxPackage #Maps: 
Get-AppxPackage *solitairecollection* | Remove-AppxPackage #Microsoft Solitaire Collection: 
Get-AppxPackage *bingfinance* | Remove-AppxPackage #Money: 
Get-AppxPackage *zunevideo* | Remove-AppxPackage #Movies & TV: 
Get-AppxPackage *bingnews* | Remove-AppxPackage #News: 
Get-AppxPackage *onenote* | Remove-AppxPackage #OneNote: 
Get-AppxPackage *people* | Remove-AppxPackage #People: 
Get-AppxPackage *windowsphone* | Remove-AppxPackage #Phone Companion: 
Get-AppxPackage *photos* | Remove-AppxPackage #Photos: 
Get-AppxPackage *windowsstore* | Remove-AppxPackage #Store: 
Get-AppxPackage *bingsports* | Remove-AppxPackage #Sports: 
Get-AppxPackage *soundrecorder* | Remove-AppxPackage #Voice Recorder: 
Get-AppxPackage *bingweather* | Remove-AppxPackage #Weather: 
Get-AppxPackage *xboxapp* | Remove-AppxPackage #Xbox: 

sfc /scannow