# Purpose: LoadDemos — General-purpose PowerShell utilities.
Function Load-MyDemos
{
    param(
            [ValidateNotNullOrEmpty()]
            [string]$demoPath = $PSScriptRoot,
            [parameter(Mandatory)]
            [string[]]$DemoScripts,
            [parameter(Mandatory)]
            [string]$TabName)


    $newTab = $psISE.PowerShellTabs.Add()
    $newTab.DisplayName = $tabName
    Foreach ($file in $DemoScripts)
    {
        $newTab.Files.Add("$demoPath\$file")
    }
}

#$params = @{
#    DemoPath = "C:\Users\jeff\OneDrive\Documents\scripts\text"
#    DemoScripts = "CmdToObj.ps1","RegExCommonMistakes.ps1","GetEmail.ps1","PSH5NewStringCmdlets.ps1"
#    TabName = "RegEx Demo"
#}
#Load-MyDemos @params





