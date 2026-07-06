# Purpose: Update-PSTeamsModule — Microsoft Teams lifecycle management.
Function Get-O365PSTeamsModule {
Install-Module PSTeams -Scope AllUsers -Force
Update-Module PSTeams -Scope AllUsers -Force
Connect-MicrosoftTeams -Credential $O365Cred
$SfbSession = New-CsOnlineSession -Credential $O365Cred
Import-PSSession $SfbSession
}