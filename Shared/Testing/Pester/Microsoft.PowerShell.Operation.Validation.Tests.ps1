# Purpose: Microsoft.PowerShell.Operation.Validation.Tests — Cross-cutting logging, error handling, and utilities.
$MyDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$moduleDir = (resolve-path "$myDir/../../..").path

Describe "OperationValidation Module Tests" {
    BeforeAll {
        $SavedModulePath = $env:PSModulePath
        $env:psmodulepath = $moduleDir
        Import-Module Microsoft.PowerShell.Operation.Validation -Force
        $Commands = Get-Command -module Microsoft.PowerShell.Operation.Validation|sort-object Name
    }
    AfterAll {
        $env:PSModulePath = $SavedModulePath
        remove-Module Microsoft.PowerShell.Operation.Validation
    }
    Context "Exported Commands" {
        It "Module has been loaded" {
            Get-Module Microsoft.PowerShell.Operation.Validation | should not BeNullOrEmpty
        }
        It "Exports 2 commands" {
            $commands.Count | Should be 2
        }
        It "The command names are correct" {
            $commands[0].Name | Should be "Get-OperationValidation"
            $commands[1].Name | Should be "Invoke-OperationValidation"
        }
    }
    Context "Get-OperationValidation parameters" {
        It "ModuleName parameter is proper type" {
            $commands[0].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter is proper type" {
            $commands[0].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[0].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Invoke-OperationValidation parameters" {
        It "ModuleName parameter is proper type" {
            $commands[1].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter is proper type" {
            $commands[1].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[1].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Get-OperationValidation finds proper tests" {
        BeforeAll {
            $env:psmodulepath += ";${moduleDir}/Microsoft.PowerShell.Operation.Validation/1.0.1/Test/Modules"    
        }
        AfterAll {
            $env:psmodulepath = $moduleDir
        }
        It "Can find its own tests" {
            $tests = Get-OperationValidation -modulename Microsoft.PowerShell.Operation.Validation
            $tests.Count | Should be 2
            $tests.File -eq "Simple.Tests.ps1" | Should be "Simple.Tests.ps1"
            $tests.File -eq "Comprehensive.Tests.ps1" | Should be "Comprehensive.Tests.ps1"
        }
        It "Can find tests which don't have an actual module" {
            $tests = Get-OperationValidation -moduleName Example1.Diagnostics
            @($tests).Count | Should be 1
            $tests.File | should be Example1.Diagnostics.Tests.ps1
        }
        It "Can find tests which don't have an actual module in a versioned directory" {
            $tests = Get-OperationValidation -moduleName Example2.Diagnostics
            @($tests).Count | Should be 1
            $tests.File | should be Example2.Diagnostics.Tests.ps1
        }
        It "Finds the latest version of diagnostics" {
            $tests = Get-OperationValidation -moduleName Example3.Diagnostics
            $tests.FilePath | should match "2.0.1"
        }
    }
    Context "Output Formatting is correct" {
        It "Formats the output appropriately" {
            $output = Get-OperationValidation -modulename Microsoft.PowerShell.Operation.Validation | out-string -str -width 210|?{$_}
            $expected = "File\s+:.*Simple.Tests.ps1",
                "FilePath\s+:.*Simple.Tests.ps1",
                "Name\s+:.*The content of this script should be correct",
                "TestCases",
                "Type\s+:.*Simple",
                "ModuleName\s+:.*Microsoft.PowerShell.Operation.Validation",
                "File\s+:.*Comprehensive.Tests.ps1",
                "FilePath\s+:.*Comprehensive.Tests.ps1",
                "Name\s+:.*Comprehensive tests example",
                "TestCases",
                "Type\s+:.*Comprehensive",
                "ModuleName\s+:.*Microsoft.PowerShell.Operation.Validation"

            for($i = 0; $i -lt $expected.Count;$i++)
            {
                $output[$i] | Should match $expected[$i]
            }
        }
    }
}
