# Purpose: SimpleInherit — General-purpose PowerShell utilities.
class BaseClass
{
    $prop1 = "baseProperty"
}

class MyClass : BaseClass
{
    $prop2 = "MyclassProperty"
}

[Myclass]::new() 