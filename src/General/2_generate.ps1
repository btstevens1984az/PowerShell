# Purpose: 2 generate — General-purpose PowerShell utilities.
Import-Module ActiveDirectory
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.

#REPORT TO EXPORT

function Get-DeviceStateTotals
	{
		
		#///////////////////////////////////////////////////
		#Device Breakdown
		#///////////////////////////////////////////////////
        
        
        
		[int]$Missing = ($CSV_Device | Where-Object { $_.AP_count_error -ne 0 } | Measure-Object | Select-Object -Property Count).count
		[int]$FullyPatched = ($CSV_Device | Where-Object {$_.AP_count_error -eq 0 } | Measure-Object | Select-Object -Property Count).count
        [int]$Awaiting_reboot = ($CSV_Device | Where-Object {$_.STATUS -eq "Reboot Pending"} | measure-object).Count
        [int]$Reboot_Complete = $FullyPatched - $Awaiting_reboot 
        

		[int]$TotalPatch = ($Missing + $FullyPatched )
        [psobject[]]$stat_list = @()
        
        $stat_Full = @{
                        'State' = "FullyPatch";
                        'Count' =   ("{0:N0}" -f $FullyPatched);
                        'Percent' = ("{0:P2}" -f ($FullyPatched / $TotalPatch))

                       }
        $stat_full_Complete = @{
                                'State' =  "    Reboots Complete "
                                'Count' = ("{0:N0}" -f $Reboot_Complete );
                                'Percent' = ("{0:P2}" -f ($Reboot_Complete / $TotalPatch))
                                
                             }
        $stat_full_Waiting = @{
                                'State' =  "    Awaiting Reboot "
                                'Count' = ("{0:N0}" -f $Awaiting_reboot );
                                'Percent' = ("{0:P2}" -f ($Awaiting_reboot / $TotalPatch))
                                
                             }
        $stat_missing = @{
                            'State' = "Missing";
                            'Count' = ("{0:N0}" -f  $Missing);
                            'Percent' = ("{0:P2}" -f ($Missing / $TotalPatch))
                         }
        $stat_Total = @{
                            'State' = "Total";
                            'Count' = ("{0:N0}" -f $TotalPatch);
                            'Percent' = ""
                         }
        $stat_list=$stat_full,$stat_full_Complete, $stat_full_Waiting,$stat_missing,$stat_total
        foreach($stat in $stat_list)
            {
                new-object -TypeName psobject -Property $stat
            } 
}

#Get-StateTotals | select -Property state,count,percent

function Get-DeviceMissingStatTotals
    {
        [int]$REBOOT = ($CSV_Device | Where-Object { $_.count_rpen -gt 0 -and $_.AP_count_error -gt 0 } | Measure-Object | Select-Object -Property Count).count
        [int]$NOT_PATCH = ($CSV_Device | Where-Object { $_.AP_count_error -gt 0 -and $_.count_rpen -eq 0 } | Measure-Object | Select-Object -Property Count).count
        [int]$total = ($REBOOT + $NOT_PATCH)
        [psobject]$stat_list=@()

            $stat_reboot = @{
                            'State' = "Reboot Pending";
                            'Count' = ("{0:N0}" -f $REBOOT);
                            'Percent' = ("{0:P2}" -f ($REBOOT/$total))
                            }
            $stat_NOTPATCH = @{
                            'State' = "Failed";
                            'Count' = ("{0:N0}" -f $NOT_PATCH);
                            'Percent' = ("{0:P2}" -f ($NOT_PATCH/$total))
                            }
            $stat_list=$stat_reboot,$stat_NOTPATCH
            Foreach($stat in $stat_list)
            {
                 new-object -TypeName psobject -Property $stat
            }

    }

#Get-MissingStatTotals | Select-Object state,count,percent

