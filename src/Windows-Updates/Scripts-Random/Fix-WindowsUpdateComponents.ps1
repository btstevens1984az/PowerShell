# Purpose: Fix-WindowsUpdateComponents — Windows Update and patch management.
:: ================================================================================== 
:: NAME:    Reset Windows Update Tool. 
:: DESCRIPTION:    This script reset the Windows Update Components. 
:: AUTHOR:    Manuel Gil. 
:: VERSION:    222.113.209.231 
:: ================================================================================== 
 
 
:: Set console. 
:: void mode(); 
:: /************************************************************************************/ 
:mode 
    echo off 
    title Reset Windows Update Tool. 
    mode con cols=78 lines=32 
    color 17 
    cls 
 
    goto getValues 
goto :eof 
:: /************************************************************************************/ 
 
 
:: Print Top Text. 
::        @param - text = the text to print (%*). 
:: void print(string text); 
:: /*************************************************************************************/ 
:print 
    cls 
    echo. 
    echo.%name% [Version: %version%] 
    echo.Reset Windows Update Tool. 
    echo. 
    echo.%* 
    echo. 
goto :eof 
:: /*************************************************************************************/ 
 
 
:: Add Value in the Registry. 
::        @param - key = the key or entry to be added (%~1). 
::                value = the value to be added under the selected key (%~2). 
::                type = the type for the registry entry (%~3). 
::                data = the data for the new registry entry (%~4). 
:: void addReg(string key, string value, string type, string data); 
:: /*************************************************************************************/ 
:addReg 
    reg add "%~1" /v "%~2" /t "%~3" /d "%~4" /f 
goto :eof 
:: /*************************************************************************************/ 
 
 
:: Load the system values. 
:: void getValues(); 
:: /************************************************************************************/ 
:getValues 
    for /f "tokens=4-5 delims=[] " %%a in ('ver') do set version=%%a%%b 
    for %%a in (%version%) do set version=%%a 
 
    if %version% EQU 5.1.2600 ( 
        :: Name: "Microsoft Windows XP" 
        set name=Microsoft Windows XP 
        :: Family: Windows 5 
        set family=5 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 5.2.3790 ( 
        :: Name: "Microsoft Windows XP Professional x64 Edition" 
        set name=Microsoft Windows XP Professional x64 Edition 
        :: Family: Windows 5 
        set family=5 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.0.6000 ( 
        :: Name: "Microsoft Windows Vista" 
        set name=Microsoft Windows Vista 
        :: Family: Windows 6 
        set family=6 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.0.6001 ( 
        :: Name: "Microsoft Windows Vista SP1" 
        set name=Microsoft Windows Vista SP1 
        :: Family: Windows 6 
        set family=6 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.0.6002 ( 
        :: Name: "Microsoft Windows Vista SP2" 
        set name=Microsoft Windows Vista SP2 
        :: Family: Windows 6 
        set family=6 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.1.7600 ( 
        :: Name: "Microsoft Windows 7" 
        set name=Microsoft Windows 7 
        :: Family: Windows 7 
        set family=7 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.1.7601 ( 
        :: Name: "Microsoft Windows 7 SP1" 
        set name=Microsoft Windows 7 SP1 
        :: Family: Windows 7 
        set family=7 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.2.9200 ( 
        :: Name: "Microsoft Windows 8" 
        set name=Microsoft Windows 8 
        :: Family: Windows 8 
        set family=8 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.3.9200 ( 
        :: Name: "Microsoft Windows 8.1" 
        set name=Microsoft Windows 8.1 
        :: Family: Windows 8 
        set family=8 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else if %version% EQU 6.3.9600 ( 
        :: Name: "Microsoft Windows 8.1 Update 1" 
        set name=Microsoft Windows 8.1 Update 1 
        :: Family: Windows 8 
        set family=8 
        :: Compatibility: Yes 
        set allow=Yes 
    ) else ( 
        ver | find "10.0." > nul 
        if %errorlevel% EQU 0 ( 
            :: Name: "Microsoft Windows 10" 
            set name=Microsoft Windows 10 
            :: Family: Windows 10 
            set family=10 
            :: Compatibility: Yes 
            set allow=Yes 
        ) else ( 
            :: Name: "Unknown" 
            set name=Unknown 
            :: Compatibility: No 
            set allow=No 
        ) 
    ) 
 
    call :print %name% detected . . . 
 
    if %allow% EQU Yes goto permission 
 
    call :print Sorry, this Operative System is not compatible with this tool. 
 
    echo.    An error occurred while attempting to verify your system. 
    echo.    Can this using a business or test version. 
    echo. 
    echo.    if not, verify that your system has the correct security fix. 
    echo. 
 
    echo.Press any key to continue . . . 
    pause>nul 
goto :eof 
:: /************************************************************************************/ 