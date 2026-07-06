# Purpose: ShowCollectionMemberShip v0 7p — Configuration Manager collections and deployments.
﻿################################################################################################################################################
# Project: Collection MemberShip
# Date: 8-6-2013
# By: Peter van der Woude
# Version: 0.7 Public
# Usage: PowerShell.exe -ExecutionPolicy ByPass .\CollectionMemberShip_v0_7p.ps1 -ResourceId <ResourceId> -SiteCode <SiteCode> -SiteServer <SiteServer>
################################################################################################################################################
[CmdletBinding()]

param (
[string]$ResourceId,
[string]$SiteCode,
[string]$SiteServer,
[string]$ApplicationVersion = "Show Collection Memberships v0.7p"
)

function Show-CollectionNames {
    $WorkArray = New-Object System.Collections.ArrayList
    $SortArray = New-Object System.Collections.ArrayList
    $DataArray = New-Object System.Collections.ArrayList
    $Ids = Get-WmiObject -Class SMS_FullCollectionMembership -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.ResourceId -eq $ResourceId} | Select-Object CollectionId
    foreach ($Id in $Ids) {
        $CollectionId = $Id.CollectionId
        $Names = Get-WmiObject -Class SMS_Collection -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.CollectionID -eq $CollectionId} | Select-Object Name
        foreach ($Name in $Names) {
            $CollectionName = $Name.Name
            $Deployments = Get-WmiObject -Class SMS_DeploymentSummary -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.CollectionName -eq $CollectionName} | Select-Object CollectionName,SoftwareName,FeatureType
            $Settings = Get-WmiObject -Class SMS_ClientSettingsAssignment -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.CollectionName -eq $CollectionName} | Select-Object ClientSettingsId
            if ($Deployments -eq $null -and $Settings -eq $null) {
                $Temp = New-Object PSObject -Property @{
                    CollectionName=$Name.Name; 
                    FeatureType=""; 
                    SoftwareName=""
                }
                $WorkArray.Add($Temp)
            }
	        else {
                if ($Deployments -ne $null) {
                    for ($i=0; $i -lt @($Deployments).Count; $i++) {
	                    if ($Deployments[$i].FeatureType -eq 1) {
                            $Deployments[$i].FeatureType = "Application"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 2) {
                            $Deployments[$i].FeatureType = "Program"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 3) {
                            $Deployments[$i].FeatureType = "Mobile Program"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 4) {
                            $Deployments[$i].FeatureType = "Script"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 5) {
                            $Deployments[$i].FeatureType = "Software Update"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 6) {
                            $Deployments[$i].FeatureType = "Baseline"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 7) {
                            $Deployments[$i].FeatureType = "Task Sequence"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 8) {
                            $Deployments[$i].FeatureType = "Content Distribution"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 9) {
                            $Deployments[$i].FeatureType = "Distribution Point Group"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 10) {
                            $Deployments[$i].FeatureType = "Distribution Point Health"
                        }
                        elseif ($Deployments[$i].FeatureType -eq 11) {
                            $Deployments[$i].FeatureType = "Configuration Policy"
                        }
                    }
                    foreach ($Deployment in $Deployments) {
                        $WorkArray.Add($Deployment)
                    }
                }
                if($Settings -ne $null) {
                    $FeatureType = "Client Settings"
                    $SettingsId = $Settings.ClientSettingsId
                    $SettingsName = Get-WmiObject -Class SMS_ClientSettings -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.SettingsId -eq $SettingsId} | Select-Object Name
                    if ($SettingsName -eq $null) {
                        $FeatureType = "Antimalware Settings"
                        $SettingsName = Get-WmiObject -Class SMS_AntimalwareSettings -Namespace root/SMS/site_$($SiteCode) -ComputerName $SiteServer | Where-Object -FilterScript {$_.SettingsId -eq $SettingsId} | Select-Object Name
                    }
                    $Temp = New-Object PSObject -Property @{
                        CollectionName=$Name.Name; 
                        FeatureType=$FeatureType; 
                        SoftwareName=$SettingsName.Name
                    }
                    $WorkArray.Add($Temp)
                }
            }
        }
    }
    $SortArray = $WorkArray | Sort-Object CollectionName,SoftwareName
    foreach($Item in $SortArray) {
        $DataArray.Add($Item)
    }
    $dataGridView1.DataSource = $DataArray
    for ($i=0; $i -lt $dataGridView1.ColumnCount; $i++) {
	    $dataGridView1.Columns[$i].width = 149
    }
    $form1.refresh()
}

