#TODO: Fix null checking for groups that match filter
<#
.SYNOPSIS
This command retrieves group membership from local and remote computers
.DESCRIPTION
This command retrieves group membership from local and remote computers.
.PARAMETER ComputerName
One or more computers to retrieve group membership from
.PARAMETER FilterMembers
Group members you want to filter out (i.e. Administrator) from the results.
.PARAMETER Group
One or more groups you want to get the membership of. Default is administrators.
.PARAMETER Delimiter
What delimiter you want to use to seperate members in output.
.PARAMETER LogFailures
Switch parameter when on will create a text file of computers that were not able to be reached.
.PARAMETER LogPathforFailedComputers
Specify output file to work with LogFailures. Defaults to current directory Failedcomputers.txt
.EXAMPLE
PS C:\> get-LocalGroupMembers -FilterMembers "administrator","domain Admins","testsql"
Gets the members of the local computers administrators group but filters out the listed members.
.EXAMPLE
PS C:\> get-LocalGroupMembers
Gets the local admin users.
.EXAMPLE
PS C:\> $computers | get-LocalGroupMembers -group Administrators,"Power Users"
Gets the group membership of administrators and power users for the piped computer names.
.EXAMPLE
PS C:\> $computers | get-LocalGroupMembers -group Administrators,"Power Users" -computers $computers -logFailures
Gets the group membership of administrators and power users for the piped computer names. LogFailusers will log failed computer names
in a txt file specified by LogPathForfailedComputers parameter which defaults to failedcomputers in the current directory.
NAME        :  Get-LocalGroupMembers
LAST UPDATED:  7/1/2015
#>
function Get-LocalGroupMembers {
#requires -version 3 
[cmdletbinding()]
        param( 
    [Parameter(valuefrompipeline=$true)] 
    [string[]]$ComputerName="localhost",
    [string[]]$FilterMembers,
    [string[]]$Group="Administrators",
    [string]$Delimiter = ";",
    [string]$LogPathforFailedComputers = ".\failedComputers.txt",
    [switch]$LogFailures,
    [switch]$NoAllNullMembership,
    [string]$LogPathComputersMatchFilter = ".\ComputerMatchFilter.txt",
    [switch]$LogComputersMatchFilter
    ) 
    Begin{
    $ConnectionFailedComputers = @()
    $ComputerNamesMatchFilter=@()
    }
    Process { 
        foreach ($comp in $ComputerName){
            try{
            $objComputer = [ordered]@{Computername=$comp}
            $computer = [ADSI]("WinNT://" + $Comp + ",computer")
            Foreach ($groupName in  $group)
            { 
                $LocalGroup = $computer.psbase.children.find($GroupName) 
                $Groupmembers= $LocalGroup.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} 
                If ($FilterMembers)
                        {
                $Groupmembers = (Compare-Object -ReferenceObject $GroupMembers -DifferenceObject $FilterMembers | where-object Sideindicator -eq "<=").inputobject

                }
                $objComputer.$($GroupName) = $Groupmembers -join $delimiter
            }
            #Return Computer Object with group info
                If($NoAllNullMembership -and (Test-HashForAllNullValues -testHash $objComputer -FilterKey "Computername" ) )
                {
                    Write-Verbose "$comp does not have any group members not filtered, discarding output for $comp since -NoAllNullMembership was specified"
                    $ComputerNamesMatchFilter += $Comp
                }
                else
                {
                [pscustomobject]$objComputer
                }
            }
            catch [System.Runtime.InteropServices.COMException],[System.Management.Automation.MethodException]{
                Write-verbose "Could not connnect to: $comp"
                $ConnectionFailedComputers += $comp
                }
            catch{
                 Write-verbose "Unexpected error on: comp"
                 Write-verbose ($_ | Select-Object *)
                }
             }
        } 
    end
    {
        if($logFailures)
        {
            $ConnectionFailedComputers | Out-File -FilePath $LogPathforFailedComputers

        }
        if($LogComputersMatchFilter)
        {
            $ComputerNamesMatchFilter | Out-File -FilePath $LogPathComputersMatchFilter

        }
    }
} 

Function Test-HashForAllNullValues
{
    param ($testHash,$FilterKey)
    #cannot clone ordered hash
    $temphash = $testHash.clone()
    $temphash.Remove($FilterKey)
    If ($temphash.values)
    {
        return $false
    }
    else
    {
        return $true
    }

}

#$computers | get-localGroupMembers -FilterMembers "Administrator","domain admins","testsql" -NoAllNullMembership -Verbose
