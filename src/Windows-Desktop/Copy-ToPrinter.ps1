<#
.SYNOPSIS
    Copy-ToPrinter - Prints the current script from the ISE or a file passed the the Path parameter from the console.
.DESCRIPTION
		This script prints a PowerShell script.
    File Name: Copy-ToPrinter.ps1
    Requires: Powershell V2
.LINK
    "http://unlockpowershell.wordpress.com/2011/12/30/print-from-powershells-integrated-scripting-environment/"
    "http://gallery.technet.microsoft.com/Script-to-copy-the-c55f0106"
    "http://www.leeholmes.com/blog/2009/02/03/more-powershell-syntax-highlighting/"

.INPUTS
	Requires a file be open in the ISE, or a file path and name passed to the Path parameter.
.OUTPUTS
    This script outputs a formatted HTML version of the script with line numbers.
.EXAMPLE
    .\Copy-ToPrinter.ps1
    __________
    Prints the contents of the current PowerShell ISE tab.
.EXAMPLE
    .\Copy-ToPrinter.ps1 -Path C:\scripts\Find-EmptyGroups.ps1
    __________
    Prints the contents of the file C:\scripts\Find-EmptyGroups.ps1.
.EXAMPLE
    Get-ChildItem -Path C:\scripts\Find-DisabledMailbox.ps1 | .\Copy-ToPrinter.ps1
    __________
    Prints the contents of the file C:\scripts\Find-DisabledMailbox.ps1.
#>

