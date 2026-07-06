<#
.SYNOPSIS
    Provides the user with the possebility to retire (or wipe) the device of a user.
.DESCRIPTION
    This script creates a form that requires a username as input. Based on the specIfied username it will show the primary mobile devices of the specIfied 
    username. This provides the user with the option to retire a primary mobile device of the specIfied username.
.ParamETER SiteServer
    The site server of the primary site.
.ParamETER SiteCode
    The site code of the primary site.
.ParamETER AllowWipe
.LINK   
    http://www.petervanderwoude.nl
.EXAMPLE
    Retire-MobileDevice.ps1 -SiteServer CLDSRV02 -SiteCode PCP -AllowWipe
#>
[CmdletBinding()]

Param (
[Parameter(Mandatory=$True, HelpMessage="Site server with the SMS Provider.")]
[String]$SiteServer,
[Parameter(Mandatory=$True, HelpMessage="Site code of the Primary Site.")]
[String]$SiteCode,
[Parameter(Mandatory=$False, HelpMessage="When specIfied, the wipe button is shown.")]
[Switch]$AllowWipe
) 

#Function to load the form
Function Load-Form {
    $Form.Controls.Add($ButtonClose)
    $Form.Controls.Add($ButtonGet)
    $Form.Controls.Add($ButtonRetire)
    $Form.Controls.Add($DataGridView)
    $Form.Controls.Add($LabelBlog)
    $Form.Controls.Add($LabelTwitter)
    $Form.Controls.Add($LinkLabelBlog)
    $Form.Controls.Add($LinkLabelTwitter)
    $Form.Controls.Add($TextBoxUser)
    $Form.Controls.Add($GroupBoxDevice)
    $Form.Controls.Add($GroupBoxUser)

    If ($AllowWipe) {
        $Form.Controls.Add($ButtonWipe)
    }

	$Form.ShowDialog()
}

#Function to verify the provided user
Function Verify-User {
    Param (
    [String]$UserName
    )
    $User = Get-WmiObject -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer -Query "SELECT * FROM SMS_R_User WHERE UserName='$UserName'" -ErrorAction Stop
    If ($User -ne $Null) {
        Return $User.UserName
    }
    Else {
        $ErrorProvider.SetError($TextBoxUser, "Please verify the username") 
        [Windows.Forms.MessageBox]::Show(“Please provide an existing username”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error) 
    }
}

#Function to get the primary mobile devices of the user
Function Get-MobileDevices {
    Param (
    [String]$UserName
    )
    $Devices = Get-WmiObject -ComputerName $SiteServer -Namespace root/SMS/site_$($SiteCode) -Query "SELECT r.* FROM SMS_CM_RES_COLL_SMSDM001 r inner JOIN SMS_UserMachineRelationship m ON r.Name=m.ResourceName  WHERE m.UniqueUserName='PTCLOUD\\$UserName' AND m.Types = 1" -ErrorAction Stop
    If ($Devices -ne $Null) {
        ForEach ($Device in $Devices) {
            $DataGridView.Rows.Add($Device.ResourceID,$Device.Name,$Device.DeviceOS) | Out-Null
        }
    }
    Else {
        $ErrorProvider.SetError($TextBoxUser, "Please verify the username") 
        [Windows.Forms.MessageBox]::Show(“Please provide an user with a primary mobile device”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error) 
    }
}

#Function to wipe the mobile device
Function Wipe-MobileDevice {
    Param (
    [String]$MobileDeviceName
    )
    Invoke-WmiMethod -ComputerName $SiteServer -Namespace root/SMS/site_$($SiteCode) -Class SMS_DeviceMethods -Name RequestWipe -ArgumentList ($Null,$MobileDeviceName) -ErrorAction Stop
}

#Function to retire the mobile device
Function Retire-MobileDevice {
    Param (
    [String]$MobileDeviceName
    )
    Invoke-WmiMethod -ComputerName $SiteServer -Namespace root/SMS/site_$($SiteCode) -Class SMS_DeviceMethods -Name RequestRetire -ArgumentList ($MobileDeviceName) -ErrorAction Stop
}

#ButtonClose OnClick event to close the form
$ButtonClose_OnClick= {
	$Form.Close()
}

