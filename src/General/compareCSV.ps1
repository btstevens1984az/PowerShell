# Purpose: compareCSV — General-purpose PowerShell utilities.
# powershell2
# get list of users from db
# compare to list of users in spreadshett and create new list of unique users
# October 2010
# compareCSV.PS1

Clear-Host
# create list of users
import-csv "\\43.241.88.221\server_team\exchange2010csvs\saffordGW.csv" | where-object {$_."Client License" -ne "Inactive"} | select-object user | `
out-file "\\43.241.88.221\server_team\exchange2010csvs\SaffordGW.txt"

# read list of users that are already in 222.205.193.149
import-csv "\\43.241.88.221\server_team\exchange2010csvs\safford.csv" | select-object alias | `
out-file "\\43.241.88.221\server_team\exchange2010csvs\SaffordEX.txt"

$strReference = get-content "\\43.241.88.221\server_team\exchange2010csvs\SaffordGW.txt"
$strDifference = get-content "\\43.241.88.221\server_team\exchange2010csvs\SaffordEX.txt"

Compare-Object $strReference $strDifference |out-file "\\43.241.88.221\server_team\exchange2010csvs\Safford-need-accounts.txt"