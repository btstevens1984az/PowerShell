# Purpose: formatWithComma — Reusable PowerShell function libraries.
function formatWithComma {
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        # [String[]]$ComputerName
        [switch]$file 
    )
    $date = get-date -uFormat "%Y%m%d"
    $Output = "SELECT
   DISTINCT
   MACHINE.NAME MACHINE_NAME
FROM
   INV_MACHINE MACHINE
WHERE
   /* CommentHere $date */
   MACHINE.NAME IN ("
        
    $i = 0
    if ($file) {
        $ComputerName = Get-content .\comma.txt
    }
    else {
        $ComputerName = Get-Clipboard
    }

    foreach ($cn in $ComputerName) {
          
            
        $i++
            
        if ($i -gt 400) {
            $Output += "'$cn') `n  OR MACHINE.NAME IN("
            $i = 0
        }
        else {
            $Output += "'$cn',"
        }
            
    }
    $Output = $Output.Substring(0, $Output.Length - 1)
    $Output += ")"

    write-output $Output.ToLower() | clip

}
   