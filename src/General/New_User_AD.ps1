# Purpose: New User AD — General-purpose PowerShell utilities.
<#
LINK: https://github.com/PazzoBread/New_User_GUI
Description: Creates a new user in active directory based on information filled out in the form.
Required fields are Name and Company, all other fields are optional (but useful if filled in). If 
the mirror field is populated, the new user will join the groups that the mirror user is apart of. 
Location field will population Office location. Manager Field will populate manager. Department field
will populate department. Employee ID field will populate the EmployeeID field in extended attibutes. 
Display name will use full name if left blank, if not blank the user account will have a different 
display name compared to the full name of the account. 
Add your server info and such below. Adjust lines 123,124,180,208,212
#>

$Exchange_Server = "servername"
$Azure_Server = "SERVERNAME"
$UPN_HomeDirectory = "PATH";
$UPN_HomeLetter = "P";
$Path_Output = "Outputfiledirectoryhere" 

Import-Module ActiveDirectory

#START Create_User Function*********************************************************************************************************************************
function Create_User () 
{
#START Input | Takes the info from GUI and declares some vars we will need at some point
$Bar_Progress.Value = '10'
$Form_Arrivals.Refresh()
$Name = $Input_Name.text;
$Name = $Name.Split();
$DisplayName = $Input_DisplayName.text;
$Department = $Input_Department.text; 
$EID = $Input_EID.text;
$Error = 0
$Title = $Input_Title.text;
$Manager = $Input_Manager.text;
$Location = $Input_Location.text;
$Mirror = $Input_Mirror.text;
$Date = Get-Date -Format "yyyy.MM.dd"
$DateAndTime = Get-Date 
#END Input **************************************************************************************************************************************************************

#START Convert to shorthad | Convert to shorthand divisions for rest of script

if ($Input_Company.SelectedItem -eq '1')
{
$Company = "1"
}
elseif ($Input_Company.SelectedItem  -eq "2")
{
$Company = "2"
}
elseif ($Input_Company.SelectedItem  -eq "3")
{
$Company = "3"
}
elseif ($Input_Company.SelectedItem  -eq "4")
{
$Company = "4"
}
elseif ($Input_Company.SelectedItem  -eq "5")
{
$Company = "5"
}
elseif ($Input_Company.SelectedItem  -eq "6")
{
$Company = "6"
}
elseif ($Input_Company.SelectedItem  -eq "7")
{
$Company = "7" 
}
elseif ($Input_Company.SelectedItem  -eq "8")
{
$Company = "8"
}
elseif ($Input_Company.SelectedItem  -eq "9")
{
$Company = "9"
}
#END Covert to shorthand ************************************************************************************************************************************************


if ($Department -eq '' -and $Mirror -ne '') 
{
$Department = (Get-ADUser -Identity $Mirror -Properties Department).Department
}
elseif ($Department -eq '' -and $Manager -ne '') 
{
$Department = (Get-ADUser -Identity $Manager -Properties Department).Department
}

if($DisplayName -eq '')
{
$DisplayName = $Name; 
}


$UPN = $name[0].Substring(0, 1) + $name[1];
$UPN = $UPN.ToLower();

New-Item -ItemType directory -Path $UPN_HomeDirectory;

#ARRAY FOR RANDOM PASSWORD
$UPN_Password = Get-RandomCharacters -length 8 -characters 'abcdefghkmnprstuvwxyz'
$UPN_Password += Get-RandomCharacters -length 2 -characters '!?#@$' 
$UPN_Password += Get-RandomCharacters -length 2 -characters '23456789'
$UPN_Password = Scramble-String $UPN_Password

$Bar_Progress.Value = '20'
$Form_Arrivals.Refresh()

#CREATE USER
New-ADUser `
-Name "$DisplayName" `
-DisplayName "$DisplayName" `
-GivenName $Name[0] `
-Surname $Name[1] `
-SamAccountName "$UPN" `
-UserPrincipalName "$UPN@EXAMPLE.com" `
-Path "CN=Users,DC=EXAMPLE,DC=com" `
-AccountPassword (ConvertTo-SecureString "$UPN_Password" -AsPlainText -Force) `
-ChangePasswordAtLogon $True `
-Enabled $True `
-Company "$Company" `
-Department "$Department" `
-Office "$Location" `
-Title "$Title" `
-Description "$Title" `
-HomeDirectory $UPN_HomeDirectory `
-HomeDrive $UPN_HomeLetter `
-EmployeeID $EID `
-Manager $Manager;

$Bar_Progress.Value = '30'
$Form_Arrivals.Refresh()

Sleep -seconds 7 
$Was_UPN_Created = Get-ADUser -f "sAMAccountName -eq '$UPN'"

if ($Was_UPN_Created -eq $null -and $Error -ne '1')
{
[System.Windows.MessageBox]::Show("Account was not created!",'New User Account','OK','Error')
$Error = 1
$Bar_Progress.Value = '0'
$Form_Arrivals.Refresh()
}

if ($Error -ne '1')
{

$Bar_Progress.Value = '40'
$Form_Arrivals.Refresh()

 if ($Input_Physician.SelectedItem -eq 'Yes') 
 {
 #Add-ADGroupMember -Identity "" -Members $UPN
 #Add-ADGroupMember -Identity "" -Members $UPN
 $Bar_Progress.Value = '45'
$Form_Arrivals.Refresh()
 }

 if ($Input_Shareholder.SelectedItem -eq 'Yes') 
 {
 #Add-ADGroupMember -Identity "" -Members $UPN
 #Add-ADGroupMember -Identity "" -Members $UPN
 $Bar_Progress.Value = '50'
 $Form_Arrivals.Refresh()
 }

 #Set folder permissions on home folder
 try 
 {
$Bar_Progress.Value = '70'
$Form_Arrivals.Refresh()
$ACL = Get-ACL -Path "$UPN_HomeDirectory"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("domain\$UPN", "FullControl","ContainerInherit,ObjectInherit", "None","Allow") 
$ACL.SetAccessRule($AccessRule) 
$ACL | Set-Acl -Path "$UPN_HomeDirectory"
}
 catch 
 {
[System.Windows.MessageBox]::Show("Error granting full access to home folder. Please manually set permission on folder.",'New User Account','OK','Error')
}

#Mirror groups for one user to another
if ($Mirror -ne "" -and $Error -ne '1') 
{
try 
{
Get-ADUser -Identity $Mirror -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $UPN 
}
catch
{
[System.Windows.MessageBox]::Show("Error mirroring accounts, please verify groups manually.",'New User Account','OK','Error')
}

}

$Bar_Progress.Value = '80'
$Form_Arrivals.Refresh()
 #Mailbox enable for Office 365
 try
 {
$Session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri http://onpremserver/PowerShell/ -Authentication Kerberos -Credential $AdminAccount
Sleep -Seconds 3
Import-PSSession -AllowClobber $Session -DisableNameChecking
Sleep -Seconds 3
Enable-RemoteMailbox -Identity:"$DisplayName" -RemoteRoutingAddress "$UPN@example.mail.onmicrosoft.com" 
Remove-PSSession $Session
 }
 catch
 {
 [System.Windows.MessageBox]::Show("Error creating remote mailbox. Please manually create via powershell.",'New User Account','OK','Error')
 }
$Bar_Progress.Value = '100'
$Form_Arrivals.Refresh()
if ($Error -ne '1') 
{
[System.Windows.MessageBox]::Show("Account has been created sucessfully!",'New User Account','OK')
}
elseif ($Error -eq '1')
{
[System.Windows.MessageBox]::Show("An error was detected. Please verify account manually.",'New User Account','OK','Error')

}
#Create output file and display on screen
$Path_Output = "$Path_Output - $DisplayName.txt"
Set-Content -Path "$Path_Output" `
-Value "Created by $env:username on $DateAndTime`r`nUsername: $UPN`r`nPassword: $UPN_Password`r`nManager: $Manager`r`nDepartment: $Department`r`nJob Title: $Title`r`nOffice: $Location`r`nCompany: $Company`r`nMirrored: $Mirror`r`n`r`nGroup Membership:";
Get-ADPrincipalGroupMembership "$UPN" | Select -expandproperty name | Add-Content "$Path_Output" 
$Output_Main.text = Get-Content $Path_Output -Delimiter "\n"
}

#End User Create
}
#END Create_User Function***********************************************************************************************************************************



#START Get-RandomCharacters Function************************************************************************************************************************
function Get-RandomCharacters($length, $characters)
{ 
 #This is resposbile for selecting random characters out of the array in the Create_User function
 $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length 
}
$private:ofs=""
return [String]$characters[$random]
}
#END Get-RandomCharacters Function**************************************************************************************************************************



#START Scramble-String Function*****************************************************************************************************************************
function Scramble-String([string]$inputString)  
{   
#This scrables the random characters selection to maximize the amount of different passwords 
$characterArray = $inputString.ToCharArray()   
$scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
$outputString = -join $scrambledStringArray
return $outputString 
}
#END Scramble-String Function*******************************************************************************************************************************



#START Validate_Input***************************************************************************************************************************************
function Validate_Input () 
{
$Bar_Progress.Value = '0'
$Form_Arrivals.Refresh()
$Validate_Name = $Input_Name.text;
$Validate_Name = $Validate_Name.Split();
$Validate_UPN = $Validate_Name[0].Substring(0, 1) + $Validate_Name[1];
$UPN_Exists = Get-ADUser -f "sAMAccountName -eq '$Validate_UPN'"
$Continue = 1

#Verify a name has been entered correctly.
if($Validate_Name.length -le 1 -and $Continue -eq '1') #Check Name
{
[System.Windows.MessageBox]::Show('Please enter the full name of the new user!','Name Input','OK','Error')
$Continue = 0
} 

#Verify Company is selected correctly. 
if ($Input_Company.SelectedItem -ne '1' -and $Input_Company.SelectedItem -ne '2' -and $Input_Company.SelectedItem -ne '3' -and $Input_Company.SelectedItem -ne '4' -and $Input_Company.SelectedItem -ne '5' -and $Input_Company.SelectedItem -ne '6' -and $Input_Company.SelectedItem -ne '7' -and $Input_Company.SelectedItem -ne '8' -and $Input_Company.SelectedItem -ne '9' -and $Continue -eq '1')
{   
[System.Windows.MessageBox]::Show('Please select a company!','Company Input','OK','Error')
$Continue = 0
}

#Verify our username is availible.
if ($UPN_Exists -ne $null -and $Continue -eq '1')
{
[System.Windows.MessageBox]::Show("Username already exists!",'New User Account','OK','Error')
$Continue = 0
}

if ($Continue -eq '1')  
{ 
Create_User
}
else 
{
[System.Windows.MessageBox]::Show("Error validating input, cannot continue!",'New User Account','OK','Error')
}

#END Validate
}
#END Validate_Input*****************************************************************************************************************************************



#START Azure_Sync*******************************************************************************************************************************************
function Azure_Sync () 
{
$Bar_Progress.Value = '0'
$Form_Arrivals.Refresh()
Invoke-Command -ComputerName $Azure_Server -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta } -credential $AdminAccount
$Bar_Progress.Value = '100'
$Form_Arrivals.Refresh()
}
#END Azure_Sync*********************************************************************************************************************************************

function Active_Directory ()
{
C:\windows\system32\dsa.msc
}

#START Generate GUI ****************************************************************************************************************************************
function Create_User_Form () 
{

$Form_Arrivals                        = New-Object system.Windows.Forms.Form
$Form_Arrivals.ClientSize             = New-Object System.Drawing.Point(750,650)
$Form_Arrivals.text                   = "New Arrivals"
$Form_Arrivals.Topmost =$True

$Label_Name                      = New-Object system.Windows.Forms.Label
$Label_Name.text                 = "Full Name*"
$Label_Name.AutoSize             = $true
$Label_Name.width                = 25
$Label_Name.height               = 10
$Label_Name.location             = New-Object System.Drawing.Point(35,40)
$Label_Name.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_DisplayName                   = New-Object system.Windows.Forms.Label
$Label_DisplayName.text              = "Display Name"
$Label_DisplayName.AutoSize          = $true
$Label_DisplayName.width             = 25
$Label_DisplayName.height            = 10
$Label_DisplayName.location          = New-Object System.Drawing.Point(35,80)
$Label_DisplayName.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_EID                       = New-Object system.Windows.Forms.Label
$Label_EID.text                   = "Employee ID"
$Label_EID.AutoSize               = $true
$Label_EID.width                  = 25
$Label_EID.height                 = 10
$Label_EID.location               = New-Object System.Drawing.Point(35,120)
$Label_EID.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Department                = New-Object system.Windows.Forms.Label
$Label_Department.text           = "Department"
$Label_Department.AutoSize       = $true
$Label_Department.width          = 25
$Label_Department.height         = 10
$Label_Department.location       = New-Object System.Drawing.Point(35,160)
$Label_Department.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Title                     = New-Object system.Windows.Forms.Label
$Label_Title.text                = "Title"
$Label_Title.AutoSize            = $true
$Label_Title.width               = 25
$Label_Title.height              = 10
$Label_Title.location            = New-Object System.Drawing.Point(35,200)
$Label_Title.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Manager                       = New-Object system.Windows.Forms.Label
$Label_Manager.text                  = "Manager (Enter Username)"
$Label_Manager.AutoSize              = $true
$Label_Manager.width                 = 25
$Label_Manager.height                = 10
$Label_Manager.location              = New-Object System.Drawing.Point(35,240)
$Label_Manager.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Location                  = New-Object system.Windows.Forms.Label
$Label_Location.text             = "Location"
$Label_Location.AutoSize         = $true
$Label_Location.width            = 25
$Label_Location.height           = 10
$Label_Location.location         = New-Object System.Drawing.Point(35,279)
$Label_Location.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Label_Physician                 = New-Object system.Windows.Forms.Label
$Label_Physician.text            = "Physician"
$Label_Physician.AutoSize        = $true
$Label_Physician.width           = 25
$Label_Physician.height          = 10
$Label_Physician.location        = New-Object System.Drawing.Point(35,320)
$Label_Physician.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Shareholder               = New-Object system.Windows.Forms.Label
$Label_Shareholder.text          = "Shareholder"
$Label_Shareholder.AutoSize      = $true
$Label_Shareholder.width         = 25
$Label_Shareholder.height        = 10
$Label_Shareholder.location      = New-Object System.Drawing.Point(35,359)
$Label_Shareholder.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Company                   = New-Object system.Windows.Forms.Label
$Label_Company.text              = "Company*"
$Label_Company.AutoSize          = $true
$Label_Company.width             = 25
$Label_Company.height            = 10
$Label_Company.location          = New-Object System.Drawing.Point(35,400)
$Label_Company.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Label_Mirror                   = New-Object system.Windows.Forms.Label
$Label_Mirror.text              = "Mirror (Enter Username)"
$Label_Mirror.AutoSize          = $true
$Label_Mirror.width             = 25
$Label_Mirror.height            = 10
$Label_Mirror.location          = New-Object System.Drawing.Point(35,440)
$Label_Mirror.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label_Progress                   = New-Object system.Windows.Forms.Label
$Label_Progress.text              = "Progress"
$Label_Progress.AutoSize          = $true
$Label_Progress.width             = 25
$Label_Progress.height            = 10
$Label_Progress.location          = New-Object System.Drawing.Point(535,505)
$Label_Progress.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Input_Name                       = New-Object system.Windows.Forms.TextBox
$Input_Name.multiline             = $false
$Input_Name.width                 = 120
$Input_Name.height                = 20
$Input_Name.location              = New-Object System.Drawing.Point(240,40)
$Input_Name.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_DisplayName               = New-Object system.Windows.Forms.TextBox
$Input_DisplayName.multiline      = $false
$Input_DisplayName.width          = 120
$Input_DisplayName.height         = 20
$Input_DisplayName.location       = New-Object System.Drawing.Point(240,80)
$Input_DisplayName.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_EID                       = New-Object system.Windows.Forms.TextBox
$Input_EID.multiline             = $false
$Input_EID.width                 = 120
$Input_EID.height                = 20
$Input_EID.location              = New-Object System.Drawing.Point(240,120)
$Input_EID.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Department                = New-Object system.Windows.Forms.TextBox
$Input_Department.multiline       = $false
$Input_Department.width           = 120
$Input_Department.height          = 20
$Input_Department.location        = New-Object System.Drawing.Point(240,160)
$Input_Department.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Title                      = New-Object system.Windows.Forms.TextBox
$Input_Title.multiline            = $false
$Input_Title.width                = 120
$Input_Title.height               = 20
$Input_Title.location             = New-Object System.Drawing.Point(240,200)
$Input_Title.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Manager                    = New-Object system.Windows.Forms.TextBox
$Input_Manager.multiline          = $false
$Input_Manager.width              = 120
$Input_Manager.height             = 20
$Input_Manager.location           = New-Object System.Drawing.Point(240,240)
$Input_Manager.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Location                   = New-Object system.Windows.Forms.TextBox
$Input_Location.multiline         = $false
$Input_Location.width             = 120
$Input_Location.height            = 20
$Input_Location.location          = New-Object System.Drawing.Point(240,280)
$Input_Location.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Physician                 = New-Object system.Windows.Forms.ComboBox
$Input_Physician.text             = "Select"
$Input_Physician.width            = 120
$Input_Physician.height           = 20
@('Yes','No') | ForEach-Object {[void] $Input_Physician.Items.Add($_)}
$Input_Physician.location         = New-Object System.Drawing.Point(240,320)
$Input_Physician.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Shareholder                = New-Object system.Windows.Forms.ComboBox
$Input_Shareholder.text           = "Select"
$Input_Shareholder.width          = 120
$Input_Shareholder.height         = 20
@('Yes','No') | ForEach-Object {[void] $Input_Shareholder.Items.Add($_)}
$Input_Shareholder.location       = New-Object System.Drawing.Point(240,360)
$Input_Shareholder.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Company                    = New-Object system.Windows.Forms.ComboBox
$Input_Company.text               = "Select"
$Input_Company.width              = 120
$Input_Company.height             = 20
@('1','2','3','4','5','6','7','8','9') | ForEach-Object {[void] $Input_Company.Items.Add($_)}
$Input_Company.location           = New-Object System.Drawing.Point(240,400)
$Input_Company.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Input_Mirror                    = New-Object system.Windows.Forms.TextBox
$Input_Mirror.multiline          = $false
$Input_Mirror.width              = 120
$Input_Mirror.height             = 20
$Input_Mirror.location           = New-Object System.Drawing.Point(240,440)
$Input_Mirror.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Button_Sync                      = New-Object system.Windows.Forms.Button
$Button_Sync.text                 = "Azure Sync"
$Button_Sync.width                = 100
$Button_Sync.height               = 30
$Button_Sync.location             = New-Object System.Drawing.Point(240,525)
$Button_Sync.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button_Create                 = New-Object system.Windows.Forms.Button
$Button_Create.text            = "Create"
$Button_Create.width           = 100
$Button_Create.height          = 30
$Button_Create.location        = New-Object System.Drawing.Point(35,525)
$Button_Create.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button_AD                 = New-Object system.Windows.Forms.Button
$Button_AD.text            = "Open AD"
$Button_AD.width           = 100
$Button_AD.height          = 30
$Button_AD.location        = New-Object System.Drawing.Point(35,575)
$Button_AD.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Output_Main                       = New-Object system.Windows.Forms.TextBox
$Output_Main.text                  = "User Output will display here once complete"
$Output_Main.Multiline             = $True
$Output_Main.enabled               = $True
$Output_Main.width                 = 230
$Output_Main.height                = 380
$Output_Main.location              = New-Object System.Drawing.Point(450,40)

$Bar_Progress = New-Object System.Windows.Forms.ProgressBar
$Bar_Progress.Name = 'Bar_Progress'
$Bar_Progress.Value = '0'
$Bar_Progress.Style ="Continuous"
$Bar_Progress.width = 230
$Bar_Progress.Height = 30
$Bar_Progress.Location = New-Object System.Drawing.Point(450,525)

$Form_Arrivals.controls.AddRange(@($Bar_Progress, $Button_AD, $Label_Name, $Label_DisplayName, $Label_EID, $Label_Department, $Label_Title, $Label_Manager, $Label_Location ,$Label_Physician ,$Label_Shareholder ,$Label_Company ,$Label_Mirror,$Label_Progress ,$Input_Name ,$Input_DisplayName ,$Input_EID ,$Input_Department ,$Input_Title ,$Input_Manager ,$Input_Location ,$Input_Physician , $Input_Shareholder, $Input_Company, $Input_Mirror ,$Button_Sync, $Button_Create, $Output_Main))

$Button_Create.Add_Click({ Validate_Input })
$Button_Sync.Add_Click({ Azure_Sync })
$Button_AD.Add_Click({ Active_Directory})

$AdminAccount = Get-Credential -Message "Enter your Admin Account to create mailbox"

$Form_Arrivals.ShowDialog()
}
#END Generate GUI ******************************************************************************************************************************************


#Start the form
Create_User_Form 