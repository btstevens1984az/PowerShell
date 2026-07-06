<#    
.SYNOPSIS    
    Builds SCCM 2012 SP1 Boundaries, Boundary groups, and asociate the boundary with its boundary group.
.DESCRIPTION  
    Builds SCCM 2012 SP1 Boundaries, Boundary groups, and asociate the boundary with its boundary group. 
.PARAMETER 
    You need to set the correct location of the CSV file BoundaryList.csv in $BoundaryList    
    Name: BuildSCCMEnv 
.EXAMPLE    
    .\BuildSCCMEnv.ps1  
      
Description  
------------  
This script returns values from a CSV file, 
Then it builds SCCM 2012 SP1 Boundaries, Boundary groups, and associate the boundary with its boundary group.
  
#>
$BoundaryList = Import-Csv "D:\Scripts\BoundaryList.csv"
foreach ($_ in $BoundaryList)
{

$getbg = Get-CMBoundaryGroup -Name $($_.BGDisplayName)
 if ($getbg -eq $null)
 {
 New-CMBoundaryGroup -Description $($_.BGDescription) -Name $($_.BGDisplayName)
 }
 $getbn = Get-CMBoundary -Name $($_.DisplayName)

if ($getbn -eq $null)
 {
 New-CMBoundary -DisplayName $($_.DisplayName) -BoundaryType IPSubnet -Value $($_.IPSubnet)
 Add-CMBoundaryToGroup -BoundaryGroupName $($_.BGDisplayName) -BoundaryName $($_.DisplayName)
 }
}