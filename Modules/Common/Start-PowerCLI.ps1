# Purpose: Start-PowerCLI — Reusable PowerShell function libraries.
function Start-PowerCLI

{

    Push-Location

    & "${env:ProgramFiles(x86)}\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

    Pop-Location

}