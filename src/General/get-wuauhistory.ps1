# Purpose: get-wuauhistory — General-purpose PowerShell utilities.
Function get-wuauhistory{
  #alternete method of getting windows updatesx needed
  $Session = New-Object -ComObject "Microsoft.Update.Session"
  $Searcher = $Session.CreateUpdateSearcher()
  $historyCount = $Searcher.GetTotalHistoryCount()
  $Searcher.QueryHistory(0, $historyCount) | Select-Object Date,
  #Define Operation # to "English"
   @{name="Operation"; expression={switch($_.operation){

       1 {"Installation"}; 2 {"Uninstallation"}; 3 {"Other"}}}},
  #Define Status Code to "English" 
   @{name="Status"; expression={switch($_.resultcode){
        1 {"In Progress"}; 2 {"Succeeded"}; 3 {"Succeeded With Errors"};
        4 {"Failed"}; 5 {"Aborted"}
}}}, Title|format-table -wrap}