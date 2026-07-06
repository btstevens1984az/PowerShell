# Purpose: listing18-2 — Certification notes and learning materials.
Import-Module PSWorkflow

workflow Test-Workflow {
    
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty `
                      -Name ExampleProperty `
                      -Value 'Hello!'
    $obj | Get-Member
}

Test-Workflow
