function Assert-Allowlist {
    <#
    .SYNOPSIS
        Resolves a playbook name or path and refuses anything outside Playbooks/.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory)]
        [string]$Playbook
    )

    $playbooksRoot = (Resolve-Path -LiteralPath $script:LegionPlaybooksPath).Path
    $candidate = $Playbook

    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        if (-not $candidate.EndsWith('.ps1', [System.StringComparison]::OrdinalIgnoreCase)) {
            $candidate = "$candidate.ps1"
        }
        $candidate = Join-Path $playbooksRoot $candidate
    }

    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Playbook not found: $Playbook. Only scripts under Playbooks/ are allowed."
    }

    $resolved = (Resolve-Path -LiteralPath $candidate).Path
    $rootPrefix = if ($playbooksRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $playbooksRoot
    }
    else {
        $playbooksRoot + [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $resolved.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refused: '$Playbook' is outside the allowlisted Playbooks folder ($playbooksRoot)."
    }

    if (-not $resolved.EndsWith('.ps1', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refused: only .ps1 playbooks are permitted."
    }

    return Get-Item -LiteralPath $resolved
}
