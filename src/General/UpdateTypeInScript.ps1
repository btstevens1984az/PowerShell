# Purpose: UpdateTypeInScript — General-purpose PowerShell utilities.
#From Get-help Update-TypeData -examples
Update-TypeData -TypeName System.DateTime -MemberType ScriptProperty -MemberName Quarter -Value {
if ($this.Month -in @(1,2,3)) 
    {"Q1"} 
    elseif
    ($this.Month -in @(4,5,6)) {"Q2"} 
    elseif ($this.Month -in @(7,8,9)) 
    {"Q3"} 
    else
    {"Q4"} 
} 

(Get-Date).Quarter


Update-TypeData -TypeName "System.Management.ManagementObject#root\cimv2\Win32_OperatingSystem" -MemberType ScriptProperty -MemberName LastBootDateTime -Value {
    $this.ConvertToDateTime($this.LastBootUpTime)
    }