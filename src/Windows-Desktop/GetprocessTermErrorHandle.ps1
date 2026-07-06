# Purpose: GetprocessTermErrorHandle — Windows desktop configuration and management.
$badcomps=@()
#$VerbosePreference = "continue"
#$computers = $UpComputers
$computers = "kms","bogus2","dc2","bogus3","vmhost5"
Foreach ($computer in $Computers)
{
try{
    Get-Process -Name lsass -ComputerName $computer
    #"I won't get here if an error"
}
catch [System.InvalidOperationException]
{
    Write-Warning "Failed on $computer"
    $badcomps += $computer
    #"invalid op:$computer"
}
catch
{
    Write-Warning "Unexpected Error"
    Write-Warning $_.exception.gettype().FullName
    throw $_
}

finally
{
    #"finally"
    Write-Verbose "finally"

}
}
"Computers that encountered errors:"
$badcomps