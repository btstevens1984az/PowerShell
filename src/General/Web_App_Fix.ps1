# Purpose: Web App Fix — General-purpose PowerShell utilities.
<#
.SUMMARY
There's a common issue with Windows 10 where certain updates will set your restriction
level for web apps to DISABLED for ALL sources even though most of them are fine to be
trusted sources. The error that usually results from these settings is "Your administrator
has blocked this application because it potentially poses a security risk to your computer."
Runing the below script will fix this!
#>


$regPath = 'HKLM:\SOFTWARE\Microsoft\.NETFramework\Security\TrustManager\PromptingLevel'

If(!(Test-Path $regPath)) {
    New-Item $regPath -ItemType Directory | Out-Null
}


If(!((Get-ItemProperty $regPath -Name Internet -EA 0).Internet)) {
    New-ItemProperty $regPath -Name Internet -Value Enabled
} ElseIf (((Get-ItemProperty $regPath -Name Internet -EA 0).Internet) -ne 'Enabled') {
    Set-ItemProperty $regPath -Name Internet -Value Enabled
    Write-Output '!FAILED: Internet was not set to Enabled, value now set to Enabled'
} Else {
    Write-Output '!SUCCESS:'
}


If(!((Get-ItemProperty $regPath -Name LocalIntranet -EA 0).LocalIntranet)) {
    New-ItemProperty $regPath -Name LocalIntranet -Value Enabled
} ElseIf (((Get-ItemProperty $regPath -Name LocalIntranet -EA 0).LocalIntranet) -ne 'Enabled') {
    Set-ItemProperty $regPath -Name LocalIntranet -Value Enabled
    Write-Output '!FAILED: LocalIntranet was not set to Enabled, value now set to Enabled'
} Else {
    Write-Output '!SUCCESS:'
}


If(!((Get-ItemProperty $regPath -Name MyComputer -EA 0).MyComputer)) {
    New-ItemProperty $regPath -Name MyComputer -Value Enabled
} ElseIf (((Get-ItemProperty $regPath -Name MyComputer -EA 0).MyComputer) -ne 'Enabled') {
    Set-ItemProperty $regPath -Name MyComputer -Value Enabled
    Write-Output '!FAILED: MyComputer was not set to Enabled, value now set to Enabled'
} Else {
    Write-Output '!SUCCESS:'
}


If(!((Get-ItemProperty $regPath -Name TrustedSites -EA 0).TrustedSites)) {
    New-ItemProperty $regPath -Name TrustedSites -Value Enabled
} ElseIf (((Get-ItemProperty $regPath -Name TrustedSites -EA 0).TrustedSites) -ne 'Enabled') {
    Set-ItemProperty $regPath -Name TrustedSites -Value Enabled
    Write-Output '!FAILED: TrustedSites was not set to Enabled, value now set to Enabled'
} Else {
    Write-Output '!SUCCESS:'
}


If(!((Get-ItemProperty $regPath -Name UntrustedSites -EA 0).UntrustedSites)) {
    New-ItemProperty $regPath -Name UntrustedSites -Value Enabled
} ElseIf (((Get-ItemProperty $regPath -Name UntrustedSites -EA 0).UntrustedSites) -ne 'Disabled') {
    Set-ItemProperty $regPath -Name UntrustedSites -Value Disabled
    Write-Output '!FAILED: UntrustedSites was not set to Disabled, value now set to Disabled'
} Else {
    Write-Output '!SUCCESS:'
}