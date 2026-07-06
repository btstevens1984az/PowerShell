# Purpose: AddRequirements — General-purpose PowerShell utilities.
& {
	# do not update #requires statement for .psm1 files
	$extension = [IO.Path]::GetExtension($psise.PowerShellTabs.SelectedPowerShellTab.Files.SelectedFile.FullPath)
	if ($extension -ne '.psm1')
	{
		$editor = Get-SteroidsEditor
		Update-SteroidsRequiresStatement -ISEEditor $editor
	}
	Invoke-SteroidsTextChange
}
