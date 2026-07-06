# Purpose: Set-TrustedComputers — Routine computer maintenance and cleanup.
Function Set-TrustedComputers {
# Strongly typed array, meaning only strings are allowed in the "$TrustedComputers" array.
[string[]]$TrustedComputers = @("QWERTYPC", "$env:COMPUTERNAME")
    $i=0
    foreach($computer in $TrustedComputers){
        Set-Item –Path WSMan:\localhost\Client\TrustedHosts –Value $computer.ToUpper() -Concatenate -Force
        $i++
        Write-Host $computer
        Write-Progress -activity “Writing computer hostname to TrustedHosts Configuration” -status “Status: ” -PercentComplete (($i / $TrustedComputers.count)*100)
    }
Get-Item –Path WSMan:\localhost\Client\TrustedHosts

function Test-NetworkProfile {
    $NetConn = Get-NetConnectionProfile
    $NetCategory = $NetConn.NetworkCategory
    switch ($NetCategory) {
        "Domain" { Write-Host "The network profile: {$NetCategory} is set correctly for PS remoting." -ForegroundColor Green }
        "Private" { Write-Host "The network profile: {$NetCategory} is set correctly for PS remoting." -ForegroundColor Green }
        "Public" { Write-Warning "The network profile: {$NetCategory} is set incorrectly for PS remoting.";
            Write-Host "We can set your Adapter profile to {Private} for you if you would like." -ForegroundColor Yellow -BackgroundColor Black
            $confirmation = Read-Host "Yes[y] or No[n]?"
            if ($confirmation -ieq "y") {
                try {
                    $SetNet = Set-NetConnectionProfile –InterfaceIndex $NetConn.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
                    Write-Host "Successfully updated your Adapter Profile to: $NetCategory" -ForegroundColor Green
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                    Write-Error "$FailedItem failed during the configuration step(s). Error message: $ErrorMessage"
                }
                finally {
                    $Time = Get-Date
                    Write-Host "Configuration events were attempted at: $Time" -ForegroundColor Cyan
                }
            }
            else {
            Write-Host "User cancelled the operation..." -ForegroundColor Red -BackgroundColor Black
            }
        }
    }
}

# Test-NetworkProfile

# Enable-PSRemoting -Force

# Enter-PSSession –Computername 31.39.1.252 –Credential "31.39.1.252\administrator"
}