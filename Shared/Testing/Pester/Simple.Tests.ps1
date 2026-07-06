# Purpose: Simple.Tests — Cross-cutting logging, error handling, and utilities.
$scriptPath = $myinvocation.mycommand.Source
$global:foo = $myinvocation.mycommand
Describe "The content of this script should be correct" {
    It "There should be a single 'it' block" {
        $t = $e = $null
        $ast=[system.management.automation.language.parser]::ParseFile("$scriptPath",[ref]$t,[ref]$e)
        ($t|?{$_.Text -eq "It"}).count | should be 1
    }
}