function Get-FullyPatchTotals
    {
        $Workstations = $CSV_Device | Where-object {$_.AP_count_error -eq '0' } | Select-Object -Property wLastBootUptime,Status
        [int]$ZeroSeven=0
        [int]$EightFourteen=0
        [int]$Fifteen_Thirty=0
        [int]$ThirtyOne_Ninety=0
        [int]$NinetyOne_OneEighty=0
        [int]$ThreeSixZero=0
        [int]$total=0
        [DateTime]$TodayDates=Get-Date

        foreach($workstation in $Workstations)
            {
                [DateTime]$lastboot = $workstation.WlastBootUptime
                #Write-output $lastboot
                #Write-output $TodayDates.adddays(7)
                #exit
                Switch ($TodayDates)
                    {
                        {($_.addDays(-8)   -lt $lastboot)}{$ZeroSeven+=1;Break;}                                          
                        {($_.addDays(-15)  -lt $lastboot)}{$EightFourteen+=1;Break;}            
                        {($_.addDays(-31)  -lt $lastboot)}{$Fifteen_Thirty+=1;Break;}            
                        {($_.addDays(-91)  -lt $lastboot)}{$ThirtyOne_Ninety+=1;Break;}            
                        {($_.addDays(-181) -lt $lastboot)}{$NinetyOne_OneEighty+=1;Break;}            
                        {($_.addDays(-361) -lt $lastboot)}{$ThreeSixZero+=1;Break;}            
                     }
                $total+=1
            }
            $stat_Zero       = @{ 'Days'  =  "0-7"    ; 'Totals'  = ("{0:N0}" -f $ZeroSeven)           ; 'Percent' = ("{0:P2}" -f ($ZeroSeven/$total)) }
            $stat_fourteen   = @{ 'Days'  =  "8-14"   ; 'Totals'  = ("{0:N0}" -f $EightFourteen)       ; 'Percent' = ("{0:P2}" -f ($eightFourteen/$total)) }
            $stat_thirty     = @{ 'Days'  =  "15-30"  ; 'Totals'  = ("{0:N0}" -f $Fifteen_Thirty)      ; 'Percent' = ("{0:P2}" -f ($Fifteen_Thirty/$total)) }
            $stat_ninety     = @{ 'Days'  =  "31-90"  ; 'Totals'  = ("{0:N0}" -f $ThirtyOne_Ninety)    ; 'Percent' = ("{0:P2}" -f ($ThirtyOne_Ninety/$total)) }
            $stat_oneeighty  = @{ 'Days'  =  "90-180" ; 'Totals'  = ("{0:N0}" -f $NinetyOne_OneEighty) ; 'Percent' = ("{0:P2}" -f ($NinetyOne_OneEighty/$total)) }
            $stat_threesixty = @{ 'Days'  =  "360+"   ; 'Totals'  = ("{0:N0}" -f $ThreeSixZero)        ; 'Percent' = ("{0:P2}" -f ($ThreeSixZero/$total)) }
            [psobject]$stat_list=@()
            $stat_list = $stat_Zero,$stat_fourteen,$stat_thirty,$stat_ninety,$stat_oneeighty,$stat_threesixty
              Foreach($stat in $stat_list)
            {
                 new-object -TypeName psobject -Property $stat
            }
    }
#Get-FullyPatchTotals 

#NOW PATCH BREAKDOWN.
function Get-PatchStatTotals
    {
        [int]$installed = 0
        [int]$rebootPending = 0
        [int]$missing   = 0
        [int]$total     = 0
        foreach ($device in $CSV_Device)
            {
               
                $rebootPending += $device.count_rpen
                $installed     += $device.AP_count_ok
                $missing       += $device.AP_count_error
                
                
            }

        $total = ($installed + $missing)  
        $stat_installed = @{'State' = "Installed" ; 'Count' = ("{0:N0}" -f $installed) ; 'Percent' = ("{0:P2}" -f ($installed/$total))}
        $stat_rebootCM = @{'State' = "    Reboots Complete" ; 'Count' = ("{0:N0}" -f ( $installed - $rebootPending ) ) ; 'Percent' = ("{0:P2}" -f (( $installed - $rebootPending )/$total))}
        $stat_reboot = @{'State' = "    Awaiting Reboot" ; 'Count' = ("{0:N0}" -f $rebootPending) ; 'Percent' = ("{0:P2}" -f ($rebootpending  / $total ) )}
        $stat_missing   = @{'State' = "Missing"   ; 'Count' = ("{0:N0}" -f $missing)   ; 'Percent' = ("{0:P2}" -f ($missing/$total))}
        $stat_total     = @{'State' = "Total"     ; 'Count' = ("{0:N0}" -f $total)     ; 'Percent' = ""}
        [psobject]$stat_list=@()
        $stat_list = $stat_installed, $stat_rebootCM, $stat_reboot, $stat_missing,$stat_total
        Foreach($stat in $stat_list)
            {
                    new-object -TypeName psobject -Property $stat
            }
        
    }
#Get-PatchStatTotals

function Get-MissingStatTotals
    {
        [int]$reboot_pending = 0
        [int]$failed         = 0
        [int]$total          = 0
        $newDeviceList = $CSV_Device | Where-object {$_.compliance_status -eq 'Not Compliant' }
        foreach ($device in $newDeviceList)
            {
                if ($device.count_rpen -gt 0)
                    {
                        $reboot_pending += $device.AP_count_error

                    }
                else
                    {
                        $failed += $device.AP_count_error
                    }
  
                
            }
        $total = ($reboot_pending + $failed)
        $stat_reboot         = @{'State' = "Reboot-Pending" ; 'Count' = ("{0:N0}" -f $reboot_pending) ; 'Percent' = ("{0:P2}" -f ($reboot_pending/$total))}
        $stat_failed         = @{'State' = "Failed"         ; 'Count' = ("{0:N0}" -f $failed)         ; 'Percent' = ("{0:P2}" -f ($failed/$total))}
        [psobject]$stat_list = @()

        $stat_list = $stat_reboot,$stat_failed
        Foreach($stat in $stat_list)
            {
                    new-object -TypeName psobject -Property $stat
            }


    }
