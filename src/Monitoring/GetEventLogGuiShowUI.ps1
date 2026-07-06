# Purpose: GetEventLogGuiShowUI — System monitoring and alerting.
#http://showui.codeplex.com/
Import-Module Showui
$getEventInput = New-StackPanel -ControlName 'Get-EventLogsSinceDate' {            
    New-Label -VisualStyle 'MediumText' "Log Name"            
    New-ComboBox -IsEditable:$false -SelectedIndex 0 -Name LogName @("Application", "Security", "System", "Setup")            
    New-Label -VisualStyle 'MediumText' "Get Event Logs Since..."   
	New-TextBox -Name "computer" -Text "Enter a computer name or . for localhost"
    Select-Date -Name After            
    New-Button "Get Events" -On_Click {            
        Get-ParentControl |            
            Set-UIValue -passThru |             
            Close-Control            
    }            
} -show            
$geteventinput.remove("togglebutton")
            
Get-EventLog @getEventInput | ? EntryType -eq "error" | ogv