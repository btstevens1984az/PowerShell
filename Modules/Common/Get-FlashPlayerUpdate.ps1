<# 
    .SYNOPSIS 
        Get-FlashPlayerUpdate is a Powershell module to check and install FlashPlayer updates. 
 
    .DESCRIPTION 
        FlashPlayer has been target of many attacks recently and historically. For anyone, it is very important to keep the FlashPlayer up-to-date. To start with there are 3 types of FlashPlayer on Windows and traditional process to to get them is bit long and painful. This module tries to ease up on that pain and take care of checking and updating idividual or all type of FlashPlayers.  
 
    .PARAMETER  Type 
        There are 3 major types of FlashPlayers for Windows activex, plugin and pepper. This script provides additional [default] type all. As the name suggest 'all' checks/patches activex, plugin and pepper type of FlashPlayers. 
 
    .PARAMETER  Patch 
        Valid options for this parameter is yes, no. Default is yes. This parameter lets you check the version without patching the system. 
 
    .PARAMETER  Logfile 
        This is for future expansion of the module; where one can specify and logfile to redirect all the optput to that log file     
 
    .EXAMPLE 
        PS C:\> Get-FlashPlayerUpdate -Type 'activex' -Patch 'no' 
        Sample output: 
        ================================================================================ 
        Checking Flash Player version for activex architecture 
        ================================================================================ 
        Congratulations, your Flash Player (activex) [247.238.50.98] is up-to-date 
         
        This example shows how to check Local as well as Latest versions of ActiveX type FlashPlayer (used in IE). The additional parameter -Patch 'no' instructs module that we just want to compair Local and Latest version without installing it. 
 
    .EXAMPLE 
        PS C:\> Get-FlashPlayerUpdate 
        Sample output: 
        ================================================================================ 
        Checking Flash Player version for activex architecture 
        ================================================================================ 
        Congratulations, your Flash Player (activex) [247.238.50.98] is up-to-date 
        ================================================================================ 
        Checking Flash Player version for plugin architecture 
        ================================================================================ 
        No Plugin Flash Found 
        Installing Flash for plugin 
        You have successfully updated Flash Player for plugin [247.238.50.98] 
        Total time taken[0 h:0 m:4 s] 
        ================================================================================ 
        Checking Flash Player version for pepper architecture 
        ================================================================================ 
        No Pepper Flash Found 
        Installing Flash for pepper 
        You have successfully updated Flash Player for pepper [247.238.50.98] 
        Total time taken[0 h:0 m:5 s] 
         
        This example takes advantage of default -Type parameter 'all'. In other words, this will go and check if there is an update avialble for activex, plugin or pepper type FlashPlayer; and if yes it will download it from Adobe and install it. 
 
    .INPUTS 
        System.String 
 
    .OUTPUTS 
        System.String 
 
        For more information about advanced functions, call Get-Help with any 
        of the topics in the links listed below. 
 
#> 
 
