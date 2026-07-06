# Purpose: PromptForChoice — General-purpose PowerShell utilities.
# --------------------------------------------------------------------------------------------------------------
# PromptForChoice.ps1
# ed wilson, msft, 6/21/2009
# Demos using prompt for choice
# the system.management.automation.host.choiceDescription allows to 
# supply values for different choices
# this is required when using the $host.ui.promptForChoice method
# PowerShell Best Practices chapter 12
# -------------------------------------------------------------------------------------------------------------
$caption = "No Disk"
$message = "There is no disk in the drive. Please insert a disk into drive D:."
$choices = [System.Management.Automation.Host.ChoiceDescription[]]@("&Cancel", "&Try Again", "&Ignore")
[int]$defaultChoice = 2
$choiceRTN = $host.ui.PromptForChoice($caption,$message, $choices,$defaultChoice)

switch($choiceRTN)
{
 0    { "cancelling ..." }
 1    { "Try Again ..." }
 2    { "ignoring ..." }
}
