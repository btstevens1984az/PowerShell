# Purpose: ProfileKK — Storage management and disk operations.
# powershell 2
# kerry kreitinger
# session default setup

# set execution policy
set-executionpolicy remotesigned

# set default search limit to unlimited 
set-qadpssnapinsettings -defaultsizelimit 0

set-location C:\Powershell2

# create a function and assign it to an alias - then the alias can refernece a command and be used in a script
function CD32 {set-location c:\windows\system32}

set-alias go cd32

# create function to list servers - create alias "SS" which will call function
# function ShowServers {get-qadcomputer 
# set-alias SS ShowServers

function yousuck {write-host YOU SUCK !!!     YOU SUCK !!!     YOU SUCK !!!     YOU SUCK !!! -foregroundcolor DarkGreen -backgroundcolor white}
set-alias YS yousuck

function findServers {Get-QADComputer -sizelimit 0 -OSName '*server*'}
set-alias listservers findservers

$CSVlistserverspath= H:\AD-Reports\AD-Servers.CSV
function MakeServerListCSV {Get-QADComputer -sizelimit 0 -OSName '*server*' | export-csv $CSVlistserverspath}
set-alias listserverscsv MakeServerListCSV
