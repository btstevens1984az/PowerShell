# Purpose: UpdateServerTestCopyOldFiles — Storage management and disk operations.
$servers = 1..8 | %{"testsrv$_"}
$servers += "win2008r2test"
$servers | %{dir C:\temp\WMIExplorer_1.0.0.8 | copy-item -Destination "\\$_\C`$\appshare" -Verbose}
