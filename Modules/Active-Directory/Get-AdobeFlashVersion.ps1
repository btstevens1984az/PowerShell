# Purpose: Get-AdobeFlashVersion — Active Directory user, group, and domain administration.
function Get-FlashVersion {
    [CmdletBinding()]
    param(
        [parameter(mandatory=$false,position=0,valuefrompipelinebypropertyname=$true)]$ComputerName=$env:ComputerName
    )
    begin {
    } process {
        if(Test-Connection $Computername -count 1 -ErrorAction SilentlyContinue) {
            $filename = "\\$ComputerName\c$\windows\system32\macromed\flash\flash*.ocx"
            if(Test-Path $filename) {
                $file = Get-Item $filename
                $version = $file.versionInfo.fileversion -replace ",","."
            } else {
                $version = "Not Installed"
            }
        } else {
            $Version = 'Offline'
        }
        New-Object -TypeName PSObject |
        Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName -PassThru |
        Add-Member -MemberType NoteProperty -Name 'FlashVersion' -Value $version -PassThru
    }
}