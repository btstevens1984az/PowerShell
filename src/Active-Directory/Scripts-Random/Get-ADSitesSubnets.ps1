# Purpose: Get-ADSitesSubnets — Active Directory user, group, and domain administration.

# get all sites and list subnets associated to site

Get-ADReplicationSubnet -Filter * | select Name,Site | group Site | `
select @{Name='Name';Expression={$_.Name.Split(',')[0].Trim('CN=')}},@{Name='Subnets';Expression={$_.Group.Name}} | `
export-csv c:\tmp\ADSitesSubnets2.csv -notypeinformation


#get all sites and subnets individually
Get-ADReplicationSubnet -Filter * | Select Site, Name | export-csv c:\tmp\ADSitesSubnetsNoFilter2.csv -notypeinformation

# get all sites and list subnets associated to site
# removal of group Site - cause sheet to only list subnets
Get-ADReplicationSubnet -Filter * | select Name,Site | group Site |`
select @{Name='Name';Expression={$_.Name.Split(',')[0].Trim('CN=')}},@{Name='Subnets';Expression={$_.Group.Name}} | `
export-csv c:\tmp\ADSites-Subnets2.csv -notypeinformation