function Get-FlashPlayerUpdate 
{ 
    [CmdletBinding(DefaultParameterSetName = 'Network')] 
    param 
    ( 
        [ValidateSet('activex', 'plugin', 'pepper', 'all')] 
        [string]$Type = 'all', 
        [ValidateSet('yes', 'no')] 
        [string]$Patch = 'yes', 
        [string]$Logfile 
    ) 
     
    begin 
    { 
        # Verify and host version of Powershell is at least 3 
        if ($PSVersionTable.PSVersion.Major -lt 3) 
        { 
            Write-Host "`r`nYou at least need PowerShell Version 3 to run some features of this script. Please install latest Windows Management Framework and re-run the script" 
            Exit 
        } 
        try 
        { 
            $Issue = $false 
            $URI = 'http://www.adobe.com/software/flash/about/' 
            $ScriptVersion = '175.203.202.114' 
            $LastUpdated = '9/30/16' 
             
            # using standard URL by adobe where they publish their latest FlashPlayer versions, Invoke-WebRequest stores the content of whole page into variable HTML                                     
            if (!(Test-Path variable:Adobe_Version)) 
            { 
                Write-Host "`r`nFlash Player Update Script`r`n" -ForegroundColor Green 
                Write-Host "Script Version: $ScriptVersion [Last updated on $LastUpdated]`r`n" -ForegroundColor Yellow 
                 
                $HTML = Invoke-WebRequest -Uri $URI 
                 
                 
                # we proceed further if web request was successful 
                if ($HTML.StatusCode -eq 200) 
                { 
                    # tempvar extracts current versions of the flash players of all the platforms and all the kinds 
                    $tempvar = (($HTML.AllElements | ? { $_.tagName -eq "table" }).innerText).split("`n") 
                    # a hashtable is innitiated which will store all the flash player versions 
                    $Adobe_Version = @{ } 
                    # based on the sequence in the adobe webpage these positions are hard coded in a hashtable 
                    $Flash_PlayerIndex = @{ "ActiveX" = 1; "NPAPI" = 4; "PPAPI" = 6 } 
                    # if OS is newer than Windows 8 then for activex version, embeded option is chosen at a different position 
                    $OS_version = [System.Environment]::OSVersion.Version 
                    if ($OS_version -ge [System.Version]"6.3.0.9600") 
                    { 
                        $Os_newer_than_8 = $true 
                        if ($OS_version -ge [System.Version]"203.232.155.49") 
                        { 
                            $Flash_PlayerIndex["ActiveX"] = 3 
                        } 
                        else 
                        { 
                            $Flash_PlayerIndex["ActiveX"] = 2 
                        } 
                         
                    } 
                    # array with simple name for different types of flash player is created here 
                    $Flash_PlayerType = @("activex", "plugin", "pepper") 
                     
                    # based on above arrays, below loop extracts version numbers of the all relevent flash player types and puts them into Adobe_Version hashtable 
                    $i = 2 
                    foreach ($fp in $Flash_PlayerIndex.GetEnumerator()) 
                    { 
                        $tempIndex = $tempvar[$fp.Value].IndexOf($fp.Name) + ($fp.Name).length 
                        $Adobe_Version.Add($Flash_PlayerType[$i], [System.Version]($tempvar[$fp.Value].Substring($tempIndex, ($tempvar[$fp.Value]).Length - $tempIndex))) 
                         
                        # to be sure about the extracted version, we test it with simple regex  
                        if (!($Adobe_Version[$Flash_PlayerType[$i]] -match '\d+\.\d+\.\d+\.\d+')) 
                        { 
                            $Issue = $true 
                        } 
                        $i-- 
                    } 
                } 
                else 
                { 
                    $Issue = $true 
                } 
                # A hack put together with trial and error extracts Version detail table. There is possibility of this being point of failiur but a RegEx verifies the version later in the module             
                 
                if ($Issue) 
                { 
                    Write-Host "`r`n`r`nSorry there was some issue with getting Adobe version. A window would shortly open where you can refer to it manually." 
                    Start-Process "C:\Program Files\Internet Explorer\iexplore.exe" -Args 'http://www.adobe.com/software/flash/about/' 
                    exit 
                } 
            } 
        } 
        catch 
        { 
            # if this operation did not work then there was a problem with internet and we can't go any further.             
            Write-Debug "Some issue connecting it to Internet" 
        } 
    } 
    process 
    { 
        #################################################################################################################### 
        #         General notes: This function checks Local and Latest (Adobe) version of type activex, plugin and pepper 
        #         Input: 
        #            Parameters (All mandatory)) 
        #                Type [Type String]: activex, plugin, pepper 
        #         Output: 
        #            VersionNumber [Type String] 
        ####################################################################################################################         
        function Get-FlashPlayerCurrVer 
        { 
            Param 
            ( 
                [Parameter(Mandatory = $True)] 
                [ValidateSet('activex', 'plugin', 'pepper')] 
                [string]$Type 
            ) 
             
            Switch ($Type) 
            { 
                "activex" { 
                    $VersionNumber = "" 
                    if ($Os_newer_than_8) 
                    { 
                        if (Test-Path "C:\Windows\System32\Macromed\Flash\Flash.ocx") 
                        { 
                            $VersionNumber = (Get-ItemProperty "C:\Windows\System32\Macromed\Flash\Flash.ocx").VersionInfo.ProductVersion -replace ",", "." 
                        } 
                    } 
                    else 
                    { 
                        if (Test-Path hklm:\SOFTWARE\Macromedia\FlashPlayerActiveX) 
                        { 
                            $VersionNumber = (Get-ItemProperty hklm:\SOFTWARE\Macromedia\FlashPlayerActiveX).Version 
                        } 
                        else 
                        { 
                        # logic infers that if no registry found or no OCX found, Flash player for that type does not exist 
                        $VersionNumber = "No ActiveX Flash Found" 
                        } 
                    } 
                } 
                "plugin" { 
                    if (Test-Path hklm:\SOFTWARE\Macromedia\FlashPlayerPlugin) 
                    { 
                        $VersionNumber = (Get-ItemProperty hklm:\SOFTWARE\Macromedia\FlashPlayerPlugin).Version 
                    } 
                    else 
                    { 
                        $VersionNumber = "No Plugin Flash Found" 
                    } 
                } 
                "pepper" { 
                    if (Test-Path hklm:\SOFTWARE\Macromedia\FlashPlayerPepper) 
                    { 
                        $VersionNumber = (Get-ItemProperty hklm:\SOFTWARE\Macromedia\FlashPlayerPepper).Version 
                    } 
                    else 
                    { 
                        $VersionNumber = "No Pepper Flash Found" 
                    } 
                } 
            } 
            return $VersionNumber.Trim() 
        } 
         
        #################################################################################################################### 
        #         General notes: This function obtains Latest (Adobe) version of type activex, plugin or pepper and installs it 
        #         Input: 
        #            Parameters (All mandatory)) 
        #                Type [Type String]: activex, plugin, pepper 
        #         Output: 
        #            VersionNumber [Type String] 
        #################################################################################################################### 
         
        function Install-FlashPlayer 
        { 
            param 
            ( 
                [Parameter(Mandatory = $True)] 
                [ValidateSet('activex', 'plugin', 'pepper')] 
                [string]$Type 
            ) 
            # A temp directory in C root is created if not alread exist to store the installer 
            if (!(Test-Path "c:\Temp")) 
            { 
                New-Item c:\Temp -ItemType directory 
                # this global variable helps cleanup after the fact if that folder did not exist before 
                $global:TempFolder = $true 
            } 
             
            # A filename with path is generated on the fly based on the function parameter 'type' 
            $Local_storage = "c:\Temp\FP_$($Type)_installer.exe" 
            switch ($Type) 
            { 
                'activex' { $Uvar = '_ax' } 
                'plugin' { $Uvar = '' } 
                'pepper' { $Uvar = '_ppapi' } 
            } 
             
            # Adobe provides latest FlashPlayer with some suffix at the end, which we create with above switch and incorporate it in bellow URL 
            $Adobe_url = "http://fpdownload.macromedia.com/pub/flashplayer/latest/help/install_flash_player$Uvar.exe" 
             
            # There are a few ways to download a file from web using PowerShell but this .net method proven to be most efficient. This is available all the way since .net 1.1 
            (New-Object System.Net.WebClient).DownloadFile($Adobe_url, $Local_storage) 
             
            # Use Unblock-File to prevent PowerShell security warning popups during installation. 
            Unblock-File -Path $Local_storage 
             
            # To test the install Global $error variable is cleared and LASTEXITCODE is set to NULL  
            $error.clear() 
            $global:LASTEXITCODE = $null 
            Write-Debug "Installing $Local_storage..." 
             
            # Installer exe takes command argument '-install' to perform a silent install (which can be found in Admin guide for FlashPlayer)                                     
            $cmd = "Start-Process $Local_storage -Args '-install' -Wait" 
            # A handy command in PowerShell allows measuring of time taken for this install process 
            $TotalTime = Measure-Command { Invoke-Expression $cmd } 
             
            # bellow if statement checks for any error reported and the exit code be anything else than 0.  
            if (($? -eq $true) -and ([string]::IsNullOrEmpty($error[0])) -and ([string]::IsNullOrEmpty($lastexitcode) -or $lastexitcode -eq 0)) 
            { 
                [System.Version]$Local_Version = Get-FlashPlayerCurrVer -Type $Type 
                 
                # If all has gone well, no errors and exit code is also 0, one more time version is checked and if for what ever reasons its not same as latest version 
                # (Eg: Starting Windows 8.1, Windows does not allow install of ActiveX based FlashPlayer, as they have embeded the FlashPlayer in IE) then a message is shown on the screen suggesting same 
                # if version matches, a message is also shown on the screen with the version of it and total time it took to get installed 
                if ($Local_Version -eq $Adobe_Version[$Type]) 
                { 
                    Write-Host "`r`nYou have successfully updated Flash Player for $Type [$Local_Version]`r`nTotal time taken[$($TotalTime.Hours) h:$($TotalTime.Minutes) m:$($TotalTime.Seconds) s]" 
                } 
                else 
                { 
                    Write-Host "`r`nSomething went wrong. Adobe's current version for $Type is $($Adobe_Version[$Type]); and local version of $Type is $Local_Version" 
                } 
            } 
            else 
            { 
                # there are some listed exit codes by Adobe which shows proper error 
                switch ($LASTEXITCODE) 
                { 
                    1003 { $ErrorMessage = "Invalid argument passed to installer" } 
                    1011 { $ErrorMessage = "Install already in progress" } 
                    1012 { $ErrorMessage = "Does not have admin permissions (W2K, XP)" } 
                    1013 { $ErrorMessage = "Trying to install older revision" } 
                    1022 { $ErrorMessage = "Does not have admin permissions (Vista, Windows 7)" } 
                    1024 { $ErrorMessage = "Unable to write files to directory" } 
                    1025 { $ErrorMessage = "Existing Player in use" } 
                    1032 { $ErrorMessage = "ActiveX registration failed" } 
                    1041 { $ErrorMessage = "An application that uses the Flash Player is open. Quit the application and try again." } 
                    3 { $ErrorMessage = "Does not have admin permissions" } 
                    4 { $ErrorMessage = "Unsupported OS" } 
                    5 { $ErrorMessage = "Previously installed with elevated permissions" } 
                    6 { $ErrorMessage = "Insufficient disk space" } 
                    7 { $ErrorMessage = "Trying to install older revision" } 
                    8 { $ErrorMessage = "Browser is open" } 
                } 
                Write-Host "`r`nThere was en error with update. Specific error was:`r`n$ErrorMessage" 
            } 
             
            # At the end of install success or not, temp file is deleted 
            Remove-Item $Local_storage -Force 
        } 
         
        # TODO: infuture implement this fuction to redirect output of the script to a logfile if speficied 
        function Log-this 
        { 
            param 
            ( 
                [parameter(Mandatory = $true)] 
                [string]$message 
            ) 
            if ($Logfile.Trim() -eq '') 
            { 
                Write-Host $message 
            } 
            else 
            { 
                Write-Output $message | Out-File $Logfile -Append 
            } 
        } 
         
        if ($Logfile.Trim() -ne '') 
        { 
            if (!(Test-Path $Logfile)) 
            { 
                New-Item -ItemType file -Path $Logfile 
            } 
        } 
         
        # if the type is 'all' then this code, calls the mother function Get-FlashPlayerUpdate with appropriate parameter each time for all 3 types 
        if ($Type -eq 'all') 
        { 
            $CommandToRun = ("Get-FlashPlayerUpdate -Type 'activex' -Patch $Patch") 
            Write-Debug "Running:`r`n$CommandToRun" 
            Invoke-Expression $CommandToRun 
            $CommandToRun = ("Get-FlashPlayerUpdate -Type 'plugin' -Patch $Patch") 
            Write-Debug "Running:`r`n$CommandToRun" 
            Invoke-Expression $CommandToRun 
            $CommandToRun = ("Get-FlashPlayerUpdate -Type 'pepper' -Patch $Patch") 
            Write-Debug "Running:`r`n$CommandToRun" 
            Invoke-Expression $CommandToRun 
        } 
        else 
        { 
            # if a type is specified during fuction call, a message is showen on the screen 
            Write-Host "`r`n" 
            Write-Host $("=" * 80) 
            Write-Host "Checking Flash Player version for $Type architecture" 
            Write-Host $("=" * 80) 
             
            # Local version of the respective FlashPlayer type is obtian via our function call 
            $Local_Version = Get-FlashPlayerCurrVer -Type $Type 
             
            # If there is no FlashPlayer detected, our response will start from 'No' which is by design to show details with in same response then if portion is executed 
            if ($Local_Version.StartsWith("No")) 
            { 
                # if parameter Patch is set to yes then Install-FlashPlayer function is called else a message is shown on the screen suggesting they should install latest version 
                Write-Host "`r`n$Local_Version`r`n" 
                if ($Patch -eq 'yes') 
                { 
                    if ($Os_newer_than_8 -eq $true -and $Type -eq 'activex') 
                    { 
                        Write-Host "`r`nPlease run Windows Updates as Flash Player for IE is now embedded`r`n" 
                    } 
                    else 
                    { 
                        Write-Host "`r`nInstalling Flash for $Type" 
                        Install-FlashPlayer -Type $Type 
                        Write-Host "`r`n" 
                    } 
                } 
                else 
                { 
                    Write-Host "`r`nPlse install Flash Player ($Type), your system is at very high risk`r`n`r`n" 
                } 
            } 
            else 
            { 
                # We will be here if the script has found a version number from registry hive 
                 
                # if both local and aodbe version are same message is shown on the screen suggesting you are up-to-date 
                if ([System.Version]$Local_Version -eq $Adobe_Version[$Type]) 
                { 
                    Write-Host "`r`nCongratulations, your Flash Player ($Type) [$($Adobe_Version[$Type])] is up-to-date`r`n`r`n" 
                } 
                else 
                { 
                    # we will come here if local version and adobe version don't match. We display appropriate message on the screen 
                     
                    Write-Host "`r`nCurrent version of Flash Player is: $($Adobe_Version[$Type]), version on your computer is: $Local_Version`r`n" 
                     
                    # if patching is allowed we call functino Install-FlashPlayer and supply type to install FlashPlayer 
                    if ($Patch -eq 'yes') 
                    { 
                        if ($Os_newer_than_8 -eq $true -and $Type -eq 'activex') 
                        { 
                            Write-Host "`r`nPlease run Windows Updates as Flash Player for IE is now embedded`r`n" 
                        } 
                        else 
                        { 
                            Write-Host "`r`nUpdating your Flash Player...`r`n" 
                            Install-FlashPlayer -Type $Type 
                        } 
                    } 
                    else 
                    { 
                        # else we let user know that they should install latest FlashPlayer 
                        Write-Host "`r`nPlse update your Flash Player ($Type :$($Adobe_Version[$Type])), your system is at very high risk`r`n`r`n" 
                    } 
                } 
            } 
        } 
    } 
    end 
    { 
        # At the end we delete temp folder it was not there 
        try 
        { 
            if ($TempFolder) 
            { 
                Remove-Item -Path c:\Temp -Force -Recurse >$null 2>&1 
            } 
        } 
        catch 
        { 
            Write-Debug "Something went wrong while removing Utilities folder" 
        } 
    } 
} 
#Export-ModuleMember -Function Get-FlashPlayerUpdate 