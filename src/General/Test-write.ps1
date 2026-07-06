# Purpose: Test-write — General-purpose PowerShell utilities.
$whopper1 = "hardly anything"
$ServerItem = "114.148.18.125"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_testInfo6.txt")

#test1 works
write-host "test1 151.17.42.141 has srvadmin mapped $whopper1"
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "test1 151.17.42.141 has srvadmin mapped $filetest"

write-host "test2 150.53.99.16 has srvadmin mapped $whopper1"
Add-Content '\\114.148.18.125\UpdatesInventory$\'$LogOutputName "test2 151.17.42.141 has srvadmin mapped $filetest"

write-host "test2A 150.53.99.16 has srvadmin mapped $whopper1"
Add-Content "'\\114.148.18.125\UpdatesInventory$\$LogOutputName'" "test2A 151.17.42.141 has srvadmin mapped $filetest"

write-host "test3 150.53.99.16 has srvadmin mapped $whopper1"
Add-Content '\\114.148.18.125\UpdatesInventory$\"$LogOutputName"' "test3 151.17.42.141 has srvadmin mapped $filetest"

write-host "test4 150.53.99.16 has srvadmin mapped $whopper1"
Add-Content ""\\114.148.18.125\UpdatesInventory$\$LogOutputName"" "test4 151.17.42.141 has srvadmin mapped $filetest"

# test5 works
write-host "test5 150.53.99.16 has srvadmin mapped $whopper1"
Add-Content \\114.148.18.125\UpdatesInventory$\"$LogOutputName" "test5 151.17.42.141 has srvadmin mapped $filetest"

Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName"  $ServerItem "test1 not online No further processing done"
# test1Variable works
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName"  "$ServerItem test1Variable not online No further processing done"