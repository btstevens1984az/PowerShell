# Purpose: Get-MSHotfixNetwork — Windows Update and patch management.


Function Get-MSHotfix
{
    $outputs = Invoke-Expression "wmic qfe list"
    $outputs = $outputs[1..($outputs.length)]
    $UpdateResults = @()
    
    foreach ($output in $Outputs) {

        if ($output) {
            $output = $output -replace 'y U','y-U'
            $output = $output -replace 'NT A','NT-A'
            $output = $output -replace '\s+',' '
            $parts = $output -split ' '
            if ($parts[5] -like "*/*/*") {
                $Dateis = [datetime]::ParseExact($parts[5], '%M/%d/yyyy',[Globalization.cultureinfo]::GetCultureInfo("en-US").DateTimeFormat)
            } elseif (($parts[5] -eq $null) -or ($parts[5] -eq ''))
            {
                $Dateis = [datetime]1700
            }
            
            else {
                $Dateis = get-date([DateTime][Convert]::ToInt64("$parts[5]", 16))-Format '%M/%d/yyyy'
            }
			
             $hItemDetails = [PSCustomObject]@{
                KBArticle = [string]$parts[0]
                Computername = [string]$parts[1]
                Description = [string]$parts[2]
                FixComments = [string]$parts[6]
                HotFixID = [string]$parts[3]
                InstalledOn = Get-Date($Dateis)-format "dddd d MMMM yyyy"
                InstalledBy = [string]$parts[4]
                InstallDate = [string]$parts[7]
                Name = [string]$parts[8]
                ServicePackInEffect = [string]$parts[9]
                Status = [string]$parts[10]
            }
			$updateResults += $hItemDetails
        }
   $UpdateResults|export-csv -append "\\186.189.182.154\share\output.csv" -notypeinformation
	}
	
}

get-mshotfix
