# Purpose: SiteCollectionExternalUsers — SharePoint Online site administration.
$Sites = Get-SPOSite | select * 
foreach($Site in $Sites)
������� {
������� 
�����������Write-Host "Getting External Users from " $Site.Url 
���������� Get-SPOUser -Site $Site.Url |  Where-Object { $_.LoginName -like "*EXT*"} |ft -AutoSize 
����������
�� ������}
