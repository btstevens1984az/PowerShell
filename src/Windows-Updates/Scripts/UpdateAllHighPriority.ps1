# Purpose: UpdateAllHighPriority — Windows Update and patch management.
$searcher = New-Object -ComObject "Microsoft.Update.Searcher"
$downloader = New-Object -ComObject "Microsoft.Update.Downloader"
$installer = New-Object -ComObject "Microsoft.Update.Installer"
#Force the search to search using Windows Update
$searcher.ServerSelection = 2
$SearchResults = $searcher.Search("IsInstalled=0 and Type='Software'")
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
	Restart-Computer 131.230.190.167
}



<#
    Due to security contraints on the Windows Update APIs using these techniques through
    Powershell remoting does not work in my experience. You can always use PSexec in those scenarios.
    The searcher object works fine remotely, you just can't install. Other possible options would
    be to run it as a scheduled task which you can configure remotely.  Also, you could use a custom remoting end-point
    that leverages a run as account. 
#>