param(
[Parameter(
Position = 0,
ValueFromPipeline=$true,
Mandatory = $false,
HelpMessage = "The path of the file"
)]
[string] $Path
)
Set-StrictMode -Version 2
$CompatibilityMode = $false
$tokenColours = @{
    'Attribute' = 'DarkCyan'
    'Command' = 'Blue'
    'CommandArgument' = 'Magenta'
    'CommandParameter' = 'DarkBlue'
    'Comment' = 'DarkGreen'
    'GroupEnd' = 'Black'
    'GroupStart' = 'Black'
    'Keyword' = 'DarkBlue'
    'LineContinuation' = 'Black'
    'LoopLabel' = 'DarkBlue'
    'Member' = 'Black'
    'NewLine' = 'Black'
    'Number' = 'Magenta'
    'Operator' = 'DarkGray'
    'Position' = 'Black'
    'StatementSeparator' = 'Black'
    'String' = 'DarkRed'
    'Type' = 'DarkCyan'
    'Unknown' = 'Black'
    'Variable' = 'Red'
} 
function Append-HtmlSpan ($block, $tokenColor){ 
    if (($tokenColor -eq 'NewLine') -or ($tokenColor -eq 'LineContinuation')){ 
        if($tokenColor -eq 'LineContinuation'){ 
            $null = $codeBuilder.Append('`')
        }
        $null = $codeBuilder.Append("<br />`r`n") 
        $null = $lineBuilder.Append("{0:000}<BR />" -f $currentLine) 
		$SCRIPT:currentLine++ 
	}
    else{
        $block = [System.Web.HttpUtility]::HtmlEncode($block) 
        if (-not $block.Trim()){
            $block = $block.Replace(' ', '&nbsp;')
        }
        $htmlColor = $tokenColours[$tokenColor].ToString().Replace('#FF', '#')
        if($tokenColor -eq 'String' -or $tokenColor -eq 'Comment' ){
            $lines = $block -split "`r`n"
            $block = ""
            $multipleLines = $false 
            foreach($line in $lines){ 
                if($multipleLines){
                    $block += "<BR />`r`n"
                    $null = $lineBuilder.Append("{0:000}<BR />" -f $currentLine)
					$SCRIPT:currentLine++
                }
                $newText = $line.TrimStart()
                $newText = "&nbsp;" * ($line.Length - $newText.Length) + $newText
                $block += $newText
                $multipleLines = $true
            }
        }
        $null = $codeBuilder.Append("<span style='color:$htmlColor'>$block</span>")
    }
} 
function GetHtmlClipboardFormat($html, $Caller){
$header = @"
Version:1.0
StartHTML:0000000000
EndHTML:0000000000
StartFragment:0000000000
EndFragment:0000000000
StartSelection:0000000000
EndSelection:0000000000
SourceURL:file:///about:blank
<!DOCTYPE HTML PUBLIC `"-//W3C//DTD HTML 4.0 Transitional//EN`">
<HTML>
<HEAD> 
<TITLE>HTML Clipboard</TITLE> 
</HEAD> 
<BODY> 
<!--StartFragment--> 
<DIV CLASS='footerstyle'></DIV>
<DIV style='font-family:Consolas,Lucida Console; font-size:10pt; 
    width:950; border:0px solid black; padding:5px'> 

<TABLE BORDER='0' cellpadding='5' cellspacing='0'> 
<TR> 
    <TD VALIGN='Top'> 
<DIV style='font-family:Consolas,Lucida Console; font-size:10pt; 
    padding:5px; background:#cecece'> 
__LINES__ 
</DIV> 
    </TD> 
    <TD VALIGN='Top' NOWRAP='NOWRAP'> 
<DIV style='font-family:Consolas,Lucida Console; font-size:10pt; 
    padding:5px; background:#fcfcfc'> 
__HTML__ 
</DIV> 
    </TD> 
</TR> 
</TBODY> 
</TABLE> 
</DIV> 
<!--EndFragment--> 
</BODY> 
</HTML> 
"@ 
    $header = $header.Replace("__LINES__", $lineBuilder.ToString())
    $startFragment = $header.IndexOf("<!--StartFragment-->") +
        "<!--StartFragment-->".Length + 2
    $endFragment = $header.IndexOf("<!--EndFragment-->") +
        $html.Length - "__HTML__".Length
    $startHtml = $header.IndexOf("<!DOCTYPE")
    $endHtml = $header.Length + $html.Length - "__HTML__".Length
    if ($Caller -eq "Print"){
        $header = $header.Replace("Version:1.0","")
        $header = $header.Replace("StartHTML:0000000000","")
        $header = $header.Replace("EndHTML:0000000000","")
        $header = $header.Replace("StartFragment:0000000000","")
        $header = $header.Replace("EndFragment:0000000000","")
        $header = $header.Replace("StartSelection:0000000000","")
        $header = $header.Replace("EndSelection:0000000000","")
        $header = $header.Replace("SourceURL:file:///about:blank","")
    }
    else{
        $header = $header -replace "StartHTML:0000000000", ("StartHTML:{0:0000000000}" -f $startHtml) 
        $header = $header -replace "EndHTML:0000000000", ("EndHTML:{0:0000000000}" -f $endHtml) 
        $header = $header -replace "StartFragment:0000000000", ("StartFragment:{0:0000000000}" -f $startFragment) 
        $header = $header -replace "EndFragment:0000000000", ("EndFragment:{0:0000000000}" -f $endFragment) 
        $header = $header -replace "StartSelection:0000000000", ("StartSelection:{0:0000000000}" -f $startFragment) 
        $header = $header -replace "EndSelection:0000000000", ("EndSelection:{0:0000000000}" -f $endFragment) 
    }
    if($Host.Name -eq 'Windows PowerShell ISE Host'){
        $header = $header.Replace("HTML Clipboard",$psise.CurrentFile.DisplayName)
    }
    $header = $header.Replace("__HTML__", $html)
    Write-Verbose $header
    $header
}
function Copy-ToPrinter{
    Add-Type -Assembly PresentationCore
    Add-Type -Assembly System.Web
    $SCRIPT:currentLine = 1
    if($Host.Name -eq 'Windows PowerShell ISE Host'){
        if ($psise.CurrentFile.Editor.SelectedText.Length -eq 0){
		    $text = $psise.CurrentFile.Editor.Text
	    }
        else{
    		$text = $psise.CurrentFile.Editor.SelectedText
	    }
    }
    elseif($Path){
        $text = (Get-Content $Path) -join "`r`n"
    }
    trap { break }
    # Do syntax parsing.
    $errors = $null
    $tokens = [system.management.automation.psparser]::Tokenize($Text, [ref] $errors)
	# Initialize HTML builder.
    $codeBuilder = new-object system.text.stringbuilder
    $lineBuilder = new-object system.text.stringbuilder
    $null = $lineBuilder.Append("{0:000}<BR />" -f $currentLine)
	$SCRIPT:currentLine ++
	# Iterate over the tokens and set the colors appropriately.
    $position = 0
    foreach ($token in $tokens){
        if ($position -lt $token.Start){
		    $block = "Second"
            $block = $text.Substring($position, ($token.Start - $position))
            $tokenColor = 'Unknown'
            Append-HtmlSpan $block $tokenColor
        }
		$block = "First"
        $block = $text.Substring($token.Start, $token.Length)
        $tokenColor = $token.Type.ToString()
        Append-HtmlSpan $block $tokenColor
        $position = $token.Start + $token.Length
    }
    $code = $codeBuilder.ToString()
    $html = GetHtmlClipboardFormat $code "Print"
    if ((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation") -match "AllSitesCompatibilityMode"){
        $CompatibilityMode = $true
    }
    if ($CompatibilityMode){
        if ((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation").AllSitesCompatibilityMode -eq 0){
            $CompatabilityBefore = 0
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation" -Name AllSitesCompatibilityMode -Value 1
        }
    }
    $IEApplication = New-Object -ComObject InternetExplorer.Application -Verbose
    $IEApplication.Navigate2("about:blank",14)
    $IEApplication.Visible = $false
    if($Host.Name -eq 'Windows PowerShell ISE Host'){
        $IEApplication.Document.frames.document.title = $psise.CurrentFile.DisplayName
    }
    Else{
        $IEApplication.Document.frames.document.title = (Split-Path -Path $Path -Leaf)
    }
    $IEApplication.Document.body.innerHTML = $html
    while ($IEApplication.busy) {Start-Sleep -Seconds 1}
    Start-Sleep -Seconds 1
        if ((Get-WmiObject -Class win32_operatingsystem).version -gt 10){
        $IEApplication.Visible = $true
    }
    $IEApplication.ExecWB(7,2)
    #region cleanup
    while ($IEApplication.busy) {Start-Sleep -Seconds 1}
    $IEApplication.Quit()
    if ($CompatibilityMode){
        if ($CompatabilityBefore -eq 0){
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation" -Name AllSitesCompatibilityMode -Value 0
       }
    }
    #endregion
}
Copy-ToPrinter -Path $Path