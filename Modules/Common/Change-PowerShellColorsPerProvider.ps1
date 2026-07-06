# Purpose: Change-PowerShellColorsPerProvider — Reusable PowerShell function libraries.
#this won't display properly on Linux
Function Change-PowerShellColorsPerProvider {
    # .Description
    # This custom version of the PowerShell prompt will present a colorized location value based on the current provider. It will also display the PS prefix in red if the current user is running as administrator.    
    # .Link
    # https://go.microsoft.com/fwlink/?LinkID=225750
    # .ExternalHelp System.Management.Automation.dll-help.xml
 
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    if ( (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        $adminfg = "Red"
    }
    else {
        $adminfg = $host.ui.rawui.ForegroundColor
    }
 
    Switch ((get-location).provider.name) {
        "FileSystem" { $fg = "green"}
        "Registry" { $fg = "magenta"}
        "wsman" { $fg = "cyan"}
        "Environment" { $fg = "yellow"}
        "Certificate" { $fg = "darkcyan"}
        "Function" { $fg = "gray"}
        "alias" { $fg = "darkgray"}
        "variable" { $fg = "darkgreen"}
        Default { $fg = $host.ui.rawui.ForegroundColor}
    } 
 
    Write-Host “[{0:HH:mm:ss}] ” -f (Get-Date) -NoNewline
    Write-Host "PS " -nonewline -ForegroundColor $adminfg
    Write-Host "$($executionContext.SessionState.Path.CurrentLocation)" -foregroundcolor $fg -nonewline
    Write-Output "$('>' * ($nestedPromptLevel + 1)) "  
}