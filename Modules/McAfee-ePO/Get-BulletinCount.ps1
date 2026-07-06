# Purpose: Get-BulletinCount — McAfee ePolicy Orchestrator reporting.
Function Get-BulletinCount {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ServerName="$env:COMPUTERNAME"
    )

$Bulletin = (Get-ChildItem -Directory "\\$ServerName\e$\PSL\RCA\ProxyServer\etc\rps\RADSTAGE\RADSTAGE\RADSTAGE\ZSERVICE" -Force)
$BulletinName = Get-ChildItem -Directory "\\$ServerName\e$\PSL\RCA\ProxyServer\etc\rps\RADSTAGE\RADSTAGE\RADSTAGE\ZSERVICE" -Force | Format-Table -AutoSize -HideTableHeaders -Property Name
$BulletinCount = ($Bulletin).Count
#$BulletinLastWriteTime =($Bulletin).LastWriteTime}
#$BulletinLastAccessTime = % {($Bulletin).LastAccessTime}
$MostRecentBulletinName = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -First 1 -ExpandProperty Name)
$MostRecentBulletinCreationTime = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -Last 1 -ExpandProperty CreationTime)
$MostRecentBulletinLastWriteDate = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -Last 1 -ExpandProperty LastWriteTime)
$OldestBulletinName = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -Last 1 -ExpandProperty Name)
$OldestBulletinCreationTime = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -Last 1 -ExpandProperty CreationTime)
$OldestBulletinLastWriteTime = ($Bulletin | Sort-Object -Descending -Property LastWriteTime | Select-Object -Property Name,CreationTime,LastWriteTime -Last 1 -ExpandProperty LastWriteTime)

Write-Host $ServerName
Write-Host $BulletinName.ToString()
            
<#@("
Server Name                        $ServerName

Bulletin Count                     $BulletinCount
                                                                          
Most Recent Bulletin Name          $MostRecentBulletinName
Most Recent Bulletin Created       $MostRecentBulletinCreationTime
Most Recent Bulletin Modified      $OldestBulletinLastWriteTime
                                                                      
Oldest Bulletin Name               $OldestBulletinName
Oldest Bulletin Created            $OldestBulletinCreationTime
Oldest Bulletin Modified           $OldestBulletinLastWriteTime
$BulletinName
")#>
}