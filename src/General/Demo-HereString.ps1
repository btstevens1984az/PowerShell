# Purpose: Demo-HereString — General-purpose PowerShell utilities.
# ------------------------------------------------------------------------
# DATE: 3/7/2009
#
# KEYWORDS: here string, here-string, read-host
#
# COMMENTS: This script demonstrates the use of a
# here string by assigning multiple lines of text to a variable
# when the user requests the instructions by typing y for
# the read-host prompt, it is displayed. 
#
# Windows PowerShell Best Practices
# ------------------------------------------------------------------------
$instructions = @"
This command line demo illustrates working with multiple lines 
of text. The cool thing about using a here string is that it allows
you to "work" with text without the need to "worry" about quoting
or other formating issues.
   It even allows you 
     a sort of 
       wysiwyg type of experience. 
You format the data as you wish it to appear. 
"@

$response = Read-Host -Prompt "Do you need instructions? <y / n>"
if ($response -eq "y") { $instructions ; exit }
else { "good by" ; exit }