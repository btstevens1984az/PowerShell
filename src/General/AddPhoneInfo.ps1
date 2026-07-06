# Purpose: AddPhoneInfo — General-purpose PowerShell utilities.
function Add-PhoneInfo
{
    param ( [string]$Username, 
            [int]$Extension, 
            [switch]$AllowFax )
    
    write-host "Inserting record: "
    write-host "  $Username @ Ext: $Extension"
    if ($AllowFax)
        { write-host "  Doubles as fax line" }
    else
        { write-host "  Not a fax line" }
}

# AllowFax is present and therefore has a value of $true
Add-PhoneInfo -Username JohnSmith -Extension 1273 -AllowFax

# AllowFax is not present, but the extension is of wrong type anyway
Add-PhoneInfo -Username JaneSmith -Extension A387

# AllowFax is present and $false is being passed in by position
Add-PhoneInfo -Username JaneSmith -Extension 7781 -AllowFax $false

# AllowFax is present but is assigned $false through switch syntax
Add-PhoneInfo -Username JaneSmith -Extension 7781 -AllowFax:$false

#The above switch syntax can be useful we overriding a confirmation i.e. -confirm:$false