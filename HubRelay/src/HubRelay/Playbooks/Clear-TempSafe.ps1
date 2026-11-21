<#
.SYNOPSIS
    Safely clears known-safe temporary scratch paths on a fictional target.
.DESCRIPTION
    Allowlisted HubRelay playbook. Operates only on explicitly provided
    scratch directories under /tmp/hubrelay-scratch (never user home paths).
    In simulation/dry-run the playbook reports intent without deleting.
.PARAMETER Target
    Fictional host name (e.g. relay-alpha). Used for labeling only unless
    a local scratch folder for that target exists.
.PARAMETER ScratchRoot
    Root scratch directory. Defaults to /tmp/hubrelay-scratch.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $Target,

    [string] $ScratchRoot = '/tmp/hubrelay-scratch'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Reject path traversal and home-directory targets
if ($Target -match '[\\/]' -or $Target -match '\.\.') {
    throw "Invalid target name. Use a simple fictional hostname (e.g. relay-alpha)."
}

$safeRoot = [System.IO.Path]::GetFullPath($ScratchRoot)
$allowedRoot = [System.IO.Path]::GetFullPath('/tmp/hubrelay-scratch')
if (-not $safeRoot.StartsWith($allowedRoot, [StringComparison]::Ordinal)) {
    throw "ScratchRoot must be under /tmp/hubrelay-scratch"
}

$targetDir = Join-Path $safeRoot $Target
$cleared = @()
$skipped = @()

if (-not (Test-Path -LiteralPath $targetDir)) {
    return [pscustomobject]@{
        Target  = $Target
        Action  = 'Clear-TempSafe'
        Cleared = @()
        Skipped = @('no-scratch-folder')
        Message = "No scratch folder for $Target under hubrelay-scratch (nothing to do)."
    }
}

Get-ChildItem -LiteralPath $targetDir -File -ErrorAction SilentlyContinue | ForEach-Object {
    # Only delete *.tmp and *.log scratch artifacts
    if ($_.Extension -in @('.tmp', '.log')) {
        if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove scratch file')) {
            Remove-Item -LiteralPath $_.FullName -Force
            $cleared += $_.Name
        }
    }
    else {
        $skipped += $_.Name
    }
}

return [pscustomobject]@{
    Target  = $Target
    Action  = 'Clear-TempSafe'
    Cleared = $cleared
    Skipped = $skipped
    Message = "Cleared $($cleared.Count) scratch file(s) for $Target."
}