#Get-MissingStatTotals

function Get-MissingTotals
    {
        $Workstations = $CSV_Device | Where-object {$_.status -ne 'Patched' } 
        [int]$ZeroSeven=0
        [int]$EightFourteen=0
        [int]$Fifteen_Thirty=0
        [int]$ThirtyOne_Ninety=0
        [int]$NinetyOne_OneEighty=0
        [int]$ThreeSixZero=0
        [int]$total=0
        [int]$missing=0
        [DateTime]$TodayDates=Get-Date

        foreach($workstation in $Workstations)
            {
                [DateTime]$lastboot = $workstation.WlastBootUptime
                [int]$err_count = $workstation.AP_count_error
                
                Switch ($TodayDates)
                    {
                        {($_.addDays(-8)   -lt $lastboot)}{$ZeroSeven+=$err_count;Break;}                                          
                        {($_.addDays(-15)  -lt $lastboot)}{$EightFourteen+=$err_count;Break;}            
                        {($_.addDays(-31)  -lt $lastboot)}{$Fifteen_Thirty+=$err_count;Break;}            
                        {($_.addDays(-91)  -lt $lastboot)}{$ThirtyOne_Ninety+=$err_count;Break;}            
                        {($_.addDays(-181) -lt $lastboot)}{$NinetyOne_OneEighty+=$err_count;Break;}            
                        {($_.addDays(-361) -lt $lastboot)}{$ThreeSixZero+=$err_count;Break;}            
                     }
               
            }
            
            
            $total = ($ZeroSeven + $EightFourteen + $Fifteen_Thirty + $ThirtyOne_Ninety + $NinetyOne_OneEighty + $ThreeSixZero)

            $stat_Zero       = @{ 'Days'  =  "0-7"    ; 'Totals'  = ("{0:N0}" -f $ZeroSeven)           ; 'Percent' = ("{0:P2}" -f ($ZeroSeven/$total)) }
            $stat_fourteen   = @{ 'Days'  =  "8-14"   ; 'Totals'  = ("{0:N0}" -f $EightFourteen)       ; 'Percent' = ("{0:P2}" -f ($eightFourteen/$total)) }
            $stat_thirty     = @{ 'Days'  =  "15-30"  ; 'Totals'  = ("{0:N0}" -f $Fifteen_Thirty)      ; 'Percent' = ("{0:P2}" -f ($Fifteen_Thirty/$total)) }
            $stat_ninety     = @{ 'Days'  =  "31-90"  ; 'Totals'  = ("{0:N0}" -f $ThirtyOne_Ninety)    ; 'Percent' = ("{0:P2}" -f ($ThirtyOne_Ninety/$total)) }
            $stat_oneeighty  = @{ 'Days'  =  "90-180" ; 'Totals'  = ("{0:N0}" -f $NinetyOne_OneEighty) ; 'Percent' = ("{0:P2}" -f ($NinetyOne_OneEighty/$total)) }
            $stat_threesixty = @{ 'Days'  =  "360+"   ; 'Totals'  = ("{0:N0}" -f $ThreeSixZero)        ; 'Percent' = ("{0:P2}" -f ($ThreeSixZero/$total)) }

            [psobject]$stat_list=@()
            $stat_list = $stat_Zero,$stat_fourteen,$stat_thirty,$stat_ninety,$stat_oneeighty,$stat_threesixty
              Foreach($stat in $stat_list)
            {
                 new-object -TypeName psobject -Property $stat
            }
    }

#Get-MissingTotals

function New-HTMLPatchReport
    {
        <#
        .SYNOPSIS
        .PARAMETER
        .EXAMPLE
        #>
        
        Param
            (
                #[ValidateSet("ALL","CRH","SJR","SJP","MGC")]
                [string] $area="ALL"
            )
        
        
        Begin
            {
               $todayDate = (Get-date).tostring("MMddyyyy")
               $CSVFILE = $ScriptPath + "\CSV\Device_patch_status.csv "

               if($area -ne "ALL")
                {
                    write-output  "Generating report for $area"
                    $FilePath=("{0}\Reports\{1}_Report_{2}.html" -f $scriptpath,$area,$todayDate)
                    write-output $FilePath
                    $pg = (Get-ADGroup ("HPCA_{0}_PATCH" -f $area )).DistinguishedName | Get-ADGroupMember | foreach-object { $_.Name } 
                    #Updating the data to only retrieve info for certain area. 
                    $CSV_Device = Import-Csv $CSVFILE | where-object {$pg -contains $_.device }
                

                }
            else
                {
                    $CSV_Device = Import-Csv $CSVFILE
                    $FilePath=("{0}\Reports\Ent_Report_{1}.html" -f $scriptpath,$todayDate)
                }
              
            }
        Process
            {
                $style = @"
<style>
body {color:#333333;font-family:Calibri,Tahoma;font-size:10pt;}

h1 {text-align:center;}

h2 {border-top:1px solid #66666;}

th {font-weight:bold;color:#000000;background-color:#eeeeee;}

td {padding: 1px 10px 1px 10px}

</style>
"@
        # Device Breakdown
        $html_Stat_total      = Get-DeviceStateTotals   | Select-object state,count,percent | ConvertTo-html -Fragment -precontent "<h2>State Totals</h2>"
        $html_stat_missing    = DeviceMissingStatTotals | Select-Object state,count,percent | ConvertTo-Html -Fragment -precontent "<h2>Missing State Totals</h2>"
        $html_stat_FullyPatch = Get-FullyPatchTotals    | Select-Object Days,Totals,Percent | ConvertTo-Html -Fragment -precontent "<h2>Fully Patched Totals</h2>"

        #Patch Breakdown
        #Get-MissingStatTotals | Get-MissingStatTotals |Get-MissingTotals
        $html_stat_PatchStatTotals   = Get-PatchStatTotals    | Select-Object state,count,percent | ConvertTo-html -Fragment -precontent "<h2>State Totals</h2>"
        $html_stat_MissingStatTotals = Get-MissingStatTotals  | Select-Object state,count,percent | ConvertTo-Html -Fragment -PreContent "<h2>Missing State Totals</h2>"
        $html_stat_MissingTotals     = Get-MissingTotals      | Select-object Days,Totals,Percent | ConvertTo-Html -Fragment -PreContent "<h2>Missing Totals</h2>"
        #Creating Report
        $content = "<h3>$(get-date) </br> Site : $area</h3>" +'<table style="width: 100%"><tr>'
        $content += "<td><h1>Device Breakdown</h1> $html_stat_total <br> $html_stat_missing <br> $html_stat_fullypatch </td>" 
        $content += "<td> <h1>Patch Breakdown</h1>$html_stat_patchstattotals <br> $html_stat_missingStatTotals <br> $html_stat_MissingTotals <td>"
        $content += "</tr></table>"
        
        $params =@{'title'       = "Patch Report";
                   'head'        = "<title>Patch Report $area</title>$style";
                   'PostContent' = $content
                   }
        
                ConvertTo-Html @params  | Out-File $filePath

            }
        End
            {
               
            }

    }
   #loading Lib
   #. c:\lib\library.ps1


   New-HTMLPatchReport
   New-HTMLPatchReport -area MGMC
   New-HTMLPatchReport -area CRH
   New-HTMLPatchReport -area SJP
   New-HTMLPatchReport -area SJR
   New-HTMLPatchReport -area MH
   New-HTMLPatchReport -area MMCR
   New-HTMLPatchReport -area SECH
   New-HTMLPatchReport -area SRS
   New-HTMLPatchReport -area SRD
   New-HTMLPatchReport -area SRM
   New-HTMLPatchReport -area SJMC
   New-HTMLPatchReport -area AGCH
   New-HTMLPatchReport -area COR
   New-HTMLPatchReport -area MTC
   New-HTMLPatchReport -area CHWMF
   New-HTMLPatchReport -area FHMC
   New-HTMLPatchReport -area MMC
   New-HTMLPatchReport -area MFH
   New-HTMLPatchReport -area MHB
   New-HTMLPatchReport -area MSH
   New-HTMLPatchReport -area MSJH
   New-HTMLPatchReport -area CHMC
   New-HTMLPatchReport -area CHSB
   New-HTMLPatchReport -area MGH
   New-HTMLPatchReport -area RORC
   New-HTMLPatchReport -area SBMC
   New-HTMLPatchReport -area WHC
   New-HTMLPatchReport -area SJH
   New-HTMLPatchReport -area BMH
   New-HTMLPatchReport -area COP
   New-HTMLPatchReport -area DSC
   New-HTMLPatchReport -area GMH
   New-HTMLPatchReport -area MCM
   New-HTMLPatchReport -area NHC
   New-HTMLPatchReport -area SFH
   New-HTMLPatchReport -area SEQ
   New-HTMLPatchReport -area SMS
   New-HTMLPatchReport -area SML
   New-HTMLPatchReport -area PCI



