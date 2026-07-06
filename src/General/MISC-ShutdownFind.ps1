# Purpose: MISC-ShutdownFind — General-purpose PowerShell utilities.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules

cls

$compName = Read-Host "Client Name"

cls

TRY{


    Write-Host "Who killed" $compName"?" -ForegroundColor White -BackgroundColor Red

    $properties = @(
        @{n='When?';e={$_.timeCreated}},
        @{n='Who?';e={$_.properties[6].Value.ToUpper()}},
        @{n='How?';e={$_.properties[4].Value.ToUpper()}},
        @{n='What?';e={$_.properties[0].Value}}
    )

    Get-WinEvent -ComputerName $compName -FilterHashTable @{LogName='System'; ID=1074} | 
    Select-Object $properties | Sort-Object "$_.timeCreated" -Descending | Format-Table -AutoSize # | Out-GridView
    Start-Sleep -Seconds 1.5

    $timeUp =  SystemInfo /s $compName /fo list | find /i "Boot Time:" 

    Write-Host "" $timeUp -ForegroundColor White -BackgroundColor Red
}

CATCH [Exception]
{
    if ($_.Exception.GetType().Name -ne "RPC")
    {
        Write-Host "`n"
        Write-Host " :(  $compName isn't reachable (RPC is unavailable) - try locally instead." -ForegroundColor White -BackgroundColor Red
        Write-Host "`n"
    }

}

Write-Host " "

