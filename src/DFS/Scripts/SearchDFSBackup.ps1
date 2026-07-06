# Purpose: SearchDFSBackup — PowerShell automation.
$BackupRootDirectory = "\\87.43.232.114\Home Folder Documentation\DFS HomeFolders"
if ((Test-Path $BackupRootDirectory) -eq $false) {
	Write-Error -Message "Root folder $BackupRootDirectory doesn't exist"
	exit
}
$messagetitle = ""
$message = "Select backup type to search"
$BackupSubfolders = [System.IO.Directory]::GetDirectories($BackupRootDirectory)
$BackupChoices = $BackupSubfolders | ForEach-Object {$_.Split("\")[-1]}
$options = [System.Management.Automation.Host.ChoiceDescription[]]$Poss = $BackupChoices | ForEach-Object {            
	New-Object System.Management.Automation.Host.ChoiceDescription "&$($_)", "Sets $_ as an answer."       
	}
$result = $host.ui.PromptForChoice($messagetitle, $message, $options, -1)

$BackupFiles = [System.IO.Directory]::GetFiles($BackupSubfolders[$result], "*.xml", [System.IO.SearchOption]::AllDirectories)
$BackupFiles = $BackupFiles | Sort-Object -Descending # Re-order the list of files so the newest one is first
[String]$User = Read-Host -Prompt "Enter username to search for"
Write-Host -Object $BackupFiles.Count -ForegroundColor 'Cyan' -NoNewline
Write-Host -Object " backup files found in " -NoNewline
Write-Host -Object $BackupSubfolders[$result].Split("\")[-1] -ForegroundColor Cyan -NoNewline
Write-Host -Object " backup subfolder..."
Write-Host -Object "Beginning search for " -NoNewline
Write-Host -Object $User -ForegroundColor 'Cyan'
foreach ($File in $BackupFiles) {
	[xml]$dfs = Get-Content $File
	$FriendlyFileName = $File.Split("\")[-1]
	$User = $User.Trim()

	$var = $dfs.Root.Link | ? {$_.Name -eq $User} | Select-Object Name,Target

	if ($var -eq $null) {
		Write-Warning "User $User not found in $FriendlyFileName`n"
	}
	else {
		$Path = "\\29.222.253.230\Folder\" + $var.Name
		$Target = "\\" + $var.Target.Server + "\" + $var.Target.Folder
		Write-Host -Object "`nFound $User in $FriendlyFileName" -ForegroundColor 'Green'
		Write-Host -Object "$Path $Target" -ForegroundColor 'Cyan'
		Write-Host "Command to restore this link would be:"
		Write-Host -ForegroundColor 'White' -BackgroundColor 'Black' -Object "dfsutil link add $Path $Target`n"
	}
}
Pause