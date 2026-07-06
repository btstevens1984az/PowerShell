# Purpose: Make-form — PowerShell automation.
function GenerateForm {

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

$form1 = New-Object System.Windows.Forms.Form
$createButton = New-Object System.Windows.Forms.Button
$display = New-Object System.Windows.Forms.ListBox
$orderBy = New-Object System.Windows.Forms.CheckBox
$orderByText = New-Object System.Windows.Forms.TextBox
$orderByString = ""
$medFoundationTest = New-Object System.Windows.Forms.CheckBox
$tunerCHANNEL_1 = New-Object System.Windows.Forms.CheckBox
$tunerCHANNEL_1Text = New-Object System.Windows.Forms.TextBox
$tunerpackage_1 = ""
$tunerCHANNEL_2 = New-Object System.Windows.Forms.CheckBox
$tunerCHANNEL_2Text = New-Object System.Windows.Forms.TextBox
$tunerpackage_2 = ""
$tunerCHANNEL_3 = New-Object System.Windows.Forms.CheckBox
$tunerCHANNEL_3Text = New-Object System.Windows.Forms.TextBox
$tunerpackage_3 = ""
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

$b1= $false
$b2= $false
$b3= $false

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------

$handler_createButton_Click= 
{
    $display.Items.Clear();    
    $display.Items.Add("SELECT DISTINCT")
    $display.Items.Add("   MACHINE.NAME MACHINE_NAME")

    if ($tunerCHANNEL_1.Checked)    {  
        $display.Items.Add( "   , CHANNEL1.URL"  ) 
        $display.Items.Add( "   , CHANNEL1.STATE"  ) 
        }

    if ($tunerCHANNEL_2.Checked)    {  
        $display.Items.Add( "   , CHANNEL2.URL"  ) 
        $display.Items.Add( "   , CHANNEL2.STATE"  ) 
        }

    if ($tunerCHANNEL_3.Checked)    {  
        $display.Items.Add( "   , CHANNEL3.URL"  ) 
        $display.Items.Add( "   , CHANNEL3.STATE"  ) 
        }

    if ($medFoundationTest.Checked)    {  
        $display.Items.Add( "   , CHANNEL_DHMF.URL DHMF_TAG"  ) 
        }

    $display.Items.Add("")
    $display.Items.Add("From")
    $display.Items.Add("   CHWMACHINES MACHINE")
    
    if ($tunerCHANNEL_1.Checked)    {
        $tunerpackage_1 = $tunerCHANNEL_1Text.Text
        $display.Items.Add( "   INNER JOIN INV_TUNER TUNER"  ) 
        $display.Items.Add( "      ON (MACHINE.MACHINE_ID = TUNER.MACHINE_ID)"  )
        $display.Items.Add( "   LEFT OUTER JOIN INV_tunerChannel CHANNEL_1"  ) 
        $display.Items.Add( "       ON ("  ) 
        $display.Items.Add( "          TUNER.TUNER_ID = CHANNEL_1.TUNER_ID "  ) 
        $display.Items.Add( "          AND CHANNEL_1.URL = '$tunerpackage_1'"  )
        $display.Items.Add( "      )"  ) 
        }

    if ($tunerCHANNEL_2.Checked)    {
        $tunerpackage_2 = $tunerCHANNEL_2Text.Text
        $display.Items.Add( "   INNER JOIN INV_TUNER TUNER"  ) 
        $display.Items.Add( "      ON (MACHINE.MACHINE_ID = TUNER.MACHINE_ID)"  )
        $display.Items.Add( "   LEFT OUTER JOIN INV_tunerChannel CHANNEL_2"  ) 
        $display.Items.Add( "       ON ("  ) 
        $display.Items.Add( "          TUNER.TUNER_ID = CHANNEL_2.TUNER_ID "  ) 
        $display.Items.Add( "          AND CHANNEL_2.URL = '$tunerpackage_2'"  )
        $display.Items.Add( "      )"  ) 
        }

    if ($tunerCHANNEL_3.Checked)    {
        $tunerpackage_3 = $tunerCHANNEL_3Text.Text
        $display.Items.Add( "   INNER JOIN INV_TUNER TUNER"  ) 
        $display.Items.Add( "      ON (MACHINE.MACHINE_ID = TUNER.MACHINE_ID)"  )
        $display.Items.Add( "   LEFT OUTER JOIN INV_tunerChannel CHANNEL_3"  ) 
        $display.Items.Add( "       ON ("  ) 
        $display.Items.Add( "          TUNER.TUNER_ID = CHANNEL_3.TUNER_ID "  ) 
        $display.Items.Add( "          AND CHANNEL_3.URL = '$tunerpackage_3'"  )
        $display.Items.Add( "      )"  ) 
        }

    if ($medFoundationTest.Checked)    {  
        $display.Items.Add( "   LEFT OUTER JOIN INV_tunerChannel CHANNEL_DHMF"  )
        $display.Items.Add( "       ON ("  ) 
        $display.Items.Add( "          TUNER.TUNER_ID = CHANNEL_DHMF.TUNER_ID "  ) 
        $display.Items.Add( "          AND CHANNEL_DHMF.URL = 'http://marimba.example.com:5282/.Organization/DE_Tools/MT/DHMF_TAG'"  )
        $display.Items.Add( "      )"  ) 
        }

        $display.Items.Add("")
        $display.Items.Add("/* IF YOU HAVE A TARGET LIST, ADD IT HERE:")
        $display.Items.Add("Where")
        $display.Items.Add("   MACHINE.NAME LIKE 'SITE%' Or")
        $display.Items.Add("   MACHINE.ADDRESS LIKE '10.9.5%' */")

    if ($orderBy.Checked)    {
        $orderByString = $orderByText.Text
        $display.Items.Add("")
        $display.Items.Add( "order by $orderByString"  ) }

        $display.Items | Clip
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
    $form1.WindowState = $InitialFormWindowState
}

# New Function for when TunerChannel_1 Check box is checked, adds a text Box

$tunerCHANNEL_1_Checked =
{

    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 154
    $System_Drawing_Size.Height = 24
    $tunerCHANNEL_1Text.Size = $System_Drawing_Size
    $tunerCHANNEL_1Text.TabIndex = 1
    $tunerCHANNEL_1Text.Text = "Enter Tuner Channel 1 URL"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 199
    $tunerCHANNEL_1Text.Location = $System_Drawing_Point
    $tunerCHANNEL_1Text.DataBindings.DefaultDataSourceUpdateMode = 0
    $tunerCHANNEL_1Text.Name = "tunerCHANNEL_1"

    $form1.Controls.Add($tunerCHANNEL_1Text)

    # Tuner Channel 2 Info Check Box

    $tunerCHANNEL_2.UseVisualStyleBackColor = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 24
    $tunerCHANNEL_2.Size = $System_Drawing_Size
    $tunerCHANNEL_2.TabIndex = 2
    $tunerCHANNEL_2.Text = "Tuner Channel 2"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 44
    $tunerCHANNEL_2.Location = $System_Drawing_Point
    $tunerCHANNEL_2.DataBindings.DefaultDataSourceUpdateMode = 0
    $tunerCHANNEL_2.Name = "tunerCHANNEL_2"

    $form1.Controls.Add($tunerCHANNEL_2)

    $tunerCHANNEL_2.add_Click($tunerCHANNEL_2_Checked)

    $tunerCHANNEL_1.add_Click($tunerCHANNEL_1_UnChecked)
    $tunerCHANNEL_1.add_click($tunerCHANNEL_2_UnChecked)
    $tunerCHANNEL_1.add_click($tunerCHANNEL_3_UnChecked)

}

# New Function for when TunerChannel_1 Check box is unchecked, removes a text Box

$tunerCHANNEL_1_UnChecked =
{

$form1.Controls.remove($tunerCHANNEL_1Text)
$tunerCHANNEL_2.Checked = $false
$form1.Controls.Remove($tunerCHANNEL_2)
$tunerCHANNEL_1.add_Click($tunerCHANNEL_1_Checked)

}

# New Function for when tunerCHANNEL_2 Check box is checked, adds a text Box

$tunerCHANNEL_2_Checked =
{

    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 154
    $System_Drawing_Size.Height = 24
    $tunerCHANNEL_2Text.Size = $System_Drawing_Size
    $tunerCHANNEL_2Text.TabIndex = 3
    $tunerCHANNEL_2Text.Text = "Enter Tuner Channel 2 URL"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 230
    $tunerCHANNEL_2Text.Location = $System_Drawing_Point
    $tunerCHANNEL_2Text.DataBindings.DefaultDataSourceUpdateMode = 0
    $tunerCHANNEL_2Text.Name = "tunerCHANNEL_2"

    $form1.Controls.Add($tunerCHANNEL_2Text)
    
    # Tuner Channel 3 Info Check Box

    $tunerCHANNEL_3.UseVisualStyleBackColor = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 24
    $tunerCHANNEL_3.Size = $System_Drawing_Size
    $tunerCHANNEL_3.TabIndex = 4
    $tunerCHANNEL_3.Text = "Tuner Channel 3"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 75
    $tunerCHANNEL_3.Location = $System_Drawing_Point
    $tunerCHANNEL_3.DataBindings.DefaultDataSourceUpdateMode = 0
    $tunerCHANNEL_3.Name = "tunerCHANNEL_3"

    $form1.Controls.Add($tunerCHANNEL_3)

    $tunerCHANNEL_3.add_Click($tunerCHANNEL_3_Checked)

    $tunerCHANNEL_2.add_Click($tunerCHANNEL_2_UnChecked)

}

# New Function for when tunerCHANNEL_2 Check box is unchecked, removes a text Box

$tunerCHANNEL_2_UnChecked =
{

$form1.Controls.remove($tunerCHANNEL_2Text)
$tunerCHANNEL_3.Checked = $false
$form1.Controls.Remove($tunerCHANNEL_3)
$tunerCHANNEL_2.add_Click($tunerCHANNEL_2_Checked)

}

# New Function for when tunerCHANNEL_3 Check box is checked, adds a text Box

$tunerCHANNEL_3_Checked =
{

    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 154
    $System_Drawing_Size.Height = 24
    $tunerCHANNEL_3Text.Size = $System_Drawing_Size
    $tunerCHANNEL_3Text.TabIndex = 5
    $tunerCHANNEL_3Text.Text = "Enter Tuner Channel 3 URL"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 261
    $tunerCHANNEL_3Text.Location = $System_Drawing_Point
    $tunerCHANNEL_3Text.DataBindings.DefaultDataSourceUpdateMode = 0
    $tunerCHANNEL_3Text.Name = "tunerCHANNEL_3"

    $form1.Controls.Add($tunerCHANNEL_3Text)

    $tunerCHANNEL_3.add_Click($tunerCHANNEL_3_UnChecked)

}

# New Function for when tunerCHANNEL_3 Check box is unchecked, removes a text Box

$tunerCHANNEL_3_UnChecked =
{

$form1.Controls.remove($tunerCHANNEL_3Text)
$tunerCHANNEL_3.add_Click($tunerCHANNEL_3_Checked)

}

# New Function for when OrderBy Check box is checked, adds a text Box

$orderBy_Checked =
{

    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 154
    $System_Drawing_Size.Height = 24
    $orderByText.Size = $System_Drawing_Size
    $orderByText.TabIndex = 8
    $orderByText.Text = "Enter Ordery By Number Here"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 27
    $System_Drawing_Point.Y = 292
    $orderByText.Location = $System_Drawing_Point
    $orderByText.DataBindings.DefaultDataSourceUpdateMode = 0
    $orderByText.Name = "orderByText"

    $form1.Controls.Add($orderByText)

    $orderBy.add_Click($orderBy_UnChecked)

}

# New Function for when OrderBy Check box is unchecked, removes a text Box

$orderBy_UnChecked =
{

$form1.Controls.remove($orderByText)
$orderBy.add_Click($orderBy_Checked)

}

#----------------------------------------------
#region Generated Form Code
$form1.Text = "SQL Query Wizard"
$form1.Name = "form1"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 780
$System_Drawing_Size.Height = 400
$form1.ClientSize = $System_Drawing_Size

# Display Box Script

$display.FormattingEnabled = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 570
$System_Drawing_Size.Height = 350
$display.Size = $System_Drawing_Size
$display.DataBindings.DefaultDataSourceUpdateMode = 0
$display.Name = "display"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 197
$System_Drawing_Point.Y = 13
$display.Location = $System_Drawing_Point
$display.TabIndex = 10

$form1.Controls.Add($display)

# Tuner Channel 1 Info Check Box

$tunerCHANNEL_1.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 110
$System_Drawing_Size.Height = 24
$tunerCHANNEL_1.Size = $System_Drawing_Size
$tunerCHANNEL_1.TabIndex = 0
$tunerCHANNEL_1.Text = "Tuner Channel 1"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 13
$tunerCHANNEL_1.Location = $System_Drawing_Point
$tunerCHANNEL_1.DataBindings.DefaultDataSourceUpdateMode = 0
$tunerCHANNEL_1.Name = "tunerCHANNEL_1"

$form1.Controls.Add($tunerCHANNEL_1)

$tunerCHANNEL_1.add_Click($tunerCHANNEL_1_Checked)

# Med Foundation Check Box Script

$medFoundationTest.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 154
$System_Drawing_Size.Height = 24
$medFoundationTest.Size = $System_Drawing_Size
$medFoundationTest.TabIndex = 6
$medFoundationTest.Text = "Med Foundation Test"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 106
$medFoundationTest.Location = $System_Drawing_Point
$medFoundationTest.DataBindings.DefaultDataSourceUpdateMode = 0
$medFoundationTest.Name = "medFoundationTest"

$form1.Controls.Add($medFoundationTest)

# OrderBy Check Box Script

$orderBy.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$orderBy.Size = $System_Drawing_Size
$orderBy.TabIndex = 7
$orderBy.Text = "OrderBy"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 137
$orderBy.Location = $System_Drawing_Point
$orderBy.DataBindings.DefaultDataSourceUpdateMode = 0
$orderBy.Name = "orderBy"

$form1.Controls.Add($orderBy)

$orderBy.add_Click($orderBy_Checked)

# Button Script

$createButton.TabIndex = 9
$createButton.Name = "createButton"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 100
$System_Drawing_Size.Height = 23
$createButton.Size = $System_Drawing_Size
$createButton.UseVisualStyleBackColor = $True

$createButton.Text = "Create Query"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 168
$createButton.Location = $System_Drawing_Point
$createButton.DataBindings.DefaultDataSourceUpdateMode = 0
$createButton.add_Click($handler_createButton_Click)

$form1.Controls.Add($createButton)

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm