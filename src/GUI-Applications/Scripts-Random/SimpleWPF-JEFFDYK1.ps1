# Purpose: SimpleWPF-JEFFDYK1 — PowerShell automation.
#http://huddledmasses.org/showui-tutorial-walkthrough/
Import-module ShowUI
$results =New-Grid -ControlName 'Your Information' -Columns Auto,* -Rows 7 -MinHeight 200 -MinWidth 250 {
     Label "First Name"
     New-TextBox -Name First -Column 1
     
     Label "Last Name" -Row 1 
     New-TextBox -Name Last -Row 1 -Column 1

     Label "Address" -Row 2
     New-TextBox -Name Address -Row 2 -Column 1

     Label "City" -Row 3 
     New-TextBox -Name City -Row 3 -Column 1

     Label "State" -Row 4
     New-TextBox -Name State -Row 4 -Column 1

     Label "Zip" -Row 5 
     New-TextBox -Name Zip -Row 5 -Column 1

     
     New-Button "OK" -IsDefault -On_Click {
         Get-ParentControl | Set-UIValue -PassThru | Close-Control
     } -Row 6 -Column 1
} -Show -On_Loaded { $First.Focus() }

