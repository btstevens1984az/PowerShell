# Purpose: testconnection — General-purpose PowerShell utilities.
$computers = "kms","bogus","238.26.219.211","dc2","vmhost4"
$Unresolved = @()
$ConnectionFailure = @()
$unknownError = @()
foreach ($comp in $computers)
{
    $myerr = $null
    Test-Connection -ComputerName $comp -Count 1 -ErrorAction SilentlyContinue -ErrorVariable myerr
    if ($myerr)
    {
        if($myerr)
        {
            if($myerr.exception.InnerException.NativeErrorCode -eq 11010)
            {
                $ConnectionFailure += $comp
                throw $myerr
            }
            elseif($myerr.exception.InnerException.NativeErrorCode -eq 11001)
            {
                $Unresolved += $comp
            }
            else
            {
                $unknownError += $comp
                $unknownerror += $myerr
            }
        }
    }
}

$ConnectionFailure > .\connectionfail.txt
$Unresolved > .\unresolved.txt

$error | Export-Clixml .\errors.xml
