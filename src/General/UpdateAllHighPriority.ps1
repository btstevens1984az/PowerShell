# Purpose: UpdateAllHighPriority — General-purpose PowerShell utilities.
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




#***********************************************Disclaimer **************************************************
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied 
#warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. 
#In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be
#liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption,
#loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation,
#even if Microsoft has been advised of the possibility of such damages. 
