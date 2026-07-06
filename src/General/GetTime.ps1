<#
This version adds dynamic daylight savings detection.
1.2 - 6/14/2017
added positional binding to localtime and an exmaple to show its use
1.3 - 8/3/2017
added Clipboard parameter to put output also in the clipboard
Cleaned up code a little bit.
#>
function Get-Time
{
<#
.Synopsis
   Gets the specified time in one more timezones
.DESCRIPTION
   Gets the specified time in one more timezones
.EXAMPLE
   The following will get the time in multiple timezones for 2pm local time.
   get-date -Hour 14 -Minute 0 | get-time
.EXAMPLE
   Get the time in the default list of timezones
   Get-Time
.EXAMPLE
   The following will get the time in multiple timezones for 2:30pm local time.
   get-date 2:30pm | get-time
.EXAMPLE
   The following will get the time in multiple timezones for 2:30pm local time.
   get-time 2:30pm
.EXAMPLE
   The following will get the time in multiple timezones for 2:30pm local time and
   weill also save the output to the clipboard.
   get-time 2:30pm -clipboard
.Parameter Timezone
    Specifiy one or more standard time zone identifiers. To see a list use:
    [TimeZoneInfo]::GetSystemTimeZones()
    Use the ID or StandardName property values.
.Parameter List
    Generates a list of timezones.
.Parameter Clipboard
    Will save output to the clipboard for quick pasting into another location.
#>
[cmdletbinding(DefaultParameterSetName='TimeZone')]
    param(
    [Parameter(ValueFromPipeline=$true,
                ParameterSetName='Timezone',
                Position=0
                )]
    [datetime]$LocalTime = (Get-date),
    [parameter(ParameterSetName='Timezone')]
    [string[]]$TimeZone,
    [parameter(ParameterSetName='Timezone')]
    [switch]$Clipboard,
    [Parameter(ParameterSetName='List')]
    [switch]$list)
    begin
    {
        if ($list)
        {
            return ([TimeZoneInfo]::GetSystemTimeZones())
            exit   
        }
    }
    process
    {
        if (!$list)
        {
        $localTimezone = [timezone]::CurrentTimeZone
        $daylight = $localTimezone.IsDaylightSavingTime(($LocalTime))
        if (-not $timezone)
        {
            $timezone ="Pacific Standard Time",
                    "Mountain Standard Time",
                    "Central Standard Time",
                    "Eastern Standard Time",
                    "UTC"    #>  
        }
        foreach ($Tzone in $timezone)
        {
            $time =   [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($Localtime,$tZone)
            $Tzinfo = [timezoneinfo]::FindSystemTimeZoneById($Tzone)
            $Tzinfo | Add-Member -MemberType NoteProperty -Name DaylightStatus -Value ($tzinfo.IsDaylightSavingTime($Localtime))  -Force
            $displayTime = $Time.ToShortTimeString()
            if ($tzinfo.DaylightStatus)
            {
                $Tzone = $tzinfo.DaylightName
            }
            $output= [pscustomobject]@{
                        TimeZone=$Tzone
                        Time = $displayTime
                     }
            if ($Clipboard)
            {
                [array]$clipboardResults += $output
            }
            $output
     }
     }
    } #end process   
    end
    {
        IF($Clipboard)
        {
            Write-Verbose "Writing output to the clipboard"
            $clipboardResults | Out-String | Set-Clipboard
        }
    }

}
