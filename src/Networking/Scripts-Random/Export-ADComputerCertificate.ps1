#Todo
#add smarter filtering for when there are more than one cert published
#Can filter by serialnumber
#Certificates.GetSerialNumberString()
#Add support for user certificates

Function Export-ADComputerCertificate{
<#
.Synopsis
   Exports certificates from AD
.DESCRIPTION
   Exports certificates (public keys) from AD
.Parameter Computername
    Computername of computer to export its certificate.
.Parameter Adcomputer
    Ad computer object to export certificate from.
.Parameter OutputPath
    Folder path to output .cer files 
.EXAMPLE
    (Get-adcomputer -filter *).name| export-ADComputerCertificate
    Exports certificates for all computers in AD with certificates published
.EXAMPLE
    export-adcomputercertificate -computername 25.59.161.56
    Export certificate for a single computer
    
#>
#Requires -version 3
#Requires -Modules ActiveDirectory
[cmdletbinding(DefaultParameterSetName="ComputerName")]
param (
[parameter(
    mandatory=$true,
    ValueFromPipelineByPropertyName=$true,
    ValueFromPipeline=$true,
    ParametersetName="ComputerName",
    Position=0
    )]
    [Alias("Name")]
    [string[]]$computerName,
    
    [parameter(
    mandatory=$true,
    ValueFromPipeline=$true,
    ParameterSetName = "ADComputer",
    Position=0)]
    [Microsoft.ActiveDirectory.Management.ADComputer]$adComputer,
    [string]$OutputPath="."
    )
process
    {
        If ($adcomputer)
        {
            $computername = $adcomputer.name
        }
        elseif(!$computername)
        {
            throw "Computername required"
        }
        foreach($computer in $computername)
        {
        Write-verbose "Querying AD for: $computer"
        $ADObj = (Get-ADComputer -Identity $computer -Properties certificates) 
            If($ADObj.certificates)
            {
            write-verbose "Certificates found in ad for: $computer"
            $certtoExport = $ADObj.certificates | Select-Object -First 1 #| Export-Certificate -FilePath "$OutputPath\$computer.cer"   
            Export-MyCertificate -certificate $certtoExport -FilePath "$OutputPath\$computer.cer" 
            Write-verbose "Certificate Exported for $computer to $(resolve-path $OutputPath\$computer.cer)"
            }
            else
            {
                Write-Verbose "No Certificates found for: $computer"
            }
        }
    }
}
Function Export-MyCertificate
{
    param($certificate,$FilePath)
    $bytes = $certificate.Export("Cert")
    [system.IO.file]::WriteAllBytes($FilePath, $bytes)
}

#"computername"| export-ADComputerCertificate -OutputPath C:\temp\temp
