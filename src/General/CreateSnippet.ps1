$params = @{
            Description = "Comment based help"
            Title = "Comment based help"
            Author = "Jeff Dykstra"
            Text = @"
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.PARAMETER  ComputerName
    Specify one or more computer names...
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
   General notes
#>

"@

        }
New-IseSnippet @params