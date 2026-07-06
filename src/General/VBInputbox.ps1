# Purpose: VBInputbox — General-purpose PowerShell utilities.
add-type -AssemblyName 'Microsoft.VisualBasic'
[string] $computername = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a computer name','Computer Name','localhost')
$computername