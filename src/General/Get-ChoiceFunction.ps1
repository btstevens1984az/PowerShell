# Purpose: Get-ChoiceFunction — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 7/7/2009
#
# KEYWORDS: Get-WmiObject, Function, promptforchoice
# ChoiceDescription
# COMMENTS: This script uses a Get-Choice function to 
# display choices using promptforchoice. The user selects
# the comptuer name from list, and the script queries the 
# appropriate computer. The name of the selected computer
# is returned directly from the function.
# 
# ------------------------------------------------------------------------

Function Get-Choice
{
 $caption = "Please select the computer to query" 
 $message = "Select computer to query"
 $choices = [System.Management.Automation.Host.ChoiceDescription[]] `
 @("&loopback", "local&host", "&127.0.0.1")
 [int]$defaultChoice = 0
 $choiceRTN = $host.ui.PromptForChoice($caption,$message, $choices,$defaultChoice)

 switch($choiceRTN)
 {
  0    { "loopback"  }
  1    { "localhost"  }
  2    { "127.0.0.1"  }
 }
} #end Get-Choice function

Get-WmiObject -class win32_bios -computername (Get-Choice)

