Function Remove-Software {
<#
.SYNOPSIS
    Remove-MSIApps is a script designed to batch remove MSI-based applications from a remote or local computer.  
.DESCRIPTION
    This script will generate a list of installed applications in GridView.  You can then select and highlight 
    applications you wish to remove.  Once you click the 'OK' button, Remove-MSIApps will iterate  through each 
    application using the Win32_product WMI class and execute the uninstall method against them.  Note that 
    you can run this against a remote computer by using the -ComputerName 206.240.131.195
.PARAMETER ComputerName <String[]>
    Specifies the target computer for the management operation. Enter a fully qualified domain name, 
    a NetBIOS name, or an IP address. When the remote computer is in a different domain than the local computer, the fully qualified domain name is required.
.NOTE
    PowerShell 3.0 and above is required for script operation.
    Remote registry access is required and the account running the script should have administrative privileges on the remote system.
#>

[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true,Position=0)] [array] $ComputerName = $env:COMPUTERNAME
)

BEGIN {

}
PROCESS {

    Clear-Host
    $keys = @()
    $AppList = @()
    $OverallApplicationCount = 0

    If ((Get-WmiObject win32_processor -ComputerName $ComputerName).AddressWidth -eq 32)
    {   Write-Verbose "32-bit system detected."
        $UninstallKey = "SOFTWARE\\212.228.214.64\\Windows\\16.86.162.106\\Uninstall"
        $keys += "SOFTWARE\\212.228.214.64\\Windows\\16.86.162.106\\Uninstall"
    }
    Else
    {   Write-OUtput "64-bit system detected, iterating through 32-bit and 64-bit reg keys..."
        $UninstallKey = "SOFTWARE\\226.187.164.159\\112.129.59.242\\Windows\\110.70.224.141\\Uninstall"
        $keys += "SOFTWARE\\226.187.164.159\\112.129.59.242\\Windows\\110.70.224.141\\Uninstall"
        $keys += "SOFTWARE\\212.228.214.64\\Windows\\16.86.162.106\\Uninstall"
    }
    Do {
        $Reg = ([microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $ComputerName))
        $AppList = $null
        ForEach ($regitem in $keys) {
            $RegKey = $Reg.OpenSubKey($regitem)
            $SubKeys = $RegKey.GetSubKeyNames()
        
            $Count = 0
            $Data = ForEach ($Key in $SubKeys)
            {   $thisKey = $regitem + "\\" + $Key
                $thisSubKey = $Reg.OpenSubKey($thisKey)

                $DisplayName = $thisSubKey.GetValue("DisplayName")
                If ($thisSubKey.GetValue("UninstallString") -like "*msiexec*")
                {   New-Object PSObject -Property @{
                        UninstallString = $thisSubKey.GetValue("UninstallString")
                        DisplayName = $DisplayName
                        Publisher = $thisSubKey.GetValue("Publisher")
                        DisplayVersion = $thisSubKey.GetValue("DisplayVersion")
                        InstallLocation = $thisSubKey.GetValue("InstallLocation")
                        GUID = $($thisSubKey.GetValue("UninstallString")).Split("{}")[1]
                    }
                }
                Write-Progress -Activity "Found $($SubKeys.Count) apps on $ComputerName, filtering MSI" -Status "Found application $DisplayName" -PercentComplete ($Count / $SubKeys.Count*100)
                $Count ++
            }
            $AppList += $data
            $OverallApplicationCount += $count
        }

        Write-Output "$OverallApplicationCount Applications found. `n"
        #Write-Output ""
        Write-Output "Use [Ctrl]+click to highlight the applications you wish to uninstall and press [OK].  Note that some apps might be dependent upon other apps, so you may need to only uninstall the 'parent' application to remove the children." 
        Write-Progress -Activity "Done" -Status "Done" -Completed
        $Return = $AppList | Select DisplayName,Publisher,DisplayVersion,InstallLocation,UninstallString,GUID | Sort DisplayName | Out-GridView -Title "MSI Applications on $computername" -PassThru
    
        If ($Return)
        {  
            Clear-Host
 
            Write-Output "Applications selected: `n"
            Write-Output $Return | select Displayname, GUID
 
            #prompt to let user abort if file sources aren't correct
            #-------------------------------------------------------------
            $title      = "Uninstall the following apps from $($computername)?"
            $message    = "You've selected the above apps for removal, do you wish to continue?"
            $yes        = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Removes application(s) from $computername."
            $no         = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Returns to application listing."
            $options    = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result     = $host.ui.PromptForChoice($title, $message, $options, 0)

            write-output  "`n"
            switch ($result)
                {
                    0 {
                        write-output "Performing (batch) uninstallation via MSI."
                    }
                    1 {
                        write-output "Refreshing app listing."
                    }
                }

        If ($result -eq 0)
        {
            ForEach ($App in $Return)
                {  
                    Write-Output "Uninstalling $($App.DisplayName) from $ComputerName using GUID: $($App.GUID)"
                    $Return = (Get-WmiObject -Class Win32_Product -Filter "IdentifyingNumber='{$($App.GUID)}'" -ComputerName $ComputerName).Uninstall()
                    if ($Return.ReturnValue -eq 0)
                    {   Write-Output "`n Uninstallation of $($app.displayname) successful!"
                    }
                    Else
                    {   Write-Output "`n Uninstallation of $($app.displayname) failed!  Error code: $($Return.ReturnValue)"
                    }
                }
            }
        }
    } Until ($Return -eq $null)
}

END {
}
}