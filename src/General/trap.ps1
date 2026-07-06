# Purpose: trap — General-purpose PowerShell utilities.
trap
{
    "test trap"
    continue
}


throw "term err"
"After throw"
trap [System.Management.Automation.RuntimeException]
{
    "test trap2"
    continue
}

"after trap"
throw "after trap term error"
"after trap and throw"