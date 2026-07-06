# Purpose: Get-CPULoadGraph — Reusable PowerShell function libraries.
############################################################################# 
# Date: 02/02/2018 
# Description: Draw a graph to see current CPU load with refresh rate
#############################################################################
 
# The initial start up takes about 5 seconds.  Afterward, the refresh rate is fast
# The pipe symbol '|' indicates user usage where the colon symbol ":" indicates OS usage
# Example: Get-CPULoadGraph -ComputerName 114.148.18.125
# Options are below
# Set-StrictMode -Version latest -Verbose 
# $ErrorActionPreference = 'Stop'

 
function Get-CPULoadGraph( [bool] $EnableColor=$false ) { 
    function GetCpuData() { 
        $aProcCntr = Get-WmiObject -Namespace "Root\CIMv2" -Computer 46.102.135.238 -Property 'Name,PercentUserTime,PercentProcessorTime,PercentProcessorUtility' -Class Win32_PerfFormattedData_Counters_ProcessorInformation 
        $regFilter = [regex] '_Total' 
        $iLen = $aProcCntr.Length 
        for ( $i=0; $i -lt $iLen; $i++ ) { 
            if ( $aProcCntr[$i].Name  -match $regFilter ) { 
                continue 
            } 
            $iMaxProcTime = [math]::max( $aProcCntr[$i].PercentProcessorTime, $aProcCntr[$i].PercentProcessorUtility ) 
            $iMaxUserTime = $aProcCntr[$i].PercentUserTime 
            if ( $iMaxUserTime -gt 100 ) { $iMaxUserTime = 100 } 
            if ( $iMaxProcTime -gt 100 ) { $iMaxProcTime = 100 } 
            if ( $iMaxUserTime -gt $iMaxProcTime ) { $iMaxProcTime = $iMaxUserTime }  # Once in a Blue Moon, user time exceeds CPU time. Perf count read timing issue? 
            ,@($aProcCntr[$i].Name,$iMaxProcTime,$iMaxUserTime) 
        } 
    } 
    function FormatCpuGraphData( $aCounter ) { 
        # Input: Array from GetCpuInfo function 
        # Shooting for 50 chars for graph tick marks, 61 chars for entire line. 
        $iNonUserTime = $aCounter[1]-$aCounter[2] 
        $iUserTicks = [int] [math]::Round(($aCounter[2]/2),[midpointrounding]::AwayFromZero) 
        $iNonUserTicks = [int] [math]::Round(($iNonUserTime/2),[midpointrounding]::AwayFromZero) 
        $iSpacePadding = $iUserTicks+$iNonUserTicks 
        if ( $iSpacePadding -gt 52 ) { $iSpacePadding = 0 }  # 50 char actual + 2 for rounding up on each tick var 
        ,@($aCounter[0]," [",('|'*$iUserTicks),(':'*$iNonUserTicks),(' '*(52-$iSpacePadding)),($aCounter[1].ToString("##0").PadLeft(3)+'%'),"]") 
    } 
    function WriteColor($aText, $aColors) { 
        $iLen = $aText.Length 
        for ( $i=0; $i -lt $iLen; $i++ ) { 
            Write-Host $aText[$i] -Foreground $aColors[$i] -NoNewLine 
        } 
        Write-Host 
    } 
    function WriteCpuGraph( [bool] $EnableColor=$false ) { 
        $aCpuInfo = GetCpuData 
        $aColors = @('Cyan','White','Green','Red','White','DarkGray','White') 
        Clear 
        foreach ( $aInfo in $aCpuInfo ) { 
            $aSingleGraph = FormatCpuGraphData $aInfo 
            if ( $EnableColor ) { 
                WriteColor $aSingleGraph $aColors 
            } else { 
                Write-Host ($aSingleGraph -join '') 
            } 
        } 
    } 
    while ($true) { 
        WriteCpuGraph $EnableColor 
        Sleep 1 
    } 
} 
