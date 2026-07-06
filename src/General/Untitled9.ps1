# Purpose: Untitled9 — General-purpose PowerShell utilities.
function Create-ModuleCompare
{
    param($moduleSource,$moduledifference,[string]$moduleSourcePrefix,[string]$moduleDiffPreFix)

    $moduleSourceHash = $moduleSource | Group-Object -AsHashTable -Property name
    $moduledifferenceHash = $moduledifference | Group-Object -AsHashTable -Property name

    foreach ($module in $moduledifference)
    {
        if ($moduleSourceHash.ContainsKey($module.name))
        {
        $moduleSource = $modulesourcehash.$($module.name)
        $module| Add-Member -MemberType NoteProperty -Name ($moduleSourcePrefix+"CommandCount") -Value $modulesourcehash.$($module.name).exportedcommands.count -Force
        $module| Add-Member -MemberType NoteProperty -Name ($modulediffPrefix+"CommandCount") -Value  $moduledifferenceHash.$($module.name).exportedcommands.count -Force
        $compare = Compare-object -ReferenceObject $modulesourcehash.$($module.name).exportedcommands.GetEnumerator().name -DifferenceObject $module.ExportedCommands.GetEnumerator().name
        $module| Add-Member -MemberType NoteProperty -Name ($moduleDiffPreFix+"AddedCommands") -Value (($compare | where-object SideIndicator -eq "=>").inputobject) -Force
         $module | Add-Member -MemberType NoteProperty -Name ($moduleDiffPreFix+"RemovedCommands") -Value (($compare | where-object SideIndicator -eq "<=").inputobject) -Force
         $modulesource | select win* | gm -MemberType NoteProperty | foreach {
          $module | Add-Member -Name $_.name -Value ($moduleSource.$($_.name) ) -MemberType NoteProperty  -force
           }
         $module

        }
        else
        {
            #new module
            $module | Add-Member -MemberType NoteProperty -Name ($modulediffPrefix+"CommandCount") -Value  $moduledifferenceHash.$($module.name).exportedcommands.count -Force
            $module

        }
    }
}

$combindedModuleInfo = Create-ModuleCompare -moduleSource $win81RTMmodules -moduledifference $win81Patchedmodules -moduleSourcePrefix Win81RTM -moduleDiffPreFix Win81Patched
$combindedModuleInfo = Create-ModuleCompare -moduleSource $combindedModuleInfo -moduledifference $win81psh5modules -moduleSourcePrefix Win81Patched -moduleDiffPreFix win81PSH5
$combindedModuleInfo = Create-ModuleCompare -moduleSource $combindedModuleInfo -moduledifference $win10modules -moduleSourcePrefix win81PSH5  -moduleDiffPreFix Win10
$countproperties = "Win81RTMCommandCount","Win81PatchedCommandCount","win81PSH5CommandCount","Win10CommandCount"
$commandAddedProps="Win81PatchedAddedCommands","win81PSH5AddedCommands","Win10AddedCommands"
$commandRemovedprops= "Win81PatchedRemovedCommands","win81PSH5RemovedCommands","Win10RemovedCommands"
$combinedProps = @("name") +$countproperties +$commandAddedProps+$commandRemovedprops

$combindedModuleInfo | select $combinedProps | ogv