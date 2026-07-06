Function Get-AssetGroupByName{
<#
    .SYNOPSIS
        Find asset groups by name.
    .DESCRIPTION
        Finds name of an asset group and returns the config of all that match.
    .PARAMETER $Assetgroupname
        String to be used to search for. Should be in this format inclduing single quotes 'Assetgroupname', 'Assetgroup*' or '*group*'.
    
    .EXAMPLE
        
        Get-AssetGroupByName 'CMDB-ApplicationTeam-*'

#>
Param([string]$Assetgroupname)
Confirm-Session
$AssetGroupID = Get-AssetGroupListing | where { $_.name -like "$Assetgroupname" } | select id -ExpandProperty id

Foreach($ID in $AssetGroupID){
    Get-AssetGroupConfig $ID.id
    }

}