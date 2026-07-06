# Purpose: SimpleConstructor — General-purpose PowerShell utilities.
class MyClass
{
    [string]$prop1 
    MyClass()
    {
        $this.prop1 = "Default"
    }
    MyClass([string]$text)
    {
        $this.prop1 = $text
    }
}
[myclass]::new()
[MyClass]::new("test")