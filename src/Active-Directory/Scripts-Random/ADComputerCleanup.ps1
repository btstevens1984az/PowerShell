Function Get-OldServers
{
    param(
            [string]$filter = "operatingsystem -like '*Server*'",
            [ValidateScript({Get-ADObject -Identity $_})]
            [string]$SearchBase = ((Get-ADDomain).DistinguishedName),
            [int]$DaysStale = 365,
            [string]$ExclusionGroup
            )
            $oldcomps = Get-ADComputer -filter $filter -SearchBase $SearchBase -Properties operatingsystem,lastlogondate,memberof |
                Where-Object { $_.lastlogondate -lt ((Get-date).AddDays($DaysStale * -1) )}
            #filtering out computers from exclusionGroup
            if ($ExclusionGroup)
            {
                $group = Get-ADGroup -Identity $ExclusionGroup -ErrorAction Stop
                $oldcomps | Where-Object memberof -NotContains $group.DistinguishedName
            }
            else
            {
                $oldcomps
            }

}

function Cleanup-ADComputer
{
<#
.Synopsis
   This function assists with moving and disabling computers or undoing that process.
.DESCRIPTION
   This function assists with moving and disabling computers or undoing that process.
   Use -Enable to enable accounts and move them. When importing from a previous log from this
   command originalOU will bind to TargetOU.
.PARAMETER Computer
    AD computer object to modify
.PARAMETER TargetOU
    Idenity of target OU. This should be a distinguished name.
.PARAMETER LogType
    Valid values are xml and csv. You can specify both: csv,xml
.EXAMPLE
   Use Get-Oldservers to get a list of stale computers, filter with out-gridview and move and disable accounts.
    Get-OldServers | Sort-Object lastlogondate |
     Out-Gridview -PassThru | 
      Cleanup-ADComputer  -TargetOU "OU=StaleComputers,DC=kaylos,DC=lab" -Verbose -Disable -Logtype xml,csv
.EXAMPLE
   Undo moves and disables from a previous log from this command.
   Import-Clixml ADComputerMove03152017_100435.xml | 
        ogv -PassThru | Cleanup-ADComputer -Enable -Verbose
.EXAMPLE
    Undo using CSV log
    Import-Csv ADComputerMove03152017_103000.csv | ogv -PassThru | Cleanup-ADComputer -Enable -Verbose -logType csv,xml
#>
    [cmdletbinding(ConfirmImpact='High',SupportsShouldProcess=$true)]
    param(
            
            [parameter( Mandatory,
                        ValueFromPipeline=$true
                        )]
            $Computer,
            [parameter(
                        Mandatory,
                        ValueFromPipelineByPropertyName=$true
                        )]
            [Alias("OriginalOU")]
            [ValidateScript({Get-ADObject -Identity $_})]
            [string]$TargetOU,
            [string]$logpath = '.',
            [validatescript({$_ -contains "xml" -or $_ -contains "csv"})]
            [string[]]$logType = @("xml"),
            [parameter(Mandatory,ParameterSetName='Enable')]
            [switch]$Enable,
            [parameter(Mandatory,ParameterSetName='Disable')]
            [switch]$Disable
            )
        begin
        {
            $computerMoveLog = @()
        }

        process
        {
            foreach ($comp in $Computer)
            {
                if ($pscmdlet.ShouldProcess("$($comp.DistinguishedName)", "cleaning up and moving computer to $TargetOU"))
                {
                
                $movedComputer = $null
                $OriginalDN = $Comp.DistinguishedName
                Write-Verbose "Moving computer $OriginalDN to $TargetOU"
                $DNParts = $OriginalDN -split ','
                $OriginalOU = ($DNParts[1..($DNParts.count)]) -join ','
                if ($Enable)
                {
                    $comp = $Comp.DistinguishedName | Enable-ADAccount -PassThru
                }
                elseif($Disable)
                {
                    $comp = $Comp | Disable-ADAccount -PassThru
                }
                Write-Verbose "Moving $OriginalDN from $OriginalOU to $TargetOU"
                $movedComputer = $Comp | Move-ADObject -TargetPath $TargetOU -PassThru
                $movedComputer | Add-Member -Name OriginalDN -Value $OriginalDN -MemberType NoteProperty -Force 
                $movedComputer | Add-Member -Name OriginalOU -Value $OriginalOU -MemberType NoteProperty -Force
                $movedComputer | Add-Member -Name MovedDate -Value (get-date) -MemberType NoteProperty -Force
                $computerMoveLog += $movedComputer
                Write-Verbose "Finished moving $OriginalDN to $TargetOU"
                }
            }
            
        }
        end
        {
            $Datestring = get-date -f MMddyyyy_HHmmss
            try{
                switch ($logType)
                {
                    "xml" {$computerMoveLog|Export-Clixml -Path "$logpath\ADComputerMove$Datestring.xml" -ErrorAction Stop}
                    "csv" {$computerMoveLog|Export-Csv  -Path "$logpath\ADComputerMove$Datestring.csv" -ErrorAction Stop}
                }
            }
            catch [System.UnauthorizedAccessException],[System.Management.Automation.DriveNotFoundException],[System.IO.DirectoryNotFoundException]
                {
                    #Access denied to write log
                    $computerMoveLog | Out-GridView 
                    $path = Read-Host "Provide Alternate Log path"
                    if (Test-Path $path -ErrorAction Inquire)
                    {$computerMoveLog | Export-Clixml -Path "$path\ADComputerMove$Datestring.xml" -ErrorAction Inquire -Verbose}
                } 
            catch
            {
                Write-Error "Unhandled error during log write" -ErrorAction Inquire
            }
           }

}
#Get-OldServers | sort lastlogondate | ogv -PassThru | Cleanup-ADComputer  -TargetOU "OU=StaleComputers,DC=kaylos,DC=lab" -Verbose -Disable -logType xml,csv

#Import-Clixml ADComputerMove03152017_100435.xml | ogv -PassThru |Cleanup-ADComputer -Enable -Verbose
#Import-Csv ADComputerMove03152017_103000.csv | ogv -PassThru | Cleanup-ADComputer -Enable -Verbose -logType csv,xml