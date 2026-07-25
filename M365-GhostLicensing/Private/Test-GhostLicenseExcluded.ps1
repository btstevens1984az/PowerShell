function Test-GhostLicenseExcluded {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$User,

        [string[]]$ExcludeUpnPatterns,

        [string[]]$ExcludeDepartments
    )

    $config = Get-GhostLicensingConfigStore
    if (-not $ExcludeUpnPatterns) { $ExcludeUpnPatterns = $config.ExcludeUpnPatterns }
    if (-not $ExcludeDepartments) { $ExcludeDepartments = $config.ExcludeDepartments }

    foreach ($pattern in $ExcludeUpnPatterns) {
        if ($User.UserPrincipalName -like $pattern) {
            return $true
        }
    }

    if ($User.Department -and $ExcludeDepartments -contains $User.Department) {
        return $true
    }

    return $false
}
