Function Open-RemoteProfileCleanupGUI {
<#
.SYNOPSIS
This GUI allows you to remove local profiles from remote servers with Wmi.

.DESCRIPTION
This GUI allows you to remove local profiles from remote servers. Compatible with Windows 7 and above operating
systems with Wmi. 

Version: 1.0 
-> Initial Build

Version: 1.02
-> Added remote open \\238.75.124.57\c:\users - Row 379
#>



# Region Sections Main Form Settings And Paths
# Contains Settings, Path To Xml File, Profile csv file, Transcripts logs 
 # Form Settings 
   $MainForm = New-Object System.Windows.Forms.Form  
   $MainForm.Text = "ProfileTool - Version 1.01" 
   $MainForm.StartPosition = "CenterScreen" 
   $MainForm.Topmost = $false 
   $MainForm.Size = "800,650" 
   $MainForm.Icon = New-Object System.Drawing.Icon ("$PSScriptRoot\Data\Img\Logo\Logo.Ico")
 # End Form Settings 

 # ListView Xml Columns File
   $XmlFile = "$PsScriptRoot\Data\Database\ListViewColumns\ListViewColumn.xml"
   [XML]$Script:XML = Get-Content $XmlFile
 # End ListView Xml Columns File
        
 # ProfileAttributesCsvFile Db
   $ProfileAttributesCsvFile = "$PsScriptRoot\Data\Database\Csv\UserAttributes\UserAttributes.Csv" 
 # End ProfileAttributesCsvFile Db
         



# Region Sections Top Bar Menu
#Contains Topmenustrip,Submenus,
 # Top Menu
   $TopMenuStrip = New-Object System.Windows.Forms.MenuStrip 
   $TopMenuStrip.Location = "0,0" 
   $TopMenuStrip.Name = "MainMenu" 
   $TopMenuStrip.Size = "780, 24" 
   $TopMenuStrip.Text = "Main" 
   $MainForm.Controls.Add($TopMenuStrip) 

 # Top Menu - Menu File
   $StripMenuFile = New-Object System.Windows.Forms.ToolStripMenuItem 
   $StripMenuFile.Name = "MenuFile"
   $StripMenuFile.Size = "40,20" 
   $StripMenuFile.Text = "File" 
   [void]$TopMenuStrip.Items.Add($StripMenuFile) 
 # End Top Menu - Menu File

 # Menu File - Sub Menu - Close
   $FileClose = New-Object System.Windows.Forms.ToolStripMenuItem
   $FileClose.Name = "MenuFileQuit"
   $FileClose.Size = '186, 22'
   $FileClose.Text = "Close"
   $FileClose.Add_Click({ Function-CloseForm })
   Function Function-CloseForm 
            { # Start Function Close-Form
              $MainForm.Close() 
            } # End Function Close-Form
   [void]$StripMenuFile.DropDownItems.Add($FileClose)
 # End Menu File - Sub Menu - Close


 # Top Menu - Menu Tools
   $StripMenuTools = New-Object System.Windows.Forms.ToolStripMenuItem
   $StripMenuTools.Name = "MenuTools"
   $StripMenuTools.Size = "40,20"
   $StripMenuTools.Text = "Tools"
   [void]$TopMenuStrip.Items.Add($StripMenuTools)

        # Menu File - Sub Menu - Reboot Machine 
        $ToolsRebootMachine = New-Object System.Windows.Forms.ToolStripMenuItem 
        $ToolsRebootMachine.Name = "MenuToolsRebootMachine"
        $ToolsRebootMachine.Size = '186, 22'
        $ToolsRebootMachine.Text = "Reboot Machine"
        $ToolsRebootMachine.Add_Click({ Function-Reboot-Machine })
        Function Function-Reboot-Machine { # Start Function-Reboot-Machine
        $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable    
            # Confirmation-Form Reboot Machine
                # ConfirmationForm Settings
                $ConfirmationFormRebootMachine = New-Object System.Windows.Forms.Form 
                $ConfirmationFormRebootMachine.Text = "Confirmation"
                $ConfirmationFormRebootMachine.StartPosition = "CenterScreen"
                $ConfirmationFormRebootMachine.Topmost = $false
                $ConfirmationFormRebootMachine.Size = "285,150"
                $ConfirmationFormRebootMachine.Icon = New-Object System.Drawing.Icon ("$PSScriptRoot\Data\Img\Logo\Logo.Ico")
                # End ConfirmationForm Settings
                       
                # Label Confirmation Text 
                $ConfirmationFormRebootMachineLabel = New-Object System.Windows.Forms.Label
                $ConfirmationFormRebootMachineLabel.Location = "15,20"
                $ConfirmationFormRebootMachineLabel.Size = "300,20"
                $ConfirmationFormRebootMachineLabel.Text  = "Are you sure that you want to reboot $ComputerName"
                $ConfirmationFormRebootMachine.Controls.Add($ConfirmationFormRebootMachineLabel)
                # End Label Confirmation Text
                 
                # ConfirmationForm - Button No
                $ConfirmationFormRebootMachineButtonNo = New-object System.Windows.Forms.Button
                $ConfirmationFormRebootMachineButtonNo.Text= "No" 
                $ConfirmationFormRebootMachineButtonNo.Location = "30,60"
                $ConfirmationFormRebootMachineButtonNo.Size = "70,20"
                $ConfirmationFormRebootMachineButtonNo.Add_Click({ Function-Confirmation-Form-Button-Reboot-Machine-No }) 
                Function Function-Confirmation-Form-Button-Reboot-Machine-No { # Start Function-Confirmation-Form-Button-Reboot-Machine-No
                    $ConfirmationFormRebootMachine.Close() 
                        } # End Function-Confirmation-Form-Button-Reboot-Machine-No
                $ConfirmationFormRebootMachine.Controls.Add($ConfirmationFormRebootMachineButtonNo) 
                # End ConfirmationForm - Button No

                # ConfirmationForm - Button Yes
                $ConfirmationFormRebootMachineButtonYes = New-object System.Windows.Forms.Button
                $ConfirmationFormRebootMachineButtonYes.Text= "Yes"
                $ConfirmationFormRebootMachineButtonYes.Location = "165,60"
                $ConfirmationFormRebootMachineButtonYes.Size = "70,20"
                $ConfirmationFormRebootMachineButtonYes.Add_Click({ Function-Confirmation-Form-Button-Reboot-Machine-Yes })
                Function Function-Confirmation-Form-Button-Reboot-Machine-Yes { # Start Function-Confirmation-Form-Button-Reboot-Machine-Yes
                    $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable
                    $MainFormProgressBar.Maximum = $Total*4 + 4 # Amount of Values you can add to the progressbar
                    $MainFormProgressBar.Value ++ # Add Value To Progressbar 1 Of 4
                    $StatusBarPanel.Text = "Test connection to $ComputerName" # Panelbar Text
                    $PingRequest = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet # Check If Remote-Machine is online
                    If ($PingRequest -Eq $True){ # If PingRequest is true then   
                            $ConfirmationFormRebootMachine.Close()
                            Start-Sleep -Milliseconds 25 # Sleep for Graphical updates
                            $StatusBarPanel.Text = "Connection to $ComputerName is successful" # StatusBar Panel Confirmation Text
                            Start-Sleep -Milliseconds 25 # Sleep for Graphical updates
                            $MainFormProgressBar.Value ++ # Add Value To Progressbar 2 Of 4
                            Restart-Computer 10.199.208.191 $ComputerName -Force
                            $MainFormProgressBar.Value ++ # Add Value To Progressbar 3 Of 4
                            $StatusBarPanel.Text = "$ComputerName is rebooting" # StatusBar Panel Confirmation Text
                            Start-Sleep -Milliseconds 25 # Sleep for Graphical updates
                            $MainFormProgressBar.Value = 0; # Reset Progressbar
                            $StatusBarPanel.Text = "Ready" # Panelbar Text
                         } # If PingRequest is true then  
                         } # End Function-Confirmation-Form-Button-Reboot-Machine-Yes
                     $ConfirmationFormRebootMachine.Controls.Add($ConfirmationFormRebootMachineButtonYes)
                # End ConfirmationForm - Button Yes                
                $ConfirmationFormRebootMachine.Add_Shown({$ConfirmationFormRebootMachine.Activate()})
                [void] $ConfirmationFormRebootMachine.ShowDialog()
                }[void]$StripMenuTools.DropDownItems.Add($ToolsRebootMachine)
        # End Menu File - Sub Menu - Reboot Machine 

        # Menu File - Sub Menu - Log out All Users 
        # Menu File - Sub Menu - Log out All Users
        $ToolsLogOutAllUsers = New-Object System.Windows.Forms.ToolStripMenuItem
        $ToolsLogOutAllUsers.Name = "MenuToolsLogOutAllLoadedUsers"
        $ToolsLogOutAllUsers.Size = "186, 22"
        $ToolsLogOutAllUsers.Text = "Log Out All Loaded Users"
        $ToolsLogOutAllUsers.Add_Click({ Function-LogOut-All-Users })
        Function Function-LogOut-All-Users { # Start Function-LogOut-All-Users 
        $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable    
            # Confirmation-Form Log out All Users
                # ConfirmationForm Settings
                $ConfirmationForLogOutAllUsers = New-Object System.Windows.Forms.Form 
                $ConfirmationForLogOutAllUsers.Text = "Confirmation"
                $ConfirmationForLogOutAllUsers.StartPosition = "CenterScreen"
                $ConfirmationForLogOutAllUsers.Topmost = $false
                $ConfirmationForLogOutAllUsers.Size = "300,160"
                $ConfirmationForLogOutAllUsers.Icon = New-Object System.Drawing.Icon ("$PSScriptRoot\Data\Img\Logo\Logo.Ico")
                # End ConfirmationForm Settings
                       
                # Label Confirmation Text 
                $ConfirmationForLogOutAllUsersLabel = New-Object System.Windows.Forms.Label
                $ConfirmationForLogOutAllUsersLabel.Location = "15,20"
                $ConfirmationForLogOutAllUsersLabel.Size = "300,20"
                $ConfirmationForLogOutAllUsersLabel.Text  = "Are you sure that you want to logout all loaded users"
                $ConfirmationForLogOutAllUsers.Controls.Add($ConfirmationForLogOutAllUsersLabel)
                # End Label Confirmation Text
                 
                # ConfirmationForm - Button No
                $ConfirmationForLogOutAllUsersButtonNo = New-object System.Windows.Forms.Button
                $ConfirmationForLogOutAllUsersButtonNo.Text= "No" 
                $ConfirmationForLogOutAllUsersButtonNo.Location = "30,60"
                $ConfirmationForLogOutAllUsersButtonNo.Size = "70,20"
                $ConfirmationForLogOutAllUsersButtonNo.Add_Click({ Function-Confirmation-Form-Button-LogOutAllUsers-No }) 
                Function Function-Confirmation-Form-Button-LogOutAllUsers-No { # Start Function-Confirmation-Form-Button-LogOutAllUsers-No
                    $ConfirmationForLogOutAllUsers.Close() 
                        } # End Function-Confirmation-Form-Button-LogOutAllUsers-No
                $ConfirmationForLogOutAllUsers.Controls.Add($ConfirmationForLogOutAllUsersButtonNo) 
                # End ConfirmationForm - Button No

                # ConfirmationForm - Button Yes
                $ConfirmationForLogOutAllUsersButtonYes = New-object System.Windows.Forms.Button
                $ConfirmationForLogOutAllUsersButtonYes.Text= "Yes"
                $ConfirmationForLogOutAllUsersButtonYes.Location = "180,60"
                $ConfirmationForLogOutAllUsersButtonYes.Size = "70,20"
                $ConfirmationForLogOutAllUsersButtonYes.Add_Click({ Function-Confirmation-Form-Button-LogOutAllUsers-Yes })
                Function Function-Confirmation-Form-Button-LogOutAllUsers-Yes { # Function-Confirmation-Form-Button-LogOutAllUsers-Yes
                    $ConfirmationForLogOutAllUsers.Close()
                    $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable
                    $MainFormProgressBar.Maximum = $Total*4 + 4 # Amount of Values you can add to the progressbar

                    $PingRequest = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet # Check If Remote-Machine is online
                    $MainFormProgressBar.Value ++ # Add Value To Progressbar 1 Of 4
        
                    If ($PingRequest -Eq $True){ # If PingRequest is true then   
                    $StatusBarPanel.Text = "NetWork-Connection to $ComputerName is successful" # StatusBar Panel Confirmation Text
                    $MainFormProgressBar.Value ++ # Add Value To Progressbar 2 Of 4
                    $StatusBarPanel.Text = "Forcing remote logoff on user" # Panelbar Text
                    $MainFormProgressBar.Value ++ # Add Value To Progressbar 3 Of 4
                    $ScriptBlock =  { $RemoteLogOfUsers = get-wmiobject win32_operatingsystem -ComputerName 46.102.135.238 -EnableAllPrivileges
                    $RemoteLogOfUsers.win32shutdown(4) } # Forced Remote logoff all users 
                    $StatusBarPanel.Text = "Sending Invoke Command..." # Panelbar Text
                    Invoke-Command -Computername $Computername -ScriptBlock $ScriptBlock # Forced Remote logoff all users 
                    $StatusBarPanel.Text = "Sending Invoke Command successful" # Panelbar Text
                    $MainFormProgressBar.Value ++ # Add Value To Progressbar 4 Of 4
                    $StatusBarPanel.Text = "Ready " # Panelbar Text
                    $MainFormProgressBar.Value = 0;  # Reset Progressbar                                    
                    } # If PingRequest is true then  
                    } # End Function-Confirmation-Form-Button-LogOutAllUsers-Yes
                    $ConfirmationForLogOutAllUsers.Controls.Add($ConfirmationForLogOutAllUsersButtonYes)
                # End ConfirmationForm - Button Yes                
                $ConfirmationForLogOutAllUsers.Add_Shown({$ConfirmationForLogOutAllUsers.Activate()})
                [void] $ConfirmationForLogOutAllUsers.ShowDialog()
                }[void]$StripMenuTools.DropDownItems.Add($ToolsLogOutAllUsers)
        # End Menu File - Sub Menu - Log out All Users

        # Menu File - Sub Menu - Ping Machine
        $ToolsPingMachine = New-Object System.Windows.Forms.ToolStripMenuItem
        $ToolsPingMachine.Name = "ToolsPingMachine"
        $ToolsPingMachine.Size = "186, 22"
        $ToolsPingMachine.Text = "Ping Machine"
        $ToolsPingMachine.Add_Click({ Function-Ping-Machine })
        Function Function-Ping-Machine { # Start Function-Ping-Machine
        $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable
        $MainFormProgressBar.Maximum = $Total*4 + 4 # Amount of Values you can add to the progressbar

        $MainFormProgressBar.Value ++ # Add Value To Progressbar 1 Of 4
        $StatusBarPanel.Text = "Testing connection to $ComputerName" # Panelbar Text
        $PingRequest = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet # Check If Remote-Machine is online
        $MainFormProgressBar.Value ++ # Add Value To Progressbar 2 Of 4
        If ($PingRequest -Eq $True){ # If PingRequest is true then   
            $StatusBarPanel.Text = "NetWork-Connection to $ComputerName is successful" # StatusBar Panel Confirmation Text
            $MainFormProgressBar.Value ++ # Add Value To Progressbar 3 Of 4
            $MainFormProgressBar.Value = 0; # Reset Progressbar

                } Else {
                    $StatusBarPanel.Text = "NetWork-Connection to $ComputerName have failed " # StatusBar Panel Confirmation Text
                    $MainFormProgressBar.Value = 0; # Reset Progressbar
                    # End Function-Ping-Machine
        }} [void]$StripMenuTools.DropDownItems.Add($ToolsPingMachine) # Bind Object To TopMenuStrip -> StripMenuFile
        # End Menu File - Sub Menu - Ping Machine
# End Region Top Bar Menu - Menu Tools


# Region Sections Main Form - Context Menu Strip
    # Main Form - Context Menu Strip
    $ContextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    $ContextMenu.Name = "ContextMenu"
    $ContextMenu.Size = "188, 114"
         # Sub Menu Delete Selected Profile, is used to remove loaded profiles 
         $CmsDeleteProfile = New-Object System.Windows.Forms.ToolStripMenuItem
         $CmsDeleteProfile.Name = "CmsDeleteProfile"
         $CmsDeleteProfile.Size = "187, 22"
         $CmsDeleteProfile.Text = "Delete Profile"
         $CmsDeleteProfile.Visible = $False
         $CmsDeleteProfile.Add_Click({Function-Cms-Delete-Profile})
         function Function-Cms-Delete-Profile  { # Start Function-Cms-Delete-Profile
        
        # ConfirmationForm Settings
        $ConfirmationFormDeleteProfiles = New-Object System.Windows.Forms.Form  
        $ConfirmationFormDeleteProfiles.Text = "Confirmation" 
        $ConfirmationFormDeleteProfiles.StartPosition = "CenterScreen"
        $ConfirmationFormDeleteProfiles.Topmost = $false
        $ConfirmationFormDeleteProfiles.Size = "300,150" 
        $ConfirmationFormDeleteProfiles.Icon = New-Object System.Drawing.Icon ("$PSScriptRoot\Data\Img\Logo\Logo.Ico") 
        # ConfirmationForm Settings       
        # Label Confirmation Text 
        $ConfirmationFormDeleteProfilesLabel = New-Object System.Windows.Forms.Label
        $ConfirmationFormDeleteProfilesLabel.Location = "30,20"
        $ConfirmationFormDeleteProfilesLabel.Size = "300,20"
        $ConfirmationFormDeleteProfilesLabel.Text  = "Are you sure that you want to remove profile"
        $ConfirmationFormDeleteProfiles.Controls.Add($ConfirmationFormDeleteProfilesLabel)
        # Label Confirmation Text 
        # ConfirmationForm - Button No
        $ConfirmationFormDeleteProfilesButtonNo = New-object System.Windows.Forms.Button
        $ConfirmationFormDeleteProfilesButtonNo.Text= "No"
        $ConfirmationFormDeleteProfilesButtonNo.Location = "45,60"
        $ConfirmationFormDeleteProfilesButtonNo.Size = "70,20"
        $ConfirmationFormDeleteProfilesButtonNo.Add_Click({ Function-Confirmation-Form-Button-Delete-Profile-No })
        Function Function-Confirmation-Form-Button-Delete-Profile-No { # Start Function-Confirmation-Form-Button-Delete-Profile-No
        $ConfirmationFormDeleteProfiles.Close() } # End Function-Confirmation-Form-Button-Delete-Profile-No       
        $ConfirmationFormDeleteProfiles.Controls.Add($ConfirmationFormDeleteProfilesButtonNo)
        # ConfirmationForm - Button Yes
        $ConfirmationFormDeleteProfilesButtonYes = New-object System.Windows.Forms.Button
        $ConfirmationFormDeleteProfilesButtonYes.Text= "Yes"
        $ConfirmationFormDeleteProfilesButtonYes.Location = "175,60"
        $ConfirmationFormDeleteProfilesButtonYes.Size = "70,20"
        $ConfirmationFormDeleteProfilesButtonYes.Add_Click({ Function-Confirmation-Form-Button-Delete-Profile-Yes })
        Function Function-Confirmation-Form-Button-Delete-Profile-Yes { # Start Function-Confirmation-Form-Button-Delete-Profile-Yes

        $ConfirmationFormDeleteProfiles.Close()   
        Start-Sleep -Seconds 1 
        ForEach ( $Item In $Lvmain.SelectedItems) {
          $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable
          $SelectedSid = $Item.Subitems[1].text # Convert Listview To Sid
          $MainFormProgressBar.Maximum = $Total*4 + 4 # Amount of Values you can add to the progressbar
              
              $MainFormProgressBar.Value ++ # Add Value To Progressbar 1 Of 4
              Start-Sleep -Milliseconds 25 # Sleep for Graphical updates

              $ProfileSid = Get-WmiObject -Class Win32_UserProfile -Computername $Computername -Filter "SID = '$SelectedSid'" 
              Remove-WmiObject -InputObject $ProfileSid  # Remove Profile

              Start-Sleep -Milliseconds 25 # Sleep for Graphical updates
              Function-Get-Local-Profiles # Reload listview with data
              $MainFormProgressBar.Value ++ # Add Value To Progressbar 4 Of 4 
          
              Start-Sleep -Milliseconds 25 # Sleep for Graphical updates
              $MainFormProgressBar.Value = 0; # Reset Progressbar
              $StatusBarPanel.Text = "Ready" # Panelbar Text 
            } # End ForEach            
        } # End Function-Confirmation-Form-Button-Delete-Profile-Yes     
        $ConfirmationFormDeleteProfiles.Controls.Add($ConfirmationFormDeleteProfilesButtonYes)
        $ConfirmationFormDeleteProfiles.Add_Shown({$ConfirmationFormDeleteProfiles.Activate()})
        [void] $ConfirmationFormDeleteProfiles.ShowDialog()}
        [void]$ContextMenu.Items.Add($CmsDeleteProfile)
         # End Function CmsDeleteLoadedProfile

         # Sub Menu CmsClearListView
         $CmsClearListView = New-Object System.Windows.Forms.ToolStripMenuItem
         $CmsClearListView.Name = "CmsClearListView"
         $CmsClearListView.Size = "187, 22"
         $CmsClearListView.Text = "Clear Listview"
         $CmsClearListView.Visible = $False
         $CmsClearListView.Add_Click({Function-Cms-Clear-ListView})
         function Function-Cms-Clear-ListView  { # Start Function-Cms-Clear-ListView 
         
         Function-Initialize-Listview
          }  # End Function-Cms-Clear-ListView 
         [void]$ContextMenu.Items.Add($CmsClearListView)          
# End Region Main Form - Context Menu Strip

# Region Section Searchbar
    # Label Hostname
    $MainFormLabelSearchBar = New-Object System.Windows.Forms.Label
    $MainFormLabelSearchBar.Location = "15,40"
    $MainFormLabelSearchBar.Size = "60,20"
    $MainFormLabelSearchBar.Text = "Computer :"
    $MainForm.Controls.Add($MainFormLabelSearchBar)
     
    # Main Form - SearchBar - Settings
    $MainFormSearchBar = New-Object System.Windows.Forms.Textbox
    $MainFormSearchBar.Location = "75,37"
    $MainFormSearchBar.Size = "80,20"
    $MainFormSearchBar.Text = ""
    $MainForm.Controls.Add($MainFormSearchBar)
    # Main Form - SearchBar - Settings

    # Main Form -Button Search
    $ButtonSearch = New-object System.Windows.Forms.Button
    $ButtonSearch.Text= "Search"
    $ButtonSearch.Location = "165,36"
    $ButtonSearch.Size = "70,23"
    $ButtonSearch.Add_Click({ Function-Get-Local-Profiles }) 
    Function Function-Get-Local-Profiles { # Start Function Get Local Profiles
    
    Function-Initialize-Listview # Clear Listview Items and Columns, Resize 
    Function-Update-ContextMenu (Get-Variable Cms*) # Load Cms Profile Menus

    $ComputerName = $MainFormSearchBar.Text # Convert Text in Textbox To Variable
    $PathToAllUsers = "C$\Users"
    $LocalPathAllUsers = "\\$ComputerName\$PathToAllUsers"
    Start-Process -FilePath $LocalPathAllUsers


    $MainFormProgressBar.Maximum = $Total*4 + 4 # Amount of Values you can add to the progressbar

    $MainFormProgressBar.Value ++ # Add Value To Progressbar 1 Of 4
    $StatusBarPanel.Text = "Test connection to $ComputerName" # Panelbar Text
    $PingRequest = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet # Check If Remote-Machine is online

    If ($PingRequest -Eq $True){ # If PingRequest is true then   

        $StatusBarPanel.Text = "Connection to $ComputerName is successful" # StatusBar Panel Confirmation Text
        Start-Sleep -Milliseconds 25 # Sleep for Graphical updates

        $MainFormProgressBar.Value ++ # Add Value To Progressbar 2 Of 4
        $StatusBarPanel.Text = "Add columns to Listview-Object" # Panelbar Text
        $Xml.Columns.LocalProfiles.Property | %{Add-Column $_} #Add Columns from XML based on the function
        Start-Sleep -Milliseconds 25 # Sleep for Graphical updates

        $MainFormProgressBar.Value ++ # Add Value To Progressbar 3 Of 4
        $StatusBarPanel.Text = "Changing columns size" # Panelbar Text
        Function-Change-Size-Columns # Change Columns Size
        Start-Sleep -Milliseconds 25 # Sleep for Graphical updates

        $StatusBarPanel.Text = "Load Listview-Object with items, Wait " # Panelbar Text
        Start-Sleep -Milliseconds 25 # Sleep for Graphical updates 
   
        $Col0 = $lvMain.Columns[0].Text # StartColumn on Listview
   
        # GetUserProfiles From Computer and save it to csv, load every object in listview
        $LocalAccountAttributes = Get-WmiObject -ComputerName $ComputerName -Filter "Special=False" -Class Win32_UserProfile |  
        Select-Object Sid, LocalPath, @{Label='LastUseTime';Expression={$_.ConvertToDateTime($_.LastUseTime)}}, Loaded  |  # Select These Objects 
        Export-Csv $ProfileAttributesCsvFile -Encoding UTF8 -Delimiter ";" # Export to a CSV
        $DbProfileCsv = Import-Csv -Path $ProfileAttributesCsvFile -Encoding UTF8 -Delimiter ";" | Sort-Object LastUseTime # Import CsvFile and sort after LastUseTime
        $DbProfileCsv | Foreach-Object { # Start Foreach-Object
                
                $StartItem = New-Object System.Windows.Forms.ListViewItem(" Start - User Attributes " ) 
                $StartItem.BackColor = "Black"
                $StartItem.ForeColor = "White"
                $LvMain.Items.Add($StartItem)
                
                    $Item = New-Object System.Windows.Forms.ListViewItem(" Path :") 
                    $Item.SubItems.Add($_.LocalPath)
                    $LvMain.Items.Add($Item)

                    $Item = New-Object System.Windows.Forms.ListViewItem(" Last login :")
                    $Item.SubItems.Add($_.LastUseTime)
                    $LvMain.Items.Add($Item)

                    $Item = New-Object System.Windows.Forms.ListViewItem(" User logged in? :")
                    $Item.SubItems.Add($_.Loaded)
                    $LvMain.Items.Add($Item)

                    $Item = New-Object System.Windows.Forms.ListViewItem(" Sid :")
                    $Item.SubItems.Add($_.Sid)
                    $LvMain.Items.Add($Item)
            
                $EndItem = New-Object System.Windows.Forms.ListViewItem(" End - User Attributes ")
                $EndItem.BackColor = "Red"
                $EndItem.ForeColor = "Black"
                $LvMain.Items.Add($EndItem)

            $MainFormProgressBar.Value = 0; # Reset Progressbar
            $StatusBarPanel.Text = "Ready" # Panelbar Text
            }     }     else    { 
            $MainFormProgressBar.Value = 0;
            $StatusBarPanel.Text = "Computer is offline"  
            }     }              
    $MainForm.Controls.Add($ButtonSearch)
    # End Button Search
    
    # Main Form - Progressbar
    $MainFormProgressBar = New-Object System.Windows.Forms.ProgressBar
    $MainFormProgressBar.Location = "260,37"
    $MainFormProgressBar.Size = "455,21"
    $MainForm.Controls.Add($MainFormProgressBar)
    # End Progressbar

    # Main Form - StatusBar Settings
    $MainFormStatusBar = New-Object System.Windows.Forms.StatusBar
    $MainFormStatusBar.Anchor = "Bottom, Left, Right"
    $MainFormStatusBar.Dock = "None"
    $MainFormStatusBar.Location = "100,85"
    $MainFormStatusBar.Name = "StatusBar"
    $MainFormStatusBar.ShowPanels = $True
    $MainFormStatusBar.Size = "620, 20"
    $MainForm.Controls.Add($MainFormStatusBar)
    # End StatusBar Settings

    # StatusPanel
    $StatusBarPanel = New-Object System.Windows.Forms.StatusbarPanel
    $StatusBarPanel.AutoSize = "Spring"
    $StatusBarPanel.Name = "StatusBarPanel"
    $StatusBarPanel.Text = "Ready"
    $StatusBarPanel.Width = "620"
    [void]$MainFormStatusBar.Panels.Add($StatusBarPanel)
    # End StatusPanel 
# End Region Section Searchbar

# Region Section MainTab
    # Settings
    $MainFormTabControl = New-object System.Windows.Forms.TabControl
    $MainFormTabControl.Size = "765,475"
    $MainFormTabControl.Location = "15,125"
    $MainForm.Controls.Add($MainFormTabControl)
    # Settings

    # Tab Remote-Server - Settings
    $TabRemoteClient = New-object System.Windows.Forms.Tabpage
    $TabRemoteClient.DataBindings.DefaultDataSourceUpdateMode = 0
    $TabRemoteClient.UseVisualStyleBackColor = $True
    $TabRemoteClient.Name = "TabRemoteServer"
    $TabRemoteClient.Text = "Remote Client"
    $MainFormTabControl.Controls.Add($TabRemoteClient)
    # Tab Remote-Server - Settings

    # Tab Remote-Server - Listview 
    # Label ListView 
    $LabelListViewTitle = New-Object System.Windows.Forms.Label
    $LabelListViewTitle.Location = "325,5"
    $LabelListViewTitle.Size = "100,20"
    $LabelListViewTitle.Text  = "User Profile Data"
    $TabRemoteClient.Controls.Add($LabelListViewTitle)
    # Listview 
    $LvMain = New-Object System.Windows.Forms.ListView
    $LvMain.Scrollable = $True 
    $LvMain.FullRowSelect = $True 
    $LvMain.GridLines = $True
    $LvMain.Location = "80, 30"
    $LvMain.Name = "lvMain"
    $LvMain.Size = "600, 418"
    $LvMain.TabIndex = "13"
    $LvMain.UseCompatibleStateImageBehavior = $False
    $LvMain.View = "Details"
    $LvMain.Font ="lucida console"
    $LvMain.Checkboxes = $False 
    $LvMain.MultiSelect = $True 
    $LvMain.ContextMenuStrip = $ContextMenu
    $TabRemoteClient.Controls.Add($lvMain)
    # Tab Remote-Server - Listview   
# End Region Section MainTab


# Region Section Functions 
    # Update-ContextMenu 
    Function Function-Update-ContextMenu{
    Param($Vis)		
    Get-Variable Cms* | %{Try{$_.Value.Visible = $False}Catch{}}
    $Vis | %{Try{$_.Value.Visible = $True}Catch{}}
    } # End Update-ContextMenu 

    # Initialize-Listview
    Function Function-Initialize-Listview{
    $LvMain.Items.Clear()
    $LvMain.Columns.Clear()
    } # End Initialize-Listview

    # Functions Add Column
    function Add-Column{
    Param([String]$Column)
    Write-Verbose "Adding $Column from XML file"
    $LvMain.Columns.Add($Column) } 
    # End Add Column

    # ReSize Columns
    Function Function-Change-Size-Columns {
    $ColWidth = (($LvMain.Width / ($LvMain.Columns).Count) -11 )
    $LvMain.Columns | %{$_.Width = $ColWidth}
    } # End ReSize Columns

    # Remove Selected Listview Items
    function Function-Remove-SelectedItems{
    $LvMain.SelectedItems | %{$LvMain.Items.RemoveAt($_.Index)}
    } # End Remove Selected Listview Items
# End Region  Section Functions 




# Region Section Mainform 
$MainForm.Add_Shown({$MainForm.Activate()})
[void] $MainForm.ShowDialog()
# End Region

 

 }