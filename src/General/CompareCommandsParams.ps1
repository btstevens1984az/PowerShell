# Purpose: CompareCommandsParams — General-purpose PowerShell utilities.

function Create-CommandCompare
{
    param($CommandSource,$Commanddifference,[string]$CommandSourcePrefix,[string]$CommandDiffPreFix,[string[]]$FilterParam=@("InformationAction","InformationVariable"))

    $CommandSourceHash = $CommandSource | Group-Object -AsHashTable -Property name
    #$CommanddifferenceHash = $Commanddifference | Group-Object -AsHashTable -Property name

    foreach ($Command in $Commanddifference)
    {
        if ($CommandSourceHash.ContainsKey($Command.name))
        {
        $CommandSource = $Commandsourcehash.$($Command.name)
        $Command| Add-Member -MemberType NoteProperty -Name ($CommandSourcePrefix+"ParamCount") -Value  $CommandSource.Parameters.keys.count -Force
        $Command| Add-Member -MemberType NoteProperty -Name ($CommanddiffPrefix+"ParamCount") -Value  $Command.Parameters.keys.count -Force
        $compare = Compare-object -ReferenceObject ([string[]]$CommandSource.Parameters.keys) -DifferenceObject ([string[]]$Command.Parameters.keys)
        $Command| Add-Member -MemberType NoteProperty -Name ($CommandDiffPreFix+"AddedParameters") -Value (($compare | where-object {$_.sideindicator -eq "=>" -and $_.inputobject -notin $filterparam}).inputobject) -Force
         $Command | Add-Member -MemberType NoteProperty -Name ($CommandDiffPreFix+"RemovedParameters") -Value (($compare | where-object SideIndicator -eq "<=").inputobject) -Force
         $Commandsource | Select-Object win* | Get-Member -MemberType NoteProperty | foreach {
          $Command | Add-Member -Name $_.name -Value ($CommandSource.$($_.name) ) -MemberType NoteProperty  -force
           }
         $Command

        }
        else
        {
            #new Command
            $Command | Add-Member -MemberType NoteProperty -Name ($CommanddiffPrefix+"CommandCount") -Value  $CommanddifferenceHash.$($Command.name).exportedcommands.count -Force
            $Command | Add-Member -MemberType NoteProperty -Name ($CommanddiffPreFix+"NewCommand") -Value $true -Force
            #Comment out below line to not include full list or parameters when the command is new
            #$Command| Add-Member -MemberType NoteProperty -Name ($CommandDiffPreFix+"AddedParameters") -Value ([string[]]$Command.Parameters.keys) -Force
            $Command| Add-Member -MemberType NoteProperty -Name ($CommandDiffPreFix+"AddedParameters") -Value $null -Force
            $command

        }
    }
}
$filepath = "C:\Users\jeff.KAYLOSLAB\OneDrive\WorkStuff\PSH5 Features\LanguageandCmdletChanges\"
Set-Location $filepath
$win81RTMcmds = Import-Clixml .\win81RTMcmds.xml | Where-Object {($_.commandtype.value -eq "cmdlet" -or $_.commandtype.value -eq "function") -and $_.parameters.keys.count}
$win81patchedcmds = Import-Clixml .\Win81psh4fullypatchedNov052015cmds.xml| Where-Object {($_.commandtype.value -eq "cmdlet" -or $_.commandtype.value -eq "function") -and $_.parameters.keys.count}
$win81PSH5cmds = Import-Clixml .\Win81psh5Oct202015cmds.xml| Where-Object {($_.commandtype.value -eq "cmdlet" -or $_.commandtype.value -eq "function") -and $_.parameters.keys.count}
$win10cmds = Import-Clixml .\win10Nov112015FastBranchbuild10586cmds.xml|  Where-Object {($_.commandtype.value -eq "cmdlet" -or $_.commandtype.value -eq "function") -and $_.parameters.keys.count}

$combinedCommandInfo = Create-CommandCompare -CommandSource $win81RTMcmds -Commanddifference $win81patchedcmds -CommandSourcePrefix Win81RTM -CommandDiffPreFix Win81Patched
$combinedCommandInfo = Create-CommandCompare -CommandSource $combinedCommandInfo -Commanddifference $win81PSH5cmds -CommandSourcePrefix Win81Patched -CommandDiffPreFix win81PSH5
$combinedCommandInfo = Create-CommandCompare -CommandSource $combinedCommandInfo -Commanddifference $win10cmds -CommandSourcePrefix win81PSH5  -CommandDiffPreFix Win10
$countproperties = "Win81RTMParamCount","Win81PatchedParamCount","win81PSH5ParamCount","Win10ParamCount"
$NewCommandProps = "Win81PatchedNewCommand","win81PSH5NewCommand","win10NewCommand"
$commandAddedProps="Win81PatchedAddedParameters","win81PSH5AddedParameters","Win10AddedParameters"
$commandRemovedprops= "Win81PatchedRemovedParameters","win81PSH5RemovedParameters","Win10RemovedParameters"
$combinedProps = @("name","source") +$countproperties +$commandAddedProps+$commandRemovedprops+$NewCommandProps
$onlyChangedCommands = $combinedCommandInfo | Where-Object {$_.Win81PatchedAddedParameters -or  $_.win81PSH5AddedParameters -or $_.Win10AddedParameters -or $_.Win81PatchedNewCommand -or $_.win81PSH5NewCommand -or $_.win10NewCommand }
$onlyChangedCommands | Select-Object $combinedProps | Out-GridView
$onlyChangedCommands | Select-Object $combinedProps | Export-Clixml .\CommandParamcompare3.xml

#$combinedCommandInfo | Select-Object $combinedProps | Where-Object {$_.Win81PatchedAddedParameters -eq $null -and $_.win81PSH5AddedParameters -eq $null -and $_.Win10AddedParameters -eq $null}
