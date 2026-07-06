# Purpose: Search-Updater — General-purpose PowerShell utilities.
$wu = new-object -com “Microsoft.Update.Searcher”
 
$totalupdates = $wu.GetTotalHistoryCount()
 
$all = $wu.QueryHistory(0,$totalupdates)
 
# Define a new array to gather output
 $OutputCollection=  @()
             
Foreach ($update in $all)
    {
    $string = $update.title
 
    $Regex = “KB\d*”
    $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }
 
     $output = New-Object -TypeName PSobject
     $output | add-member NoteProperty “HotFixID” -value $KB.‘ $_.Matches ‘.Value
     $output | add-member NoteProperty “Title” -value $string
     $OutputCollection += $output
 
    }
 
# Oupput the collection sorted and formatted:
$OutputCollection | Sort-Object HotFixID | Format-Table -AutoSize
Write-Host “$($OutputCollection.Count) Updates Found”