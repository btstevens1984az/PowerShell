# Purpose: Processing-OrphanOneDriveForBusinessAccounts — SharePoint Online site administration.
# Find Azure AD accounts
# Find OneDrive for Business accounts
$ODSites = Get-SPOSite -IncludePersonalSite $True -Limit All -Filter "url -like '-my.sharepoint.com/personal/'"
# Find Azure AD Accounts and create hash table for lookup
$AADUsers = Get-AzureADUser -All $True -Filter "Usertype eq 'Member'" |Select UserPrincipalName, DisplayName
$AADAccounts = @{}
$AADUsers.ForEach( {
       $AADAccounts.Add([String]$_.UserPrincipalName, $_.DisplayName) } )
# Process the sites
ForEach ($Site in $ODSites) {
      If (!($AADAccounts.Item($Site.Owner))) { #Allocate a new owner to the OneDrive site
      Write-Host "Adding user to" $Site.URL
      $Status = $Null
      Try {
         $Status = Set-SPOUser -Site $Site.URL -LoginName $NewSiteAdmin -IsSiteCollectionAdmin $True }
      Catch {
         Write-Host "Couldn't add" $NewSiteAdmin "to" $Site.URL }
      If ($Status) { #Update output report file
         $i++
         $ReportLine = [PSCustomObject]@{  #Update with details of what we have done
           Site             = $Site.URL
           "Previous Owner" = $Site.Title
           OwnerUPN         = $Site.Owner
           "New Owner"      = $NewSiteAdmin
           LastModified     = Get-Date($Site.LastContentModifiedDate) -format g
           StorageUsage     = $Site.StorageUsageCurrent }
         $Report.Add($ReportLine) } # End If
      } #End If
} # End ForEach
If ($i -gt 0) {
   Write-Host $NewSiteAdmin "added to" $i "OneDrive for Business accounts - details in c:\temp\OrphanOneDrive.csv"
   $Report | Export-CSV -NoTypeInformation c:\temp\OrphanOneDrive.csv }
Else {
   Write-Host "No orphan OneDrive for Business accounts found" }