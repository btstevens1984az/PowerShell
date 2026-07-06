# Purpose: Get-Permissions — Reusable PowerShell function libraries.
Function Get-Permissions ()
{

        <#
                    .SYNOPSIS
                    .DESCRIPTION
                    .PARAMETER SourcePath 
                        Full Path to the folder where files you want to see the permissions
                    .EXAMPLE
                        Get-Permission -SourcePath $SourcePath 
                             Create DATE  : 04.27.2018
                      Last Modified DATE  : 04.27.2018
                      # Set-ExecutionPolicy bypass -Scope Process
        #>


        [CmdletBinding( DefaultParameterSetName="SourcePath", SupportsShouldProcess=$True, ConfirmImpact='Low')]
        PARAM(
                [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Position=0)]
                [ValidateNotNullOrEmpty()]
                [ValidateScript({Test-Path -PathType container -Path $_})]
                [STRING[]]$SourcePath
            )
        begin 
    {
            #############################################################################################
            ########=~ Script configuration Starts Here ~=###############################################
            $ErrorActionPreference = "Stop"
            $DebugPreference = 'Continue'
            $Path = $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })
            $scriptPath = Split-Path -Path $Path
            Set-Location $scriptPath
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $OutputType = 0 # 0 will output to Screen; 1 will output to Log File (sendlog function)
            ########=~ Script configuration Ends here ~=#################################################
            #############################################################################################> 
            If($OutputType -eq 0)
            {
                Write-Host -F Green "*** Script Start -  - Full Script Path: $path ***"
                Write-Host -f Green "SourcePath: $SourcePath "
            }

            # 10..20 | % {New-Item -Name SQLServerTrace$_.trc -ItemType File}
        } # End Begin
        process 
    {
          try{

          (get-acl $SourcePath).access | Select-Object `
            @{Label="FilePath";Expression={$SourcePath}}, `
                @{Label="Identity";Expression={$_.IdentityReference}}, `
                @{Label="Right";Expression={$_.FileSystemRights}}, `
                @{Label="Access";Expression={$_.AccessControlType}}, `
                @{Label="Inherited";Expression={$_.IsInherited}}, `
                @{Label="Inheritance Flags";Expression={$_.InheritanceFlags}}, `
                @{Label="Propagation Flags";Expression={$_.PropagationFlags}}  | out-file .\folderPermission.txt

            Get-Content .\folderPermission.txt

             }# End try
     Catch
            {
                $scriptName = $_.InvocationInfo.ScriptName
                $e = $_.Exception
                $line = $_.InvocationInfo.ScriptLineNumber
                $msg = $e.Message 
                Write-Host -ForegroundColor Red "The Script : $scriptName"
                Write-Host -ForegroundColor Red "caught exception: $e at $line"
                Write-Host -ForegroundColor Red "at line number: $line"
                Write-Host -ForegroundColor Red "error message is : $msg"
                Breaki

            } # End Catch
         finally
            { Write-Host -F Green "***** Script Complete - Time to complete: $($stopwatch.Elapsed) *****"}
        }# End Process  
} # End Function

# NVR WebSite Folder ############################
#$SourcePath = "\\93.180.251.104\C200\C280\284\NVR\"
#$SourcePath = "C:\Users\$env:USERNAME\Downloads\"
#Get-Permissions -SourcePath $SourcePath  
##########################################>