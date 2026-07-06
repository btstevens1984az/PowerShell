# Purpose: compareCSVv2 — General-purpose PowerShell utilities.
# powershell2
# get list of users from db
# compare to list of users in spreadshett and create new list of unique users
# October 2010
# compareCSV.PS1

Clear-Host
$exfile = read-host "enter list name from 222.205.193.149 ie . .  Safford.csv do not include extension"
$gwfile = read-host "Enter list name from Groupwise ie SaffordGW no extension"

$csvfileEX = $($exfile + ".csv")
$csvfileGW = $($gwfile + ".csv")

# create list of users from groupwise list
import-csv $("\\43.241.88.221\server_team\exchange2010csvs\"+ $csvfileGW) | where-object {$_."Client License" -ne "Inactive"} | select-object user | `
out-file $("\\43.241.88.221\server_team\exchange2010csvs\"+ $gwfile + ".txt")

$inputGWtxt = $($gwfile + ".txt")

# read list of users that are already in 222.205.193.149
import-csv $("\\43.241.88.221\server_team\exchange2010csvs\"+ $csvfileEX) | select-object alias | `
out-file $("\\43.241.88.221\server_team\exchange2010csvs\"+ $exfile + ".txt")
$inputEXtxt = $($exfile + ".txt")

$strReference = get-content $("\\43.241.88.221\server_team\exchange2010csvs\" + $inputGWtxt)
$strDifference = get-content $("\\43.241.88.221\server_team\exchange2010csvs\" + $inputEXtxt)

Compare-Object $strReference $strDifference | `
out-file $("\\43.241.88.221\server_team\exchange2010csvs\"+ $exfile + "-need-accounts.txt")