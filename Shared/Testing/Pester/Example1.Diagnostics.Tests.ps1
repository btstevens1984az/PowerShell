# Purpose: Example1.Diagnostics.Tests — Cross-cutting logging, error handling, and utilities.
Describe "Example diagnostic finds the proper application" {
    It "Finds built in command get-Command" {
        $CommandName = "Get-Command"
        $cmd = Get-Command Get-Command
        $Cmd.Name | Should Be $CommandName
    }
}
