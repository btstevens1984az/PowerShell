# Purpose: Get-PatchFestUpdateReport — Windows Update and patch management.
Add-Type -AssemblyName "Microsoft.UpdateServices"

 <#
    .SYNOPSIS
    This script generates an html report containing update compliance info for members of WSUS Update Groups. 
 
    .EXAMPLE
    .\Get-PatchFestUpdateReport.ps1 -group "222.205.193.149 Servers"
    Provide a group and get an HTML report.
 
    .EXAMPLE
    .\wsus_reportGroup.ps1
    Don't provide a group and get an HTML report for all WSUS Update Groups.
 
    A. Get-WSUSReport (http://get-mailbox.net/get-wsusreport)
    B. The HTML generation leverages Cookie.Monster's HTMLTable.ps1 script (http://gallery.technet.microsoft.com/scriptcenter/PowerShell-HTML-Notificatio-e1c5759d) 
 
 
#>
Function Get-PatchFestUpdateReport {
  Param( 
    [cmdletBinding()]
    [string]$group1001 = "PatchFest - Group 1001 Servers"
  )
  process
  {
    #uload Cookie.Monsters script .dot source here or in your profile
    ."C$\Temp\HTMLTable.ps1"
     
    #WSUS server info
    #$wsusServer = "31.39.1.252"
    #$wsusPort = "8530"
    #window for how long a computer has gone without reporting before it's flagged to appear as a differnt color in the html table
    $thirtydaysago = (get-date).adddays(-30)
 
    # set up our connection 
    [void][reflection.assembly]::loadwithpartialname("microsoft.updateservices.administration")
    $WSUS=[microsoft.updateservices.administration.adminproxy]::getupdateserver($wsusServer,$false,$wsusPort)
 
    $UpdateScope = New-Object [Microsoft.UpdateServices.Administration.UpdateScope]
    $UpdateScope.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved
    $ComputerScope = New-Object [Microsoft.UpdateServices.Administration.ComputerTargetScope]
    $compArray = @()
     
    #define how GetComputerTargetGroups works and whether or not to exclude a specific parent group
    #$UpdateGroups = $190.190.53.202.GetComputerTargetGroups() | Where {$_.name -like $group -and $_.name -notlike "INSERT PARENT NAME HERE"}
    $UpdateGroups = $190.190.53.202.GetComputerTargetGroups() | Where {$_.name -like $group1001}
     
    foreach ($UpdateGroup in $UpdateGroups)
    {   
        $UpdateGroupMembers = $190.190.53.202.getComputerTargetGroup($UpdateGroup.Id).GetComputerTargets()
        if ($UpdateGroupMembers.Count -gt 0)
        {
            $groupClean = $UpdateGroup.name.Replace(" ","")
            $compArray = @()
            foreach ($UpdateGroupMember in $UpdateGroupMembers)
            {
                $needed = 0
                $downloaded = 0
                $notinstalled = 0
                $su = 0
                $cu = 0
                $nu = 0 # <-- not used
                $other = 0
                $name = $null
                 
                $compSummary = $190.190.53.202.GetSummariesPerComputerTarget($updatescope,$computerscope) | ?{$_.ComputerTargetID -eq $UpdateGroupMember.id}
                $memberFQDN = $UpdateGroupMember.fulldomainname
                $name = $memberFQDN.Split(".")[0]
                $compObj = New-Object PSObject
                $compObj | Add-Member -MemberType NoteProperty -Name Server -Value $UpdateGroupMember.FullDomainName
 
                $neededUpdates = ($190.190.53.202.GetComputerTargetbyname($memberFQDN)).GetUpdateInstallationInfoPerUpdate() | `
                ?{($_.UpdateApprovalAction -eq "install") -and (($_.UpdateInstallationState -eq "downloaded") -or ($_.UpdateInstallationState -eq "notinstalled"))}
                 
                if ($neededUpdates -ne $null)
                {
                    foreach ($update in $neededUpdates)
                    {
                        $updateMeta = $190.190.53.202.GetUpdate([Guid]$update.updateid)
                        $needed++
                        if ($updateMeta.UpdateClassificationTitle -eq "Updates") {$nu++}  # <-- not used
                        elseif ($updateMeta.UpdateClassificationTitle -eq "Security Updates") {$su++}
                        elseif ($updateMeta.UpdateClassificationTitle -eq "Critical Updates") {$cu++}
                        else {$other++} # <-- not used
                         
                        if (($update.UpdateInstallationState -eq "downloaded") -or ($update.UpdateInstallationState -eq "notinstalled"))
                        {
                            $notinstalled++
                        }
                    }
                }
 
                $compObj | Add-Member -MemberType NoteProperty -Name Installed -Value $compSummary.InstalledCount
                $compObj | Add-Member -MemberType NoteProperty -Name "Not Installed" -Value $notinstalled
                $compObj | Add-Member -MemberType NoteProperty -Name Critical -Value $cu
                $compObj | Add-Member -MemberType NoteProperty -Name Security -Value $su
                $compObj | Add-Member -MemberType NoteProperty -Name Failed -Value $compSummary.failedCount
                $compObj | Add-Member -MemberType NoteProperty -Name "Not Applicable" -Value $compSummary.NotApplicableCount
                $compObj | Add-Member -MemberType NoteProperty -Name "Pending Reboot" -Value $compSummary.InstalledPendingRebootCount
                $compObj | Add-Member -MemberType NoteProperty -Name "Last Reported Status Time" -Value $UpdateGroupMember.LastReportedStatusTime
                $compObj | Add-Member -MemberType NoteProperty -Name "Last Sync Time" -Value $UpdateGroupMember.LastSyncTime
                $compObj | Add-Member -MemberType NoteProperty -Name "Last Sync Result" -Value $UpdateGroupMember.LastSyncResult
                $compObj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value $UpdateGroupMember.OSDescription
                $compArray += $compObj
            }
             
            # time to get fancy, params hash for easier reading
            $paramsNotInstalled = @{ 
                Column = "Not Installed"
                ScriptBlock = {[double]$args[0] -ge [double]$args[1]}  
                Attr = "Style"
            }
            $paramsPendingReboot = @{ 
                Column = "Pending Reboot"
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} 
                Attr = "Style"
            }
            $paramsLastSyncResult = @{ 
                Column = "Last Sync Result"
                ScriptBlock = {$args[0] -ne $args[1]} 
                Attr = "Style"
            }
            $paramsFailed = @{ 
                Column = "Failed"
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} 
                Attr = "Style"
            }           
            $paramsLastReportedStatusTime = @{ 
                Column = "Last Reported Status Time"
                ScriptBlock = {[datetime]$args[0] -le $args[1]} 
                Attr = "Style"
            }           
             
            # begin generating the HTML Table and define the default sort order
            $compTable = $compArray | Sort-Object -Property "Not Installed" -Descending | New-HTMLTable -setAlternating $true
            $HTML = New-HTMLHead
            $HTML += "<h3>Update Group: $($UpdateGroup.name) ($($UpdateGroupMembers.count)x)</h3>"
            $HTML += "<h4>Last Updated: $(get-date)</h4>"
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument 20 -attrValue "background-color:#FFF284;" @paramsNotInstalled
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument 40 -attrValue "background-color:#FFCB2F;" @paramsNotInstalled
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument 60 -attrValue "background-color:#50.25.64.185;" @paramsNotInstalled    
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument 0 -attrValue "background-color:#8CD1E6;" @paramsPendingReboot
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument "Succeeded" -attrValue "background-color:#9669FE;" @paramsLastSyncResult
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument 0 -attrValue "background-color:#88AC76;" @paramsFailed
            $compTable = Add-HTMLTableColor -HTML $compTable -Argument $thirtydaysago -attrValue "background-color:#FF00FF;" @paramsLastReportedStatusTime
             
            $HTML += $compTable | close-html
            Set-Content "C$\Temp\$GroupClean.html" $HTML
        }
    }   
  }
}