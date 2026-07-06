# Purpose: Get-ProcessPercentages — Windows desktop configuration and management.
Function Get-ProcessPercentages {
        Param(
            [Parameter(ValueFromPipelineByPropertyName)]
            [Alias("device")]
            [string[]]$Computername
            )
    {
    $Total = Get-Counter -ComputerName $Computername '\Process(*)\Working Set' | 
    Select-Object -ExpandProperty countersamples | ? {$_.instancename -eq "_total"} | Select -ExpandProperty CookedValue

    Get-Counter $Computername '\Process(*)\Working Set' | 
    Select-Object -ExpandProperty countersamples | 
    Select-Object -Property instancename, cookedvalue | 
    Sort-Object -Property cookedvalue -Descending | Select-Object -First 5 |
     ft InstanceName,@{L='Memory';E={([System.Math]::Round($_.Cookedvalue / $total * 100).toString()) + " %"}}
    }
}