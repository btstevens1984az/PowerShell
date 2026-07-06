# Purpose: LoadRegExDemos — General-purpose PowerShell utilities.
$root = (Get-PSDrive scripts).root
$params = @{
    
    DemoPath = "$root\text"
    DemoScripts = "GetIps.ps1","FilterIps.txt","CmdToObj.ps1",
                "RegExCommonMistakes.ps1","GetEmail.ps1",
                "PSH5NewStringCmdlets.ps1"
    TabName = "REGEX DEMO"
}
. scripts:\Functions\LoadDemos.ps1
Load-MyDemos @params





