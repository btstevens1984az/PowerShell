# Purpose: LexicalScoping — General-purpose PowerShell utilities.
$d = 42 # Script scope
function bar
{
    $d = 0 # Function scope
    [MyClass]::DoSomething()
}
class MyClass
{
    static [object] DoSomething()
    {
        return $d # error, not found dynamically
        return $function:d
        return $script:d # no error
        $d = $script:d
        return $d # no error, found lexically
    }
}
$v = bar
$v -eq $d # true