
Function Close-AllISEFiles
{
<#
.Synopsis
   Closes All ISE files in the current Powershell Tab of the ISE
.DESCRIPTION
   This command will close all files in the current ISE Powershell tab. Unsaved files won't be closed unless the force parameter is used.
.EXAMPLE
   Close-AllISEFiles
.EXAMPLE
   Close-AllISEFiles -force
.EXAMPLE
   Close-AllISEFiles -force -verbose
.parameter Files
    Files to close. By default includes all files in current Powershell Tab of the ISE
.parameter Force
    Forces the closing of unsaved script tabs.
#>
    [cmdletbinding(
                    ConfirmImpact='high',
                    SupportsShouldProcess=$true
                    )]
    param(
            [switch]$force,
            [array]$files = $psise.CurrentPowerShellTab.Files
        )
    Foreach ($file in $files)
    {
        If ($PSCmdlet.ShouldProcess($file.DisplayName,"Close File"))
        {
            If ($force)
            {
                Write-Verbose "Closing: $($file.DisplayName)"
                $psise.CurrentPowerShellTab.files.Remove($file,$force) | Out-Null
            }
            Elseif ($file.IsSaved)
            {
                Write-Verbose "Closing: $($file.DisplayName)"
                $psise.CurrentPowerShellTab.files.Remove($file) | Out-Null
            }
            else
            {
                Write-Verbose "$($file.DisplayName) won't be closed because it hasn't been saved.`n Use the -force paramter to close unsaved files or save the file and run this function again."
            }
        }
    }
}

#create a custom sub menu
$MyAddOns=$psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Jeff's Stuff",$null,$null)
#add my menu addons
$MyAddOns.submenus.Add("Close All Saved ISE Files",{Close-AllISEFiles},$null) | Out-Null
$MyAddOns.submenus.Add("Force Close All ISE Files",{Close-AllISEFiles -force -Confirm:$false},"ALT+C") | Out-Null
$MyAddOns.submenus.Add("Clear Host",{Clear-Host},"alt+b") | Out-Null