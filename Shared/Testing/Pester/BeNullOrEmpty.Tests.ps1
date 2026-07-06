# Purpose: BeNullOrEmpty.Tests — Cross-cutting logging, error handling, and utilities.
Set-StrictMode -Version Latest

InModuleScope Pester {
    Describe "PesterBeNullOrEmpty" {
        It "should return true if null" {
            Test-PositiveAssertion (PesterBeNullOrEmpty $null)
        }

        It "should return true if empty string" {
            Test-PositiveAssertion (PesterBeNullOrEmpty "")
        }

        It "should return true if empty array" {
            Test-PositiveAssertion (PesterBeNullOrEmpty @())
        }
    }
}
