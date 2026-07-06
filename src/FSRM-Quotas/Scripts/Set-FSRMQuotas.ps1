# Purpose: Set-FSRMQuotas — PowerShell automation.
Import-Module FileServerResourceManager
$Quotas = Get-FsrmQuotaTemplate # Get list of all quotas on the server
$Path = Read-Host -Prompt "Enter path [e.g. X:\Users1]" # Get path from user
$Path = $Path.Trim() # Remove any spaces from entered path
try {
	$AutoApplyQuota = (Get-FsrmAutoQuota -Path $Path -ErrorAction 'Stop').Size / 1gb # Get the current Auto Apply Quota for the path
}
catch {
	# Catch any error - usually either the path doesn't exist or it doesn't have an Auto Apply Quota on it
	Write-Error -Message "Path $Path does not exist or does not have an AutoApply quota applied to it`nExiting script"
	Pause
	exit
}
if ($AutoApplyQuota -lt 20) { # If the AutoApply quota is less than 20GB, warn before proceeding.
	$messagetitle = "WARNING"
	$message = "AutoApply Quota on $Path is less than 20GB. Do you want to continue anyway?"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
	"Exits the script"
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
	"Proceeds with running the script"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
	$result = $host.ui.PromptForChoice($messagetitle, $message, $options, 0)
	switch ($result) {
	0 { # No selected
		exit
		}
	1 { # Yes selected
		# Just continue if Yes
		}
	}
}
$Folders = Get-ChildItem -Path $Path | Select -ExpandProperty FullName # Get list of all folders on Users5

foreach ($Folder in $Folders) {
	$CurrentQuotaInfo = Get-FsrmQuota $Folder # Get current quota & usage information
	$CurrentQuotaSize = $CurrentQuotaInfo.Size / 1gb
	$CurrentQuotaUsage = $CurrentQuotaInfo.Usage / 1gb
	if ($CurrentQuotaSize -lt $AutoApplyQuota) {
		# If their current quota is already less than the autoapply quota, don't do anything.
		Write-Host -ForegroundColor 'Yellow' -Object "Not changing quota for $Folder because the applied quota is already less than the auto apply quota"
		continue
	}
	if ($CurrentQuotaUsage -ge 5) {$FutureGrowth = $CurrentQuotaInfo.Usage * 1.2} # If they are using more than 5GB already, multiply by 1.2 to account for future growth
	else {$FutureGrowth = $CurrentQuotaInfo.Usage * 1.5} # If they're using less than 5GB, multiply by 1.5
	$BestQuota = $Quotas | where {$FutureGrowth -lt $_.Size -and $_.Description -ne ""} | Select -First 1 # The built-in templates (not created by Allan) do not have a description.
	Reset-FsrmQuota -Path $Folder -Template $BestQuota.Name -Confirm:$false | Out-Null # Change quota to ideal.
	Write-Host -ForegroundColor 'Cyan' -Object "Changed quota on $Folder to $($BestQuota.Name). Usage was $([Decimal]::Round($CurrentQuotaUsage)) GB. Future growth was $([Decimal]::Round($FutureGrowth / 1gb)) GB."
}

# -Confirm:$false makes it not prompt for confirmation

# Get-SmbShare | where {$_.Name -notlike "*$"} | Select -ExpandProperty Path | ForEach-Object {gci -Path $_} | Select -ExpandProperty FullName
# Get-SmbShare | where {$_.Name -notlike "*$"} | Select -ExpandProperty Path
# This line would get a list of every share.