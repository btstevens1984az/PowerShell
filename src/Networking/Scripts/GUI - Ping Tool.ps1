#######################
#Function Declarations#
#######################

<#
	.SYNOPSIS
		This function performs the ping to the remote machine.
	
	.DESCRIPTION
		Function uses WMI instead of test-connection for speed reasons and for the breadth
		of information it returns.
	
	.PARAMETER computername
		This is the computer to be pinged.
	
	.EXAMPLE
		PS C:\> Ping-Host -computername '168.189.163.9'
	
		N/A
#>
function Ping-Host
{

  Param
  (
    [string]$computername=$(Throw "You must specify a computername.")
  )
  
  $query="Select * from Win32_PingStatus where address='$computername'"
  $wmi=Get-WmiObject -query $query
  
  Write-Output $wmi
}

#Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null

<#
	.SYNOPSIS
		This function declares and generates the form.
	
	.DESCRIPTION
		This function does all the heavy lifting of declaring the form objects and all
		of their properties.
	
	.EXAMPLE
		PS C:\> Generate-Form
	
		N/A
#>
Function Generate-Form
{
#Generated form objects

$Form1 = New-Object System.Windows.Forms.Form
$lblRefreshInterval = New-Object System.Windows.Forms.Label
$numInterval = New-Object System.Windows.Forms.NumericUpDown
$btnQuit = New-Object System.Windows.Forms.Button
$btnGo = New-Object System.Windows.Forms.Button
$btnBrowse = New-Object System.Windows.Forms.Button
$dataGridView = New-Object System.Windows.Forms.DataGridView
$label2 = New-Object System.Windows.Forms.Label
$statusBar = New-Object System.Windows.Forms.StatusBar
$txtComputerList = New-Object System.Windows.Forms.TextBox
$timer1 = New-Object System.Windows.Forms.Timer
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog


#Event script Blocks

$GetStatus= 
{

    Trap 
    {
        Write-Warning $_.Exception.message
        Continue
    }
    
    #stop the timer while data is refreshed
    $timer1.stop()

    if ($computers) {Clear-Variable computers}
    
    #clear the table
    #$dataGridView.DataSource=$Null
    
    $computers=Get-Content $txtComputerList.Text -ea stop | sort 
    
    if ($computers) 
    {
       
        $statusBar.Text = ("Querying computers from {0}" -f $txtComputerList.Text)
        $form1.Refresh
        
        #create an array for griddata
        $griddata=@()
        #create a custom object
        
        foreach ($computer in $computers) 
        {
            $statusBar.Text=("Pinging {0}" -f $computer.toUpper())
            $obj=New-Object PSobject
                $obj | Add-Member -MemberType Noteproperty -Name Computername -Value $computer.ToUpper()
          
            #ping the computer
            if ($pingResult) 
            {
                #clear PingResult if it has a left over value
                Clear-Variable pingResult
            }

            $pingResult=Ping-Host $computer
      
            if ($pingResult.StatusCode -eq 0) 
            {
                $obj | Add-Member -MemberType Noteproperty -Name 'Pinged' -Value "Yes"
                $obj | Add-Member -MemberType Noteproperty -Name 'IP' -Value $pingResult.ProtocolAddress
                $obj | Add-Member -MemberType Noteproperty -Name 'Response Time' -Value $pingResult.responsetime
            }

            else 
            {
                $obj | Add-Member -MemberType Noteproperty -Name 'Pinged' -Value "No"
                $obj | Add-Member -MemberType Noteproperty -Name 'IP' -Value "N/A"
                $obj | Add-Member -MemberType Noteproperty -Name 'Response Time' -Value "N/A"
            }
        
        	#Add the object to griddata
            Write-Debug "Adding `$obj to `$griddata"
            $griddata+=$obj

		
        } #end foreach
        
 
        $array= New-Object System.Collections.ArrayList
        

        $array.AddRange($griddata)
        $DataGridView.DataSource = $array
        #find unpingable computer rows

        $c=$dataGridView.RowCount
        for ($x=0;$x -lt $c;$x++) {
            for ($y=0;$y -lt $dataGridView.Rows[$x].Cells.Count;$y++) {
                $value = $dataGridView.Rows[$x].Cells[$y].Value
                if ($value -eq "No") {
                #if Pinged cell = No change the row font color

                $dataGridView.rows[$x].DefaultCellStyle.Forecolor=[System.Drawing.Color]::FromArgb(255,255,0,0)
                }
            }
        }

        $statusBar.Text=("Ready. Last updated {0}" -f (Get-Date))

    }
    else {

        $statusBar.Text=("Failed to find {0}" -f $txtComputerList.text)
    }
   
   #set the timer interval
    $interval=$numInterval.value -as [int]

    #interval must be in milliseconds
    $timer1.Interval = ($interval * 1000) #1 minute time interval

    #start the timer

    $timer1.Start()

    $form1.Refresh()
   
}

$Quit= 
{
    $form1.Close()
}

$GetFile = 
{
$OpenFileDialog.initialDirectory = 'c:\'
$OpenFileDialog.filter = "TXT (*.txt)| *.txt"
$OpenFileDialog.ShowHelp = $true 
$OpenFileDialog.ShowDialog() | Out-Null
$txtComputerList.Text = $OpenFileDialog.filename
}


#################
#Form Properties#
#################

$Form1.Name = 'form1'
$Form1.Text = 'Ping Check Tool'
$Form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 890
$System_Drawing_Size.Height = 359
$Form1.ClientSize = $System_Drawing_Size
$Form1.StartPosition = 1
$Form1.BackColor = [System.Drawing.Color]::FromArgb(255,185,209,234)


###################################
#Refresh Interval Label Properties#
###################################

$lblRefreshInterval.Text = 'Refresh Interval (sec)'
$lblRefreshInterval.DataBindings.DefaultDataSourceUpdateMode = 0
$lblRefreshInterval.TabIndex = 10
$lblRefreshInterval.TextAlign = 64
$lblRefreshInterval.Name = 'lblRefreshInterval'
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 145
    $System_Drawing_Size.Height = 23
$lblRefreshInterval.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 540
    $System_Drawing_Point.Y = 28
$lblRefreshInterval.Location = $System_Drawing_Point
$form1.Controls.Add($lblRefreshInterval)

#####################################
#Refresh Interval Counter Properties#
#####################################

$numInterval.DataBindings.DefaultDataSourceUpdateMode = 0
$numInterval.Name = 'numInterval'
$numInterval.Value = 30
$numInterval.TabIndex = 9
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 51
    $System_Drawing_Size.Height = 20
$numInterval.Size = $System_Drawing_Size
$numInterval.Maximum = 60
$numInterval.Minimum = 10
$numInterval.Increment = 5
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 700
    $System_Drawing_Point.Y = 30
$numInterval.Location = $System_Drawing_Point
$form1.Controls.Add($numInterval)

########################
#Quit Button Properties#
########################

$btnQuit.UseVisualStyleBackColor = $True
$btnQuit.Text = 'Close'
$btnQuit.DataBindings.DefaultDataSourceUpdateMode = 0
$btnQuit.TabIndex = 2
$btnQuit.Name = 'btnQuit'
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
$btnQuit.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 800
    $System_Drawing_Point.Y = 30
$btnQuit.Location = $System_Drawing_Point
$btnQuit.add_Click($Quit)
$form1.Controls.Add($btnQuit)

######################
#Go Button Properties#
######################

$btnGo.UseVisualStyleBackColor = $True
$btnGo.Text = 'Start Ping'
$btnGo.DataBindings.DefaultDataSourceUpdateMode = 0
$btnGo.TabIndex = 1
$btnGo.Name = 'btnGo'
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 80
    $System_Drawing_Size.Height = 23
$btnGo.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 350
    $System_Drawing_Point.Y = 31
$btnGo.Location = $System_Drawing_Point
$btnGo.add_Click($GetStatus)
$form1.Controls.Add($btnGo)

##########################
#Browse Button Properties#
##########################

$btnBrowse.UseVisualStyleBackColor = $True
$btnBrowse.Text = 'Browse...'
$btnBrowse.DataBindings.DefaultDataSourceUpdateMode = 0
$btnBrowse.TabIndex = 1
$btnBrowse.Name = 'btnBrowse'
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 80
    $System_Drawing_Size.Height = 23
$btnBrowse.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 225
    $System_Drawing_Point.Y = 31
$btnBrowse.Location = $System_Drawing_Point
$btnBrowse.add_Click($GetFile)
$form1.Controls.Add($btnBrowse)

#########################
#DataGridView Properties#
#########################

$dataGridView.RowTemplate.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(255,0,128,0)
$dataGridView.Name = 'dataGridView'
$dataGridView.DataBindings.DefaultDataSourceUpdateMode = 0
$dataGridView.ReadOnly = $True
$dataGridView.AllowUserToDeleteRows = $False
$dataGridView.RowHeadersVisible = $False
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 870
    $System_Drawing_Size.Height = 260
$dataGridView.Size = $System_Drawing_Size
$dataGridView.TabIndex = 8
$dataGridView.Anchor = 15
$dataGridView.AutoSizeColumnsMode = 16
$dataGridView.AllowUserToAddRows = $False
$dataGridView.ColumnHeadersHeightSizeMode = 2
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 70
$dataGridView.Location = $System_Drawing_Point
$dataGridView.AllowUserToOrderColumns = $True
$form1.Controls.Add($dataGridView)

#################
#File Path Label#
#################
$label2.Text = 'Enter the path to a text file or browse for one.'
$label2.DataBindings.DefaultDataSourceUpdateMode = 0
$label2.TabIndex = 7
$label2.Name = 'label2'
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 600
    $System_Drawing_Size.Height = 23
$label2.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 12
    $System_Drawing_Point.Y = 7
$label2.Location = $System_Drawing_Point
$form1.Controls.Add($label2)

#######################
#Status Bar Properties#
#######################

$statusBar.Name = 'statusBar'
$statusBar.DataBindings.DefaultDataSourceUpdateMode = 0
$statusBar.TabIndex = 4
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 428
    $System_Drawing_Size.Height = 22
$statusBar.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 0
    $System_Drawing_Point.Y = 337
$statusBar.Location = $System_Drawing_Point
$statusBar.Text = 'Ready'
$form1.Controls.Add($statusBar)

#############################
#PC List text Box Properties#
#############################

$txtComputerList.Text = 'Browse for a path'
$txtComputerList.Name = 'txtComputerList'
$txtComputerList.TabIndex = 0
$System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 198
    $System_Drawing_Size.Height = 20
$txtComputerList.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 13
    $System_Drawing_Point.Y = 33
$txtComputerList.Location = $System_Drawing_Point
$txtComputerList.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Controls.Add($txtComputerList)


##################
#Timer Properties#
##################
$timer1.add_Tick($GetStatus)


#Launch the Form
$form1.ShowDialog()| Out-Null
}

Generate-Form