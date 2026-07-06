# Purpose: OD4B-SPOSites — SharePoint Online site administration.
# Update SharePoint default storage quota
Set-SPOTenant -OneDriveStorageQuota 5242880


# Assign storage quota to OneDrive sites
$ODSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select URL, Title, StorageQuota, StorageUsageCurrent
ForEach ($Site in $ODSites) {
   If ($Site.StorageQuota -ne 5242880) {
      Write-Host "Setting Quote for OneDrive account:" $Site.Title
      Set-SPOSite -Identity $Site.URL -StorageQuota 5242880 }
}



# Get all OneDrive sites
Write-Host "Fetching OneDrive site information..."
$Sites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'"  | Sort StorageUsageCurrent -Desc
$TotalOneDriveStorageUsed = [Math]::Round(($Sites.StorageUsageCurrent | Measure-Object -Sum).Sum /1024,2)
$Report = [System.Collections.Generic.List[Object]]::new()
ForEach ($Site in $Sites) {
  $SiteOwners = $Null ; $Process = $True; $NoCheckGroup = $False
  $SiteNumber++
  $SiteStatus = $Site.Title + " ["+ $SiteNumber +"/" + $Sites.Count + "]"
  $UsedGB = [Math]::Round($Site.StorageUsageCurrent/1024,2)
# And write out the information about the site
  If ($Process -eq $True) {
      $ReportLine = [PSCustomObject]@{
         URL           = $Site.URL
         Owner         = $Site.Title
         QuotaGB       = [Math]::Round($Site.StorageQuota/1KB,0)
         UsedGB        = $UsedGB
         PercentUsed   = ([Math]::Round(($Site.StorageUsageCurrent/$Site.StorageQuota),4).ToString("P")) }
     $Report.Add($ReportLine)}}
# Now generate the report
$Report | Export-CSV -NoTypeInformation c:\temp\OneDriveConsumption.CSV