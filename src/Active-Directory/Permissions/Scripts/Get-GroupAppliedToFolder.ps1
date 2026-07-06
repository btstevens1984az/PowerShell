# Purpose: Get-GroupAppliedToFolder — Active Directory user, group, and domain administration.

$StartDirectory = Read-Host -Prompt "Enter path"
$Group = (Read-Host -Prompt "Enter group").Trim()
$RootDirectoryList = [System.IO.Directory]::GetDirectories($StartDirectory)
$OneLevelDirectoryList = $RootDirectoryList | %{[System.IO.Directory]::GetDirectories($_)}
$DirectoryList = $RootDirectoryList + $OneLevelDirectoryList
[Bool]$Found = $false
foreach ($Directory in $DirectoryList) {
	$p++
	Write-Progress -Activity "Checking folders" -Status $Directory.Split("\")[-1] -PercentComplete (($p / $DirectoryList.Count) * 100)
	$ACL = [System.IO.Directory]::GetAccessControl($Directory)
	foreach ($DirACL in $ACL.Access) {
		if ($DirACL.IdentityReference -match $Group -and $DirACL.IsInherited -eq $false) {
			$Found = $true
			Write-Host -Object $DirACL.IdentityReference -ForegroundColor 'Cyan' -NoNewline
			Write-Host -Object " found explicitly applied to " -NoNewline
			Write-Host -Object $Directory -ForegroundColor Cyan
		}
	}
}
if ($Found -eq $false) {
	Write-Output "$Group not found on any directory in $StartDirectory`nor one level below"
}
Read-Host -Prompt "Press Enter to exit"