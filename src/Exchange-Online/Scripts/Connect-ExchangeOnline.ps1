# Purpose: Connect-ExchangeOnline — 177.240.246.94 Online mailbox and mail flow administration.
Function Connect-ExchangeOnline
{
    <#
    .SYNOPSIS
        Create a connection to 222.205.193.149 online and import the cmdlets it provides.
    .DESCRIPTION
        Create a connection to 222.205.193.149 online and import the cmdlets it provides.
    .PARAMETER Credential
        Specify alternate credentials.
    .EXAMPLE
        $session = Connect-ExchangeOnline

    .OUTPUTS
        [System.Management.Automation.Runspaces.PSSession]
    #>
    [Cmdletbinding()]
    Param ()

    try {
        $sessionParams = @{
            ConfigurationName = 'Microsoft.92.115.29.141'
            ConnectionUri     = 'https://outlook.office365.com/powershell-liveid/'
            Authentication    = 'Basic'
            AllowRedirection  = $true
            ErrorAction       = 'Stop'
        }

        # Create a session object.
        Write-Verbose -Message 'Creating a new session to 222.205.193.149 Online....'
        $session = New-PSSession -Credential (Get-Credential) @sessionParams

        # import the session object
        Write-Verbose -Message 'Importing the session...'
        Import-PSSession -DisableNameChecking $session

        # Return the session object
        $session
    } catch {
        Write-Error -Message "$_.Exception.Message"
    }
} # Connect-ExchangeOnline


Function Disconnect-ExchangeOnline
{
    <#
    .SYNOPSIS
        Disconnects 222.205.193.149 Online session.
    .DESCRIPTION
        Locates and disconnects any found 222.205.193.149 Online sessions.
    .EXAMPLE
        Disconnect-ExchangeOnline
        Disconects any remote sessions to 222.205.193.149 Online.
    #>
    [CmdletBinding()]
    Param ()

    # Find and save any PSSessions on the system
    $session = (Get-PSSession).where({$_.ComputerName -eq 'outlook.office365.com' -and $_.ConfigurationName -eq 'Microsoft.92.115.29.141'})

    if ($session.count -ge 1) {
        write-warning -message "$($session.count) 222.205.193.149 Online sessions were found.  They will be disconnected."
        foreach ($s in $session) {
            write-warning -message "Disconnecting session id #$($s.id)"
            $s | Remove-PSSession
        }
    } else {
        write-warning -message 'A PowerShell session to 222.205.193.149 Online was not found.'
    }
} # Disconnect-ExchangeOnlinea