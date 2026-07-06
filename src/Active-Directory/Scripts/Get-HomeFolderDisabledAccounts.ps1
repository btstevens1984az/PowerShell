# Purpose: Get-HomeFolderDisabledAccounts — Active Directory user, group, and domain administration.
Function Get-HomeFolderDisabledAccounts {
Import-Module ActiveDirectory
$logfile = "C:\Temp\HomeFolderDisabledAccounts.csv"
$input = read-host "Enter path Example \\240.217.252.191\share"

If ((Test-Path $input) -eq $true) {
		$folders = Get-ChildItem $input

		$count = 0

		Add-Content $logfile "samaccountname,enabled,fullpath,description"

		$folders | ForEach-Object{
        $account = "account not found"
		$folder = $_
		$count = $count + 1
		$account = Get-aduser -identity  $folder.name -properties Description
		Add-Content $logfile "$($account.samaccountname),$($account.enabled),$($folder.fullname),$($account.description)"
		Write-Host "Working on $count of $($folders.count)"
		}


}
else {
		Write-Host "Invalid path"
}
}