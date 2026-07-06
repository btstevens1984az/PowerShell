# Purpose: Get-InstalledSoftwarev2 — Reusable PowerShell function libraries.
<#     
    =========================================================================== 
     Created with:     SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.149 
     Created on:       15/4/2018 19:17 
     Filename:         Get-InstalledSoftware.ps1 
     Version:        1.0 
    =========================================================================== 
    .SYNOPSIS 
        Get-InstalledSoftware retrieves a list of installed software 
    .DESCRIPTION 
        Get-InstalledSoftware opens up the specified (remote) registry and scours 
        it for installed software. When found it returns a list of the software 
        and it's version. 
    .PARAMETER ComputerName 
    The computer from which you want to get a list of installed software. Defaults to the local host. 
    .EXAMPLE 
        Get-InstalledSoftware 19.131.54.185 
     
        This will return a list of software from DC1. Like: 
        Name                        Version            Computer      UninstallCommand 
        ----                        -------         --------      ---------------- 
        Google Chrome                66.0.3359.117    DC101         "C:\Program Files (x86)\Google\Chrome\Application\66.0.3359.117\Installer\setup.exe" --uninstall --system-level --verbose-logging 
        Adobe Acrobat Reader DC     18.011.20038    DC101          MsiExec.exe /I{AC76BA86-7AD7-1033-7B44-AC0F074E4100} 
        Java 8 Update 161            8.0.1610.12        19.131.54.185        MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F32180161F0} 
    .EXAMPLE 
        Import-Module ActiveDirectory 
        Get-ADComputer -filter 'name -like "19.131.54.185"' | Get-InstalledSoftware 
 
        This will get a list of installed software on every AD computer that matches the AD filter (So all computers with names starting with DC) 
    .INPUTS 
        [string[]]Computername 
    .OUTPUTS 
        PSObject with properties: Name,Version,Computer,UninstallCommand 
#> 
 
Function Get-InstalledSoftwarev2 
{ 
    Param 
    ( 
        [Alias('Computer', 'ComputerName', 'HostName')] 
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $true, Position = 1)] 
        [string[]]$Name = $env:COMPUTERNAME 
    ) 
    Begin 
    { 
        $LMkeys = "Software\Microsoft\Windows\CurrentVersion\Uninstall", "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" 
        $LMtype = [Microsoft.Win32.RegistryHive]::LocalMachine 
        $CUkeys = "Software\Microsoft\Windows\CurrentVersion\Uninstall" 
        $CUtype = [Microsoft.Win32.RegistryHive]::CurrentUser 
         
    } 
    Process 
    { 
        ForEach ($Computer in $Name) 
        { 
            $MasterKeys = @() 
            If (!(Test-Connection -ComputerName $Computer -count 1 -quiet)) 
            { 
                Write-Error -Message "Unable to contact $Computer. Please verify its network connectivity and try again." -Category ObjectNotFound -TargetObject $Computer 
                Break 
            } 
            $CURegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($CUtype, $computer) 
            $LMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($LMtype, $computer) 
            ForEach ($Key in $LMkeys) 
            { 
                $RegKey = $LMRegKey.OpenSubkey($key) 
                If ($RegKey -ne $null) 
                { 
                    ForEach ($subName in $RegKey.getsubkeynames()) 
                    { 
                        foreach ($sub in $RegKey.opensubkey($subName)) 
                        { 
                            $MasterKeys += (New-Object PSObject -Property @{ 
                                    "ComputerName"  = $Computer 
                                    "Name"            = $sub.getvalue("displayname") 
                                    "SystemComponent" = $sub.getvalue("systemcomponent") 
                                    "ParentKeyName" = $sub.getvalue("parentkeyname") 
                                    "Version"        = $sub.getvalue("DisplayVersion") 
                                    "UninstallCommand" = $sub.getvalue("UninstallString") 
                                }) 
                        } 
                    } 
                } 
            } 
            ForEach ($Key in $CUKeys) 
            { 
                $RegKey = $CURegKey.OpenSubkey($Key) 
                If ($RegKey -ne $null) 
                { 
                    ForEach ($subName in $RegKey.getsubkeynames()) 
                    { 
                        foreach ($sub in $RegKey.opensubkey($subName)) 
                        { 
                            $MasterKeys += (New-Object PSObject -Property @{ 
                                    "ComputerName"  = $Computer 
                                    "Name"            = $sub.getvalue("displayname") 
                                    "SystemComponent" = $sub.getvalue("systemcomponent") 
                                    "ParentKeyName" = $sub.getvalue("parentkeyname") 
                                    "Version"        = $sub.getvalue("DisplayVersion") 
                                    "UninstallCommand" = $sub.getvalue("UninstallString") 
                                }) 
                        } 
                    } 
                } 
            } 
            $MasterKeys = ($MasterKeys | Where { $_.Name -ne $Null -AND $_.SystemComponent -ne "1" -AND $_.ParentKeyName -eq $Null } | select Name, Version, ComputerName, UninstallCommand | sort Name) 
            $MasterKeys 
        } 
    } 
    End 
    { 
         
    } 
}
