# Purpose: Open-HPCALogFile — HP Radia client automation and satellite servers.
Function Open-HPCALogFile {
    param
        (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$ComputerName
        )

if(Test-Connection $ComputerName -count 1 -Quiet){

$files = Get-ChildItem -Path "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log" -File -ErrorAction SilentlyContinue
$fileChoices = @()

for ($i=0; $i -lt $files.Count; $i++) {
  $fileChoices += [System.Management.Automation.Host.ChoiceDescription]("$($files[$i].Name) &$($i+1)")
}

$userChoice = $host.UI.PromptForChoice('Select File', 'Choose a file', $fileChoices, 0) + 1

Write-Host "Please select a log to open $($files[$userChoice].FullName)" | Invoke-Item $files[$userChoice].FullName
}
    else
    {
      write-host "$ComputerName is offline"
    }
}