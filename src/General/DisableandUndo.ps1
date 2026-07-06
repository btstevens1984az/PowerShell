# Purpose: DisableandUndo — General-purpose PowerShell utilities.
$exportXMLPath= "c:\temp\computersChanged.xml"
$oneyearAgo = (get-date).AddYears(-100)
$computers = Get-ADComputer -Filter {lastlogondate -lt $oneyearAgo}
$computers | Export-Clixml $exportXMLPath
$staleOU = "OU=StaleComputers,DC=kaylos,DC=lab"
$computers  | Disable-ADAccount -PassThru | Move-ADObject -TargetPath $staleOU -PassThru #| Export-Clixml c:\temp\changedcomputersafter.xml


#undo
$undoComputers = Import-Clixml $exportXMLPath
$undoComputers | %{Get-ADComputer -Identity $_.objectguid |
                     Enable-ADAccount -PassThru | 
                     Move-ADObject -TargetPath (Get-ParentPath -Distingquishednamed $_.distinguishedName) -PassThru
                  }
            



Function Get-ParentPath
{
param ([string]$Distingquishednamed)
    $DNSplit = $Distingquishednamed -split ","
    $ParentParts = $DNSplit | Select-Object -Skip 1
    $parentPath = $ParentParts -join ","
    $parentPath

}
