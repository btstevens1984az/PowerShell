# Purpose: GetEmail — General-purpose PowerShell utilities.
#function to parse text for valid email addresses and return them optionally delimited for pasting into an email program.
Function Get-Emailaddress
{[cmdletbinding()]
param(
[parameter(
    Mandatory=$true, 
    ValueFromPipeline=$true)]
    [AllowEmptyString()]
    [AllowNull()]
    [string[]]$string,
    [string]$Delimiter)
    begin{
        $regex ="\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b"
        $EmailAddresses = @()
    }
    Process
    {
        If ($string)
        {
        $EmailAddresses += $string  | Select-String -Pattern $regex -AllMatches |
        ForEach-Object{$_.matches.value} 
        }
        Else
        {
            write-verbose "skipping $string"

        }
    }
    end
    {
        $EmailAddresses = $EmailAddresses | Select-Object -Unique
        if ($Delimiter)
        { 
            $EmailAddresses -join $Delimiter
        }
        else
        {
            $EmailAddresses
        }
}
}

#get-content .\EmailAddresses.csv | Get-Emailaddress | Set-Clipboard
#https://en.wikipedia.org/wiki/Email_address
#Get-Clipboard | Get-Emailaddress -Delimiter ';'