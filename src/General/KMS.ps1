# Purpose: KMS — General-purpose PowerShell utilities.
#******************************
#To do: 
#Add support for office 2010 (WMI officesoftwareprotectionproduct)
#Fix Activate Client so it can activate the client immediatley after installing the kms client key. Not really necessary as activation will be automatically attempted but it would be
#ideal to install key, activate, then verify activation
Function GetKMSPID
{
    param ([string]$OperatingSystem)
    switch -wildcard ($operatingSystem) 
    {
    "*Microsoft Windows Server 2008 R2 Enterprise*" {"489J6-VHDMP-X63PK-3K798-CPX3Y"}
    "*Microsoft Windows Server 2008 R2 Standard*" {"YC6KT-GKW9T-YTKYR-T4X34-R7VHC"}
    "*Microsoft Windows Web Server 2008 R2*" {"6TPJF-RBVHG-WBW2R-86QPH-6RTM4"}
    "*Microsoft� Windows Server� 2008 Enterprise*" {"YQGMW-MPWTJ-34KDK-48M3W-X4Q6V"}
    default {throw "no PID found"}
    }
}
Function ActivateClient
{
    Param($computer)
        #Start-Sleep 15
        $product = Get-WmiObject softwarelicensingproduct -ComputerName $computer -filter {licensestatus=1 and description like '%Windows Operating%'}
        $ActivationResult = $product.activate()    

}

Function MakeKMSClient
{
 param ($computer,$ProductKey)
        $WMIResult = (Get-WmiObject softwarelicensingservice -ComputerName $computer).installproductkey($ProductKey)
      
}


Add-PSSnapin Quest*
$KMSServer = 'PRVKMS001W'
$thirtyDaysAgo = (Get-date).adddays(-30)
$Computers = Get-QADComputer -OSName "*2008*" -includeallproperties |?{$_.lastlogontimestamp -gt $thirydaysago} |%{$_.name}
$computers.count
$results = @()
foreach ($computer in $computers)
{
    Try
    {
        $results += Get-WmiObject -class softwarelicensingservice -ComputerName $computer
    }
    Catch
    {
     Write-Error $computer
     $error | fl * -Force
     $error.clear()
    }
}

$ServerObjects = $results | Select-Object __server,ClientMachineID,DiscoveredKeyManagementServiceMachineNAme,IsKeyManagementServiceMachine,VLRenewalInterval,@{name='OSWMI';expression ={gwmi win32_operatingsystem -computer ($_.__server)}},`
@{name='SoftProduct';expression ={Get-WmiObject softwarelicensingproduct -computername ($_.__server) -filter {licensestatus=1}}} |
Select-object *,@{name="OS";Expression={$_.OSWMI.caption}},@{name="LicenseUsed";expression={if ($_.SoftProduct.description){$_.SoftProduct.description}}}
$ServerObjects=$ServerObjects | Select-object *,@{name="KMSClientKey";expression={GETKMSPID $_.OS}} 
$serverObjects | 
ForEach-Object {
 if (($_.__server) -eq $KMSServer)
 {
    write-host "found KMSServer: $KMSServer"
 }
 Elseif ($_.IsKeyManagementServiceMachine -eq 1 -or $_.licenseUsed -like "*Volume_MAK_*")
 {
    Write-host "Will Set Key on $($_.__Server) with $($_.KMSClientKey)"
    MakeKMSClient $_.__Server $_.KMSClientKey
    Write-host "$($_.__Server):Is now a KMS Client)"
 
 }
 Else
 {
    Write-host "This should be a KMSClient:$($_.__server):$($_.licenseused)"
 }

}