#Generated Form Function
function GenerateForm {
    ########################################################################
    # Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.10.0
    # Generated On: 29-5-2013 20:26
    # Generated By: Peter
    ########################################################################

    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

    $form1 = New-Object System.Windows.Forms.Form
    $dataGridView1 = New-Object System.Windows.Forms.DataGridView
    $button1 = New-Object System.Windows.Forms.Button
    $label1 = New-Object System.Windows.Forms.Label
    $label2 = New-Object System.Windows.Forms.Label
    $label3 = New-Object System.Windows.Forms.Label
    $label4 = New-Object System.Windows.Forms.Label
    $linkLabel1 = New-Object System.Windows.Forms.LinkLabel
    $linkLabel2 = New-Object System.Windows.Forms.LinkLabel
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

    $button1_OnClick= {
	    $form1.Close()
    }
    
    $linkLabel1_OpenLink= {
        [system.Diagnostics.Process]::start($linkLabel1.text)
    }

    $linkLabel2_OpenLink= {
        [system.Diagnostics.Process]::start("http://twitter.com/pvanderwoude")
    }

    $OnLoadForm_UpdateGrid= {
       Show-CollectionNames
    }

    #Create form1
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 308
    $System_Drawing_Size.Width = 534
    $form1.ClientSize = $System_Drawing_Size
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.Name = "form1"
    $form1.Text = "$ApplicationVersion - P.T. van der Woude"

    #Create dataGridView1
    $dataGridView1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 40
    $dataGridView1.Location = $System_Drawing_Point
    $dataGridView1.Name = "dataGridView1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 205
    $System_Drawing_Size.Width = 508
    $dataGridView1.ReadOnly = $True
    $dataGridView1.SelectionMode = 'FullRowSelect'
    $dataGridView1.Size = $System_Drawing_Size
    $dataGridView1.TabIndex = 2
    $form1.Controls.Add($dataGridView1)

    #Create button1
    $button1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 372
    $System_Drawing_Point.Y = 253
    $button1.Location = $System_Drawing_Point
    $button1.Name = "button1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 150
    $button1.Size = $System_Drawing_Size
    $button1.TabIndex = 1
    $button1.Text = "Close"
    $button1.UseVisualStyleBackColor = $True
    $button1.add_Click($button1_OnClick)
    $form1.Controls.Add($button1)
    
    #Create label1
    $label1.DataBindings.DefaultDataSourceUpdateMode = 0
    $label1.Font = New-Object System.Drawing.Font("Tahoma",14.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 13
    $label1.Location = $System_Drawing_Point
    $label1.Name = "label1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 225
    $label1.Size = $System_Drawing_Size
    $label1.TabIndex = 0
    $label1.Text = "Collection Memberships"
    $form1.Controls.Add($label1)

    #Create label2
    $label2.DataBindings.DefaultDataSourceUpdateMode = 0
    $label2.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 265
    $System_Drawing_Point.Y = 19
    $label2.Location = $System_Drawing_Point
    $label2.Name = "label2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 254
    $label2.Size = $System_Drawing_Size
    $label2.TabIndex = 0
    $label2.Text = "- Including targeted deployments and their type -"
    $form1.Controls.Add($label2)

    #Create label3
    $label3.DataBindings.DefaultDataSourceUpdateMode = 0
    $label3.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 12
    $System_Drawing_Point.Y = 282
    $label3.Location = $System_Drawing_Point
    $label3.Name = "label3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 48
    $label3.Size = $System_Drawing_Size
    $label3.TabIndex = 1
    $label3.Text = "My blog:"
    $form1.Controls.Add($label3)
        
    #Create label4
    $label4.DataBindings.DefaultDataSourceUpdateMode = 0
    $label4.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 321
    $System_Drawing_Point.Y = 282
    $label4.Location = $System_Drawing_Point
    $label4.Name = "label4"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 117
    $label4.Size = $System_Drawing_Size
    $label4.TabIndex = 2
    $label4.Text = "Follow me on twitter:"
    $form1.Controls.Add($label4)

    #Create linkLabel1
    $linkLabel1.DataBindings.DefaultDataSourceUpdateMode = 0
    $linkLabel1.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 63
    $System_Drawing_Point.Y = 282
    $linkLabel1.Location = $System_Drawing_Point
    $linkLabel1.Name = "linkLabel1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 142
    $linkLabel1.Size = $System_Drawing_Size
    $linkLabel1.TabIndex = 0
    $linkLabel1.TabStop = $True
    $linkLabel1.Text = "www.petervanderwoude.nl"
    $linkLabel1.add_click($linkLabel1_OpenLink)
    $form1.Controls.Add($linkLabel1)

    #Create linkLabel2
    $linkLabel2.DataBindings.DefaultDataSourceUpdateMode = 0
    $linkLabel2.Font = New-Object System.Drawing.Font("Tahoma",8.25,0,3,0)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 435
    $System_Drawing_Point.Y = 282
    $linkLabel2.Location = $System_Drawing_Point
    $linkLabel2.Name = "linkLabel2"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 23
    $System_Drawing_Size.Width = 90
    $linkLabel2.Size = $System_Drawing_Size
    $linkLabel2.TabIndex = 3
    $linkLabel2.TabStop = $True
    $linkLabel2.Text = "@pvanderwoude"
    $linkLabel1.add_click($linkLabel2_OpenLink)
    $form1.Controls.Add($linkLabel2)

    $InitialFormWindowState = $form1.WindowState

    $form1.add_Load($OnLoadForm_UpdateGrid)
    $form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
