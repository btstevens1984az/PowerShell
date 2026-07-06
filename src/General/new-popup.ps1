# Purpose: new-popup — General-purpose PowerShell utilities.
param(
    [int]$formWidth=200, 
    [int]$formHeight=110,
    [string]$title="Your title here",
    [string]$message="Your message here",
    [int]$wait=4,
    [switch]$slide
)

[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

###############################
# extract powershell icon if doesn't exist
$icon = "$env:temp\posh.ico"
if( !(test-path -pathType leaf $icon)){
    [System.Drawing.Icon]::ExtractAssociatedIcon((get-process -id $pid).path).ToBitmap().Save($icon)
}

###############################
# Create the form
$form = new-object System.Windows.Forms.Form
$form.ClientSize = new-object System.Drawing.Size($formWidth,$formHeight)
$form.BackColor = [System.Drawing.Color]::LightBlue
$form.ControlBox = $false
$form.ShowInTaskbar = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.topMost=$true

# initial form position
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual

if($slide){
    $top = $screen.WorkingArea.height + $form.height
    $left = $screen.WorkingArea.width - $form.width
    $form.Location = new-object System.Drawing.Point($left,$top)
} else {
    $top = $screen.WorkingArea.height - $form.height
    $left = $screen.WorkingArea.width - $form.width
    $form.Location = new-object System.Drawing.Point($left,$top)
}

###############################
## pictureBox for icon 
$pictureBox = new-object System.Windows.Forms.PictureBox 
$pictureBox.Location = new-object System.Drawing.Point(2,2)
$pictureBox.Size = new-object System.Drawing.Size(20,20)
$pictureBox.TabStop = $false
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$pictureBox.Load($icon)


###############################
## create textbox to display the  message
$textbox = new-object System.Windows.Forms.TextBox
$textbox.Text = $message
$textbox.BackColor = $form.BackColor
$textbox.Location = new-object System.Drawing.Point(4,26)
$textbox.Multiline = $true
$textbox.TabStop = $false
$textbox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$textbox.Size = new-object System.Drawing.Size(192,77)
$textbox.Cursor = [System.Windows.Forms.Cursors]::Default
$textbox.HideSelection = $false


###############################
## Create 'Close' button, when clicked hide and dispose the form
$button = new-object system.windows.forms.button 
$button.Font = new-object System.Drawing.Font("Webdings",8)
$button.Location = new-object System.Drawing.Point(182,3)
$button.Size = new-object System.Drawing.Size(16,16)
$button.Text = [char]114
$button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$button.Add_Click({ $form.hide(); $form.dispose() })
if($slide) {$button.visible=$false}


###############################
## Create a label, for title text
$label = new-object System.Windows.Forms.Label
$label.Font = new-object System.Drawing.Font("Microsoft Sans Serif",8,[System.Drawing.FontStyle]::Bold)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$label.Text = $title
$label.Location = new-object System.Drawing.Point(24,3)
$label.Size = new-object System.Drawing.Size(174, 20)


###############################
## Create a timer to slide the form
$timer = new-object System.Windows.Forms.Timer
$timer.Enabled=$false
$timer.Interval=15
$timer.tag="up"
$timer.add_tick({

    if(!$slide){return}

    if($timer.tag -eq "up"){
        $timer.enabled=$true
        $form.top-=2
        if($form.top -le ($screen.WorkingArea.height - $form.height)){
            #$timer.enabled=$false
            $timer.tag="down"
            start-sleep $wait
        }
    } else {

        $form.top+=2
        if($form.top -eq ($screen.WorkingArea.height + $form.height)){
            $timer.enabled=$false
            $form.dispose()
        }
    }
})


## add form event handlers
$form.add_shown({
    $form.Activate()
    (new-Object System.Media.SoundPlayer "$env:windir\Media\notify.wav").play()
    $timer.enabled=$true
})

## draw seperator line 
$form.add_paint({    
    $gfx = $form.CreateGraphics()        
    $pen = new-object System.Drawing.Pen([System.Drawing.Color]::Black)
    $gfx.drawLine($pen,0,24,$form.width,24)      
    $pen.dispose()
    $gfx.dispose()
})


###############################
## add controls to the form
## hide close button if form is not sliding

if($slide){
    $form.Controls.AddRange(@($label,$textbox,$pictureBox))
} else {
    $form.Controls.AddRange(@($button,$label,$textbox,$pictureBox))
}

###############################
## show the form
[void]$form.showdialog()