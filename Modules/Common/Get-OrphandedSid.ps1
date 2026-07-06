# Purpose: Get-OrphandedSid — Reusable PowerShell function libraries.

    <#
    .SYNOPSIS
    Checks the ACL's on all folders not inheriting permissions to determine if there are any
    unresolved SID's present and if so outputs a PSCustomObject for each one.

    .DESCRIPTION
    Checks the ACL's on all folders not inheriting permissions to determine if there are any
    unresolved SID's present and if so outputs a PSCustomObject for each one.

    .PARAMETER SearchPath
    The path to search for orphaned SIDs.

    .EXAMPLE
    Get-OrphandedSid -SearchPath c:\, d:\

    .INPUTS
    None.   Get-OrphandedSid does not accept objects from the pipeline.

    .OUTPUTS
    System.Mangament.Automation.PSCustomObject

    Raymond Jette
    #>
    
    [OutputType([System.Management.Automation.PSCustomObject])]
    [CmdletBinding()]
    param (
        # SearchPath
        [Parameter(Mandatory = $true, HelpMessage = 'The path to search for orphaned SIDs')]
        [ValidateNotNullOrEmpty()]
        [String[]]$SearchPath
    )

    BEGIN {
        
        Set-StrictMode -Version 2.0

        $GetChildItemParams = @{Recurse = $true; ErrorAction = 'SilentlyContinue'}
        $GetAclParams = @{ErrorAction = 'SilentlyContinue'; ErrorVariable = 'errGetAcl'}
    }

    PROCESS {

        foreach ($Path in $SearchPath) {

        if (-not ($Path -match "\w:\\" | Out-Null)) { $Path = "${Path}\" }

            try {

                if (Test-Path -Path $Path) {

                    foreach ($item in (Get-ChildItem -Path $Path @GetChildItemParams)) {

                        foreach ($ace in (($item | Get-ACL @GetAclParams).Access)) {
                        
                            if (-not $ace.IsInherited -and ($ace.IdentityReference.Value -match "s-1-5-*")) {

                                [PSCustomObject]@{
                                    Computer = $ENV:COMPUTERNAME
                                    Name = $item.FullName
                                    ACE = $ace.IdentityReference.Value
                                }
                            }
                        }
                    }
                } else { write-warning -message "Skipping $Path because it does not exist." }

            } catch { if (-not ($errGetAcl)) { write-error -message "$PSItem.Exception.Message"; $errGetAcl = $null }  }
        }
    }
}
#Get-OrphanedSid

