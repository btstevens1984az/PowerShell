@echo off
title Nebula Loom
cd /d "%~dp0"
echo.
echo Starting Nebula Loom...
echo.

where py >nul 2>nul
if %ERRORLEVEL%==0 (
  py nebula_loom.py %*
  goto :done
)

where python >nul 2>nul
if %ERRORLEVEL%==0 (
  python nebula_loom.py %*
  goto :done
)

where python3 >nul 2>nul
if %ERRORLEVEL%==0 (
  python3 nebula_loom.py %*
  goto :done
)

echo Python was not found on PATH.
echo Install Python from https://www.python.org/downloads/
echo and check "Add python.exe to PATH".
echo.
pause
exit /b 1

:done
if errorlevel 1 (
  echo.
  echo Something went wrong. Try:
  echo   py nebula_loom.py --web
  echo.
  pause
)