#ButtonGet OnClick event to get the primary mobile devices of the provided user
$ButtonGet_OnClick= {
    Try {
        $ErrorProvider.SetError($TextBoxUser,"")

        If ($DataGridView.RowCount -ne 0) {
            $DataGridView.Rows.Clear()
            $ButtonRetire.Enabled =  $False
            $ButtonWipe.Enabled =  $False                          
        }

        If($TextBoxUser.Text.Length -eq 0) {
            $ErrorProvider.SetError($TextBoxUser, "Please verify the username") 
            [Windows.Forms.MessageBox]::Show(“Please provide a valid username”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)         
        }
        Else {
            $User = Verify-User $TextBoxUser.Text
            If ($User -ne "OK") {
                Get-MobileDevices $User
            }
        }
    }
    Catch {
        [Windows.Forms.MessageBox]::Show(“Please verify the connection with the specified site server”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
    }
}

#ButtonRetire OnClick event to perform the retire action, including verification, of the selected mobile device
$ButtonRetire_OnClick= {
    Try {
        $ErrorProvider.SetError($TextBoxUser,"")

        $ResourceId = $DataGridView.CurrentRow.Cells[0].Value
        $VerIfcation = [Windows.Forms.MessageBox]::Show(“Are you sure that you want to retire the mobile device with the ResourceId '$ResourceId'?”, “Verification”, [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Question)
        If ($VerIfcation -eq "Yes") { 
            Retire-MobileDevice $ResourceId
            [Windows.Forms.MessageBox]::Show(“The action to retire the mobile device is successful initiated.”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    }
    Catch {
        [Windows.Forms.MessageBox]::Show(“Please verify the selected mobile device”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
    }
}

#ButtonWipe OnClick event to perform the wipe action, including verification, of the selected mobile device
$ButtonWipe_OnClick= {
    Try {
        $ErrorProvider.SetError($TextBoxUser,"")

        $ResourceId = $DataGridView.CurrentRow.Cells[0].Value
        $VerIfcation = [Windows.Forms.MessageBox]::Show(“Are you sure that you want to wipe the mobile device with the ResourceId '$ResourceId'?”, “Verification”, [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Question)
        If ($VerIfcation -eq "Yes") { 
            Wipe-MobileDevice $ResourceId
            [Windows.Forms.MessageBox]::Show(“The action to wipe the mobile device is successful initiated.”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
        }
    }
    Catch {
        [Windows.Forms.MessageBox]::Show(“Please verify the selected mobile device”, “Retire/ Wipe Mobile Device”, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
    }
}

#TextBoxUser MouseHover event to show a tooltip about the required information
$TextBoxUser_MouseHover= {
    $Tip = "Enter the name of the user"
    $ToolTip.SetToolTip($This,$Tip)
}

#DataGridView CurrentCellChanged event to enable buttons based on the selection
$DataGridView_CurrentCellChanged= {
    $ButtonRetire.Enabled =  $True
    $ButtonWipe.Enabled =  $False

    If ($DataGridView.CurrentRow -ne $Null) {
        $ResourceOS = $DataGridView.CurrentRow.Cells[2].Value
        If ($ResourceOS -notlike "Microsoft Windows NT*" -and $AllowWipe -eq $True) {
            $ButtonWipe.Enabled =  $True
        }
    }
}

#LinkLabelBlog event to open a browser session to my blog
$LinkLabelBlog_OpenLink= {
    [System.Diagnostics.Process]::start($LinkLabelBlog.text)
}

#LinkLabelTwitter OpenLink event to open a browser session to my twitter page
$LinkLabelTwitter_OpenLink= {
    [System.Diagnostics.Process]::start("http://twitter.com/pvanderwoude")
}

#Load Assemblies
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

#Create ToolTip
$ToolTip = New-Object System.Windows.Forms.ToolTip

#Create ErrorProvider
$ErrorProvider = New-Object System.Windows.Forms.ErrorProvider
$ErrorProvider.BlinkStyle = "NeverBlink"

#Create Form
$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(510,390)  
$Form.MinimumSize = New-Object System.Drawing.Size(510,390)
$Form.MaximumSize = New-Object System.Drawing.Size(510,390)
$Form.SizeGripStyle = "Hide"
$Form.Text = "Retire/ Wipe Mobile Device"
$Form.ControlBox = $True
$Form.TopMost = $True

#Create ButtonClose
$ButtonClose = New-Object System.Windows.Forms.Button
$ButtonClose.Location = New-Object System.Drawing.Size(320,290)
$ButtonClose.Size = New-Object System.Drawing.Size(150,25)
$ButtonClose.Text = "Close"
$ButtonClose.add_Click($ButtonClose_OnClick)

#Create ButtonGet
$ButtonGet = New-Object System.Windows.Forms.Button
$ButtonGet.Location = New-Object System.Drawing.Size(320,30)
$ButtonGet.Size = New-Object System.Drawing.Size(150,25)
$ButtonGet.Text = "Get"
$ButtonGet.add_Click($ButtonGet_OnClick)

#Create ButtonRetire
$ButtonRetire = New-Object System.Windows.Forms.Button
$ButtonRetire.Location = New-Object System.Drawing.Size(20,290)
$ButtonRetire.Size = New-Object System.Drawing.Size(150,25)
$ButtonRetire.Text = "Retire"
$ButtonRetire.Enabled = $False
$ButtonRetire.add_Click($ButtonRetire_OnClick)

#Create ButtonWipe
$ButtonWipe = New-Object System.Windows.Forms.Button
$ButtonWipe.Location = New-Object System.Drawing.Size(170,290)
$ButtonWipe.Size = New-Object System.Drawing.Size(150,25)
$ButtonWipe.Text = "Wipe"
$ButtonWipe.Enabled = $False
$ButtonWipe.add_Click($ButtonWipe_OnClick)

#Create DataGriView1
$DataGridView = New-Object System.Windows.Forms.DataGridView
$DataGridView.Location = New-Object System.Drawing.Size(20,95)
$DataGridView.Size = New-Object System.Drawing.Size(450,170)
$DataGridView.AllowUserToAddRows = $False
$DataGridView.AllowUserToDeleteRows = $False
$DataGridView.AllowUserToResizeRows = $False
$DataGridView.Anchor = "Top, Bottom, Left, Right"
$DataGridView.BackGroundColor = "White"
$DataGridView.ColumnCount = 3
$DataGridView.ColumnHeadersHeightSizeMode = "DisableResizing"
$DataGridView.ColumnHeadersVisible = $True
$DataGridView.Columns[0].Name = "Resource ID"
$DataGridView.Columns[0].AutoSizeMode = "Fill"
$DataGridView.Columns[1].Name = "Device Name"
$DataGridView.Columns[1].AutoSizeMode = "Fill"
$DataGridView.Columns[2].Name = "Device Platform"
$DataGridView.Columns[2].AutoSizeMode = "Fill"
$DataGridView.ReadOnly = $True
$DataGridView.RowHeadersWidthSizeMode = "DisableResizing"
$DataGridView.RowHeadersVisible = $False
$DataGridView.SelectionMode = "FullRowSelect"
$DataGridView.add_CurrentCellChanged($DataGridView_CurrentCellChanged)

#Create GroupBoxDevice
$GroupBoxDevice = New-Object System.Windows.Forms.GroupBox
$GroupBoxDevice.Location = New-Object System.Drawing.Size(10,75) 
$GroupBoxDevice.Size = New-Object System.Drawing.Size(470,200) 
$GroupBoxDevice.Text = "Primary Mobile Devices"

#Create GroupBoxUser
$GroupBoxUser = New-Object System.Windows.Forms.GroupBox
$GroupBoxUser.Location = New-Object System.Drawing.Size(10,10) 
$GroupBoxUser.Size = New-Object System.Drawing.Size(170,55) 
$GroupBoxUser.Text = "Primary User"

#Create LabelBlog
$LabelBlog = New-Object System.Windows.Forms.Label
$LabelBlog.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
$LabelBlog.Location = New-Object System.Drawing.Size(20,330) 
$LabelBlog.Size = New-Object System.Drawing.Size(48,23)
$LabelBlog.Text = "My blog:"
        
#Create LabelTwitter
$LabelTwitter = New-Object System.Windows.Forms.Label
$LabelTwitter.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
$LabelTwitter.Location = New-Object System.Drawing.Size(270,330) 
$LabelTwitter.Size = New-Object System.Drawing.Size(111,23)
$LabelTwitter.Text = "Follow me on twitter:"

#Create LinkLabelBlog
$LinkLabelBlog = New-Object System.Windows.Forms.LinkLabel
$LinkLabelBlog.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
$LinkLabelBlog.Location = New-Object System.Drawing.Size(68,330) 
$LinkLabelBlog.Size = New-Object System.Drawing.Size(142,23) 
$LinkLabelBlog.Text = "www.petervanderwoude.nl"
$LinkLabelBlog.add_Click($LinkLabelBlog_OpenLink)

#Create LinkLabelTwitter
$LinkLabelTwitter = New-Object System.Windows.Forms.LinkLabel
$LinkLabelTwitter.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
$LinkLabelTwitter.Location = New-Object System.Drawing.Size(379,330) 
$LinkLabelTwitter.Size = New-Object System.Drawing.Size(90,23)
$linkLabelTwitter.Text = "@pvanderwoude"
$LinkLabelTwitter.add_Click($LinkLabelTwitter_OpenLink)

#Create TextBoxUser
$TextBoxUser = New-Object System.Windows.Forms.TextBox
$TextBoxUser.Location = New-Object System.Drawing.Size(20,30)
$TextBoxUser.Size = New-Object System.Drawing.Size(150,25)
$TextBoxUser.add_MouseHover($TextBoxUser_MouseHover)

#Load form
Load-Form