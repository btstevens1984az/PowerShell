# Purpose: Get-ProcessOwner — Windows desktop configuration and management.


function Get-ProcessOwner {
    &lt;#
        .SYNOPSIS
        Get the owner of a process.
        .DESCRIPTION
        Get the owner of a process via WMI.
        .PARAMETER ComputerName
        Gets the processes owner of processes running on the specified computers.
        The default is the local computer.
        .PARAMETER ProcessName
        Specifies one or more processes by process name.
        You can type multiple process names (separated by commas).
        .EXAMPLE
        PS C:\&gt; Get-Process -ComputerName 120.216.94.88 -Name notepad | Get-ProcessOwner
 
        ProcessName       UserName       Domain          ComputerName      handle
        -----------       --------       ------          ------------      ------
        notepad.exe       Jeff           MINIMONSTER     METHOS            2228
        .EXAMPLE
        PS C:\&gt;  Get-ProcessOwner 'notepad.exe' -ComputerName 210.252.220.118
 
        ProcessName       UserName       Domain          ComputerName      handle
        -----------       --------       ------          ------------      ------
        notepad.exe       Jeff           RDS01           METHOS            2228
        notepad.exe       Lars           RDS01           METHOS            3466
        notepad.exe       Angelique      RDS01           METHOS            8672
        .EXAMPLE
        PS C:\&gt;  Get-ProcessOwner 'notepad.exe' -ComputerName 210.252.220.118,MINIMONSTER
 
        ProcessName       UserName       Domain          ComputerName      handle
        -----------       --------       ------          ------------      ------
        notepad.exe       Jeff           RDS01           METHOS            2228
        notepad.exe       Lars           RDS01           METHOS            3466
        notepad.exe       Angelique      RDS01           METHOS            8672
        notepad.exe       Jeff           MINIMONSTER     METHOS            2228
        .NOTES
        Author: Jeff Wouters
    #&gt;
    [cmdletbinding()]
    param(
        [parameter(mandatory=$false,position=0,valuefrompipelinebypropertyname=$true)]$ComputerName=$env:COMPUTERNAME,
        [parameter(Mandatory=$true,position=1,valuefrompipelinebypropertyname=$true)]$ProcessName
    )
    begin {
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($(New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$('ProcessName','UserName','Domain','ComputerName','handle'))))
    } process {
        try {
            $Processes = Get-wmiobject -Class Win32_Process -ComputerName $ComputerName -Filter "name LIKE '$ProcessName%'"
        } catch {
            Write-Warning "Unable to query $ComputerName via WMI"
        }
        if ($Processes -ne $null) {
            foreach ($Process in $Processes) {
                $Process | 
                Add-Member -MemberType NoteProperty -Name 'Domain' -Value $($Process.getowner().domain) -PassThru |
                Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $ComputerName -PassThru |
                Add-Member -MemberType NoteProperty -Name 'UserName' -Value $($Process.getowner().user) -PassThru | 
                Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers -PassThru
            }
        } else {
            Write-Warning "No processes found that match the criteria on $ComputerName"
        }
    } end {
    }
}