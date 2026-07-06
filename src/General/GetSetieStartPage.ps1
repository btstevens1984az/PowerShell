# Purpose: GetSetieStartPage — General-purpose PowerShell utilities.
Param([switch]$get,[switch]$set,$computer="localhost")
$Comment = @"
NAME: GetSetieStartPage.ps1
AUTHOR: ed wilson, Microsoft
DATE: 1/5/2009

KEYWORDS: stdregprov, ie, [wmiclass] type accelerator,
Hey Scripting Guy
COMMENTS: This script uses the [wmiclass] type accelerator
and the stdregprov to get the ie start pages and to set the
ie start pages. Using ie 7 or better you can have multiple
start pages.

"@ #end comment

Function Get-ieStartPage()
{
$Comment = @"
FUNCTION: Get-ieStartPage 
Is used to retrieve the current settings for Internet Explorer 7 and greater.
The value of $hkcu is set to a constant value from the SDK that points
to the Hkey_Current_User. Two methods are used to read
from the registry because the start page is single valued and
the second start page's key is multi-valued.

"@ #end comment
 $hkcu = 2147483649
 $key = "Software\Microsoft\Internet Explorer\Main"
 $property = "Start Page"
 $property2 = "Secondary Start Pages"
 $wmi = [wmiclass]"\\$computer\root\default:stdRegProv"
 ($wmi.GetStringValue($hkcu,$key,$property)).sValue
 ($wmi.GetMultiStringValue($hkcu,$key, $property2)).sValue
} #end Get-ieStartPage

Function Set-ieStartPage()
{
$Comment = @"
FUNCTION: Set-ieStartPage 
Allows you to configure one or more home pages for IE 7 and greater. 
The $aryValues and the $Value variables hold the various home pages.
Specify the complete URL ex: "http://www.ScriptingGuys.Com." Make sure
to include the quotation marks around each URL. 

"@ #end comment
  $hkcu = 2147483649
  $key = "Software\Microsoft\Internet Explorer\Main"
  $property = "Start Page"
  $property2 = "Secondary Start Pages"
  $value = "http://www.microsoft.com/technet/scriptcenter/default.mspx"
  $aryValues = "http://social.technet.microsoft.com/Forums/en/ITCG/threads/",
  "http://www.microsoft.com/technet/scriptcenter/resources/qanda/all.mspx"
  $wmi = [wmiclass]"\\$computer\root\default:stdRegProv"
  $rtn = $wmi.SetStringValue($hkcu,$key,$property,$value)
  $rtn2 = $wmi.SetMultiStringValue($hkcu,$key,$property2,$aryValues)
  "Setting $property returned $($rtn.returnvalue)"
  "Setting $property2 returned $($rtn2.returnvalue)"
} #end Set-ieStartPage

# *** entry point to script 
if($get) {Get-ieStartpage}
if($set){Set-ieStartPage}