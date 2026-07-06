# Purpose: klist — General-purpose PowerShell utilities.
Measure-Command {klist | ConvertFrom-String -TemplateFile .\KlistTemplate.txt -UpdateTemplate}
Measure-Command {klist | ConvertFrom-String -TemplateFile .\KlistTemplate.txt}

klist | ConvertFrom-String -TemplateFile .\KlistTemplate.txt |
 where endtime -gt (get-date)