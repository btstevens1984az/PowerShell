# Purpose: Clean-TempItems — Routine computer maintenance and cleanup.
Function Clean-TempItems
{
    $SystemTempPath = Join-Path -Path $env:windir -ChildPath "Temp"
    $ProfileTempPath = $env:TEMP

    $SystemTempPath, $ProfileTempPath | ForEach-Object `
    {
        Write-Host -Object "Deleting temporary files in " -NoNewline
        Write-Host -Object $_ -NoNewline -ForegroundColor Cyan
        Write-Host -Object ":"
        Get-ChildItem -Path (Join-Path -Path $_ -ChildPath "*") -ErrorAction SilentlyContinue | ForEach-Object `
        {
            Write-Host -Object "$([Char] 0x2022) Deleting " -NoNewline
            Write-Host -Object $_.Name -NoNewline -ForegroundColor Cyan
            Write-Host -Object "... " -NoNewline
            try
            {
                Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
                Write-Host -Object "Done." -ForegroundColor Green
            }
            catch
            {
                Write-Host -Object "Failed ($($_.Exception.Message))." -ForegroundColor Red
            }
        }
    }
}
