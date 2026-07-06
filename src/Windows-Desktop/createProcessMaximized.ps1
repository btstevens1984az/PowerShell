# Purpose: createProcessMaximized — Windows desktop configuration and management.
#This used to work with IE...
$WshShell = New-Object -ComObject "Wscript.Shell"
$WshShell.run("Iexplore.exe http://bing.com",3,$false) #https://msdn.microsoft.com/en-us/subscriptions/d5fk67ky(v=vs.84).aspx
#Createobject("wscript.Shell")

#this does not work with IE
$iepath = "iexplore.exe"
$Webpage = "http://www.Bing.com"
#$iepath = "notepad.exe"
#$webpage = "c:\temp\fixedemails.txt"
$props = @{
                windowstyle= "Maximized"
          }
$startInfo = New-Object -TypeName "System.Diagnostics.ProcessStartInfo" -ArgumentList $iepath,$webpage -Property $props

$process = [System.Diagnostics.Process]::start($startInfo)