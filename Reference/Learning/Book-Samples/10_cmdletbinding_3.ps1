# Purpose: 10 cmdletbinding 3 — Certification notes and learning materials.
function Test-DefaultParameterSet {
    [cmdletbinding(DefaultParameterSetName="Second")]
    Param (
        [parameter(ParameterSetName="First", Position=0)]
        [string]$FirstOne,
        [parameter(ParameterSetName="First", Position=1)]
        [int]$FirstTwo,
        [parameter(ParameterSetName="Second", Position=0)]
        [string]$SecondOne,
        [parameter(ParameterSetName="Second", Position=1)]
        [int]$SecondTwo
    )

    $PSBoundParameters
}

Test-DefaultParameterSet 123 32