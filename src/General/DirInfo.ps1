# Purpose: DirInfo — General-purpose PowerShell utilities.
$ParentDirectory = "C:\temp"
$TopLevelDirectories = dir $ParentDirectory -Directory
$results = foreach ($TLD in $TopLevelDirectories)
{
   $directory =  Get-item $tld.FullName
   $dirAcl = $directory | Get-Acl
   $ACEs = $diracl.Access
   $files = dir $directory -Recurse -File
   $folders = dir $directory -Recurse -Directory
   $files30 = $files | where lastwritetime -lt ((get-date).AddDays(-30))  
   $files90 = $files | where lastwritetime -lt ((get-date).AddDays(-90))
   $files180 = $files | where lastwritetime -lt ((get-date).AddDays(-180))
   $customObj = [pscustomobject]@{
                    Fullname = $directory.FullName
                    NumberofFolders = $folders.Count
                    NumberofFiles =   $files.count
                    Files30 =$files30.count
                    Files90 =$files90.count
                    Files180 =$files180.count
                    ACECount =  $ACEs.count
                    ACEString = ($dirAcl.AccessToString -split "`n") -join ";"
                }
    $customObj
}

$results | Out-GridView