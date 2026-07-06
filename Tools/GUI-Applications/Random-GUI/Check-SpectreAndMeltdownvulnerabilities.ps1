# Purpose: Check-SpectreAndMeltdownvulnerabilities — Standalone GUI applications and utilities.
Function Check-SpectreAndMeltdownvulnerabilities {{

Param ($Csv)

# Find the PDC Emulator, which is what we will connect to in order to list all computers in the domain Import-Module ActiveDirectory $pdce = (Get-ADDomain).PDCEmulator

# Retrieve a list of all computer objects in the domain that are not disabled, are not cluster virtual objects, and are running Windows $computerList = @() Get-ADComputer -Server $pdce -LDAPFilter "(&(!(userAccountControl:1.2.840.113556.1.4.803:=2))(!(servicePrincipalName=MSClusterVirtualServer*))(operatingSystem=Windows*))" | % {
    $computerList += $_.DNSHostName

# This is the script that is executed remotely against the target computers $remoteScript = {
    Try {
        # Set the error action prefer to "Stop" so that it will terminate and throw on any error
        $ErrorActionPreference = "Stop"

        # Install the SpeculationControl module and pre-reqs
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force | Out-Null
        Install-PackageProvider -Name NuGet -MinimumVersion 88.41.27.30 -Force | Out-Null
        Install-Module SpeculationControl -Force | Out-Null
        Import-Module SpeculationControl -Force | Out-Null

        # Test the system and return the results
        Get-SpeculationControlSettings 6> $null
    } Finally {
        # Uncomment the below lines if you want to uninstall the SpeculationControl module on each computer once the check is complete
        #Try { Remove-Module SpeculationControl -Force | Out-Null } Catch {}
        #Try { Uninstall-Module SpeculationControl -Force | Out-Null } Catch {}
    }
}


$format =  @{Expression={$_.Computer};Label="Computer";width=18}, `
    @{Expression={$_.ScanStatus};Label="Status";width=7}, `
    @{Expression={$_.BTIHardwarePresent};Label="BTIHWPr";width=7}, `
    @{Expression={$_.BTIWindowsSupportPresent};Label="BTIWinPr";width=8}, `
    @{Expression={$_.BTIWindowsSupportEnabled};Label="BTIWinEn";width=8}, `
    @{Expression={$_.BTIDisabledBySystemPolicy};Label="BTIDisSP";width=8}, `
    @{Expression={$_.BTIDisabledByNoHardwareSupport};Label="BTINoHWSup";width=10}, `
    @{Expression={$_.KVAShadowRequired};Label="KVAShdwRq";width=9}, `
    @{Expression={$_.KVAShadowWindowsSupportPresent};Label="KVIWinPr";width=8}, `
    @{Expression={$_.KVAShadowWindowsSupportEnabled};Label="KVIWinEn";width=8}, `
    @{Expression={$_.KVAShadowPcidEnabled};Label="KVIPcidEn";width=9}

$rowOne = $true

$computerList | % {
    # Hash-table for organizing output results
    $output = @{}
    $output.Computer = $_
    $output.ScanStatus = ""
    $output.BTIHardwarePresent = ""
    $output.BTIWindowsSupportPresent = ""
    $output.BTIWindowsSupportEnabled = ""
    $output.BTIDisabledBySystemPolicy = ""
    $output.BTIDisabledByNoHardwareSupport = ""
    $output.KVAShadowRequired = ""
    $output.KVAShadowWindowsSupportPresent = ""
    $output.KVAShadowWindowsSupportEnabled = ""
    $output.KVAShadowPcidEnabled = ""

    # Test to see if the computer is online, attempt the test, and store the results in the hash-table
    if (Test-Connection -ComputerName $output.Computer -Quiet -Count 1) {
        try {
            $result = Invoke-Command -ComputerName $output.Computer -ScriptBlock $remoteScript -ErrorAction Stop
            $output.ScanStatus = "OK"
            $output.BTIHardwarePresent = $result.BTIHardwarePresent 
            $output.BTIWindowsSupportPresent = $result.BTIWindowsSupportPresent 
            $output.BTIWindowsSupportEnabled = $result.BTIWindowsSupportEnabled 
            $output.BTIDisabledBySystemPolicy = $result.BTIDisabledBySystemPolicy 
            $output.BTIDisabledByNoHardwareSupport = $result.BTIDisabledByNoHardwareSupport 
            $output.KVAShadowRequired = $result.KVAShadowRequired 
            $output.KVAShadowWindowsSupportPresent = $result.KVAShadowWindowsSupportPresent 
            $output.KVAShadowWindowsSupportEnabled = $result.KVAShadowWindowsSupportEnabled 
            $output.KVAShadowPcidEnabled = $result.KVAShadowPcidEnabled 
        } catch {
            $output.ScanStatus = "Error"
        }
    } else {
        $output.ScanStatus = "Offline"
    }

    # If applicable, append to the CSV file
    if ($Csv -ne $null) {
        $row = New-Object PsObject -Property $output
        if ($rowOne) {
            $row | Export-Csv $Csv -NoTypeInformation -Force
            $rowOne = $false
        } else {
            $row | Export-Csv $Csv -Append -Force
        }
    }

    # Output the row
    New-Object –TypeName PSObject –Prop $output } | Format-Table $format
}