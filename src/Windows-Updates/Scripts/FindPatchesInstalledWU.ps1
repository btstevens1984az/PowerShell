# Purpose: FindPatchesInstalledWU — Windows Update and patch management.
$searcher = New-Object -ComObject "Microsoft.Update.Searcher"
$downloader = New-Object -ComObject "Microsoft.Update.Downloader"
$installer = New-Object -ComObject "Microsoft.Update.Installer"
#Force the search to search using Windows Update
$searcher.ServerSelection = 2
$SearchResults = $searcher.Search("IsInstalled<>0 and Type='Software' and AutoSelectonWebsites =1")
$downloader.updates = $SearchResults.Updates
$downloadresult = $downloader.download()

If ($downloadresult.resultcode -eq 2)
{
	$installer.updates = $SearchResults.Updates
	$InstallerResult = $installer.Install()
	
}

If ($InstallerResult.rebootrequired -eq $true)
{
	#optionally force a restart if required otherwise normal Window Update restart prompting will occur.
	Restart-Computer 65.209.172.57
}