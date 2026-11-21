<#
.SYNOPSIS
    Clears only well-known safe temp patterns on a target (demo playbook).
.DESCRIPTION
    Intentionally conservative: reports what would be cleaned. Does not delete
    user profiles or arbitrary paths. Suitable as an allowlisted example.
.PARAMETER ComputerName
    Target computer name (example: app-03).
.PARAMETER MaxAgeHours
    Only consider files older than this many hours (default 72).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter()]
    [ValidateRange(1, 720)]
    [int]$MaxAgeHours = 72
)

$safeRoots = @(
    'C:\Windows\Temp'
    'C:\Temp'
)

return [pscustomobject]@{
    ComputerName = $ComputerName
    Action       = 'Clear-TempSafe'
    Scope        = $safeRoots
    MaxAgeHours  = $MaxAgeHours
    FilesRemoved = 0
    BytesFreed   = 0
    Mode         = 'ReportOnly'
    Message      = "Safe temp clear planned for $ComputerName (demo playbook)."
    Timestamp    = [datetime]::UtcNow
}
