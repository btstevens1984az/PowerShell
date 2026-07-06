# Purpose: pscustomobject — General-purpose PowerShell utilities.
$computers = "syddc01","localhost"
$objs = foreach ($comp in  $computers)
{
    $hash = @{
                somekey = (Get-WmiObject -ComputerName $comp -Class Win32_operatingsystem).caption
                computername = $comp
             }

    #[pscustomobject] $hash
    #or
    New-Object -TypeName PSObject -Property $hash
}

$computers = "vmhost4","vmhost5","localhost","kms","dc4","win7test"


$objs = foreach ($comp in  $computers)
{

    $OS = Get-WmiObject -Class win32_operatingsystem -ComputerName $comp
    $computerInfo = Get-WmiObject -Class win32_computersystem -ComputerName $comp
    $hash = [ordered]@{
                        computername = $os.__server
                        OS = $OS.Caption
                        ServicePack = $os.ServicePackMajorVersion
                        Manufacturer = $computerInfo.Manufacturer
                        Model = $computerInfo.Model
                        Domain = $computerInfo.Domain
                    }

    #[pscustomobject] $hash
    #or
    New-Object -TypeName PSObject -Property $hash
}
$objs | FT -AutoSize