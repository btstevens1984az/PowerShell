# Purpose: listobject — General-purpose PowerShell utilities.
function list-object {
param (
    [parameter(Mandatory)]
    $obj,
    $depth=5,
    $tablevel=1
    )
    $tabs = "`t" * $tablevel
    if (!$obj)
    {
        "what is obj: $obj"
    }
    $properties = $obj | Get-Member -MemberType Properties
    trap [System.Management.Automation.PropertyNotFoundException]
    {continue}
    If ($properties)
    {Foreach ($prop in $properties.name)
    {
        if ($obj.$($prop) -and $obj.$($prop).gettype().fullname -match "^system\.[^\.]+$")
        {
            "$tabs$prop : $($obj.$($prop))"
        }
        elseif($obj.$($prop) -eq $null)
        {
            "$tabs$prop is null"
        }
        else
        {
            write-verbose "nested object in $prop"
            if($obj.$($prop) -and (Get-PSCallStack).count -lt $depth)
            {list-object -obj $obj.$($prop) -tablevel ($tablevel++) }
        }
    }
    }
    else
    {$obj}
    
}

list-object -obj $error[0]