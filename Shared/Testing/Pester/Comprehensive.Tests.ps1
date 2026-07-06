# Purpose: Comprehensive.Tests — Cross-cutting logging, error handling, and utilities.
Describe "Comprehensive tests example" {
    BeforeAll {
        $myModule = get-module Microsoft.PowerShell.Operation.Validation
    }
    It "The module should be loaded" {
        $myModule | Should Not BeNullOrEmpty
    }
    It "The version of the module should be correct" {
        $myModule.Version | Should be "1.0.1"
    }
    It "Should have the proper defined functions" {
        $myModule.ExportedFunctions.Count | Should be 2
        $commands = @($myModule.ExportedFunctions.Keys)|sort-object
        $commands[0] | should be "Get-OperationValidation"
        $commands[1] | should be "Invoke-OperationValidation"
    }
    It "Should have copyright of 2016" {
        $mymodule.Copyright | should match 2016
    }
    
}
