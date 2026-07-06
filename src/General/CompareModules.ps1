# Purpose: CompareModules — General-purpose PowerShell utilities.

function Create-ModuleCompare
{
    param($moduleSource,$moduledifference,[string]$moduleSourcePrefix,[string]$moduleDiffPreFix)

    $moduleSourceHash = $moduleSource | Group-Object -AsHashTable -Property name
    #$moduledifferenceHash = $moduledifference | Group-Object -AsHashTable -Property name

    foreach ($module in $moduledifference)
    {
        if ($moduleSourceHash.ContainsKey($module.name))
        {
        $moduleSource = $modulesourcehash.$($module.name)
        $module| Add-Member -MemberType NoteProperty -Name ($moduleSourcePrefix+"CommandCount") -Value $moduleSource.exportedcommands.count -Force
        $module| Add-Member -MemberType NoteProperty -Name ($modulediffPrefix+"CommandCount") -Value  $module.exportedcommands.count -Force
        $compare = Compare-object -ReferenceObject $moduleSource.exportedcommands.GetEnumerator().name -DifferenceObject $module.ExportedCommands.GetEnumerator().name
        $module| Add-Member -MemberType NoteProperty -Name ($moduleDiffPreFix+"AddedCommands") -Value (($compare | where-object SideIndicator -eq "=>").inputobject) -Force
         $module | Add-Member -MemberType NoteProperty -Name ($moduleDiffPreFix+"RemovedCommands") -Value (($compare | where-object SideIndicator -eq "<=").inputobject) -Force
         $modulesource | Select-Object win*,new* | Get-Member -MemberType NoteProperty | foreach {
          $module | Add-Member -Name $_.name -Value ($moduleSource.$($_.name) ) -MemberType NoteProperty  -force
           }
         $module

        }
        else
        {
            #new module
            $module | Add-Member -MemberType NoteProperty -Name ($modulediffPrefix+"CommandCount") -Value  $moduledifferenceHash.$($module.name).exportedcommands.count -Force
            $module| Add-Member -MemberType NoteProperty -Name ($moduleDiffPreFix+"AddedCommands") -Value ($module.exportedcommands.GetEnumerator().name)
            #$module | Add-Member -MemberType NoteProperty -name ("Newin"+$moduleDiffPrefix) -Value $true
            $module | Add-Member -MemberType NoteProperty -name ("Newin"+$moduleDiffPrefix) -Value $true
            $module

        }
    }
}
$filepath = "C:\Users\jeff.KAYLOSLAB\OneDrive\WorkStuff\PSH5 Features\LanguageandCmdletChanges\"
Set-Location $filepath
$win81RTMmodules = Import-Clixml .\win81RTMmodules.xml
$win81Patchedmodules = Import-Clixml .\Win81psh4fullypatchedNov052015modules.xml
$win81psh5modules = Import-Clixml .\Win81psh5Oct202015modules.xml
$win10modules = import-clixml .\win10Nov112015FastBranchbuild10586modules.xml

$combinedModuleInfo = Create-ModuleCompare -moduleSource $win81RTMmodules -moduledifference $win81Patchedmodules -moduleSourcePrefix Win81RTM -moduleDiffPreFix Win81Patched
$combinedModuleInfo = Create-ModuleCompare -moduleSource $combinedModuleInfo -moduledifference $win81psh5modules -moduleSourcePrefix Win81Patched -moduleDiffPreFix win81PSH5
$combinedModuleInfo = Create-ModuleCompare -moduleSource $combinedModuleInfo -moduledifference $win10modules -moduleSourcePrefix win81PSH5  -moduleDiffPreFix Win10
$countproperties = "Win81RTMCommandCount","Win81PatchedCommandCount","win81PSH5CommandCount","Win10CommandCount"
$commandAddedProps="Win81PatchedAddedCommands","win81PSH5AddedCommands","Win10AddedCommands"
$commandRemovedprops= "Win81PatchedRemovedCommands","win81PSH5RemovedCommands","Win10RemovedCommands"
$NewinProps = "win81Patched" ,"win81PSH5","win10" | %{"NewIn$_" }
$combinedProps = @("name") +$countproperties +$NewinProps+$commandAddedProps+$commandRemovedprops

$combinedModuleInfo | Select-Object $combinedProps | Out-GridView
$combinedModuleInfo | Select-Object $combinedProps | Export-Clixml .\modulecompare3.xml