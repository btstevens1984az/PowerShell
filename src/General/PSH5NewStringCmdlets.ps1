# Purpose: PSH5NewStringCmdlets — General-purpose PowerShell utilities.
###############################################################################
# http://blogs.msdn.com/b/powershell/archive/2014/10/31/convertfrom-string-example-based-text-parsing.aspx
# ConvertFrom-String
# Convert-String

ipconfig

ipconfig | Convert-String -Example "IPv4 Address. . . . . . . . . . . : 201.32.5.53 =201.32.5.53"

$text = @'
Ana Trujillo
Redmond, WA

Antonio Moreno
Renton, WA

Thomas Hardy
Seattle, WA

Christina Berglund
Redmond, WA

Hanna Moos
Puyallup, WA
'@
Set-Content -Path .\ToBeParsed.txt -Value $text

$text = @'
{Name*:Ana Trujillo}
{City:Redmond}, {State:WA}

{Name*:Antonio Moreno}
{City:Renton}, {State:WA}
'@
Set-Content -Path .\Template.txt -Value $text
Get-Content .\ToBeParsed.txt | ConvertFrom-String -TemplateFile .\Template.txt 

#Use the UpdateTemplate parameter to improve performace in future processing. The learning algorithim is saved for future use.
measure-command {Get-Content .\ToBeParsed.txt | ConvertFrom-String -TemplateFile .\Template.txt -UpdateTemplate }
measure-command {Get-Content .\ToBeParsed.txt | ConvertFrom-String -TemplateFile .\Template.txt  }
psedit .\Template.txt

#Netstat - template could be improved
netstat -ano |Select-Object -first 30
psedit .\netstatTemplate.txt 
netstat -ano | select -skip 4 -First 30 |  ConvertFrom-String -TemplateFile .\netstatTemplate.txt  | Out-GridView
netstat -ano | select -skip 4 -First 30 |  ConvertFrom-String -TemplateFile .\netstatTemplate.txt  |
Add-Member -MemberType ScriptProperty -Name ProcessName -Value {(Get-process -Id $this.pid).ProcessName} -PassThru |
Out-GridView



#for newer operating systems and just TCP you can also use Get-NetTCPConnection

