# Purpose: Build-AdvGUI — Standalone GUI applications and utilities.
######################################################################
# PowerShell Form Designer
# The prototype was "PowerShell Form Builder" by Brandon Stevens <https://gallery.technet.microsoft.com/scriptcenter/Powershell-Form-Builder-3bcaf2c7>
$ Version = '2.1.0'
# PowerShell 2.0 or later
######################################################################

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$Global:frmDesign = $null
$Global:CurrentCtrl = $null
$Global:Source = ''
$Global:iCurFirstX = 0
$Global:iCurFirstY = 0

# --- Resize and move control --------------------------------------
function mouseDown {
	$Global:iCurFirstX = ([System.Windows.Forms.Cursor]::Position.X)
	$Global:iCurFirstY = ([System.Windows.Forms.Cursor]::Position.Y)
}

function mouseMove ($mControlName) {
	$iCurPosX = ([System.Windows.Forms.Cursor]::Position.X)
	$iCurPosY = ([System.Windows.Forms.Cursor]::Position.Y)
	$iBorderWidth = ($Global:frmDesign.Width - $Global:frmDesign.ClientSize.Width) / 2
	$iTitlebarHeight = $Global:frmDesign.Height - $Global:frmDesign.ClientSize.Height - 2 * $iBorderWidth

	if ($Global:iCurFirstX -eq 0 -and $Global:iCurFirstY -eq 0){
		if ($this.Parent -ne $Global:frmDesign) {
			$GroupBoxLocationX = $this.Parent.Location.X
			$GroupBoxLocationY = $this.Parent.Location.Y
		} else {
			$GroupBoxLocationX = 0
			$GroupBoxLocationY = 0
		}
		$bIsWidthChinge = ($iCurPosX - $Global:frmDesign.Location.X - $GroupBoxLocationX - $this.Location.X) -ge $this.Width
		$bIsHeightChange = ($iCurPosY - $Global:frmDesign.Location.Y - $GroupBoxLocationY - $this.Location.Y) -ge ($this.Height + $iTitlebarHeight)

		if ($bIsWidthChinge -and $bIsHeightChange) {
			$this.Cursor = "SizeNWSE"
		} elseif ($bIsWidthChinge) {
			$this.Cursor = "SizeWE"
		} elseif ($bIsHeightChange) {
			$this.Cursor = "SizeNS"
		} else {
			$this.Cursor = "SizeAll"
		}
	} else {
		$mDifX = $Global:iCurFirstX - $iCurPosX
		$mDifY = $Global:iCurFirstY - $iCurPosY
		switch ($this.Cursor){
			"[Cursor: SizeWE]"  {$this.Width = $this.Width - $mDifX}
			"[Cursor: SizeNS]"  {$this.Height = $this.Height - $mDifY}
			"[Cursor: SizeNWSE]"{
									$this.Width = $this.Width - $mDifX
									$this.Height = $this.Height - $mDifY
								}
			"[Cursor: SizeAll]" {
									$this.Left = $this.Left - $mDifX
									$this.Top = $this.Top - $mDifY
								}
		}
		$Global:iCurFirstX = $iCurPosX
		$Global:iCurFirstY = $iCurPosY
	}
}

function mouseUP {
	$this.Cursor = "SizeAll"
	$Global:iCurFirstX = 0
	$Global:iCurFirstY = 0
	ListProperties
}

function ResizeAndMoveWithKeyboard {
	if ($Global:CurrentCtrl) {
		if     ($_.KeyCode -eq 'Left'  -and $_.Modifiers -eq 'None')    {$Global:CurrentCtrl.Left   -= 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Left'  -and $_.Modifiers -eq 'Control') {$Global:CurrentCtrl.Width  -= 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Right' -and $_.Modifiers -eq 'None')    {$Global:CurrentCtrl.Left   += 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Right' -and $_.Modifiers -eq 'Control') {$Global:CurrentCtrl.Width  += 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Up'    -and $_.Modifiers -eq 'None')    {$Global:CurrentCtrl.Top    -= 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Up'    -and $_.Modifiers -eq 'Control') {$Global:CurrentCtrl.Height -= 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Down'  -and $_.Modifiers -eq 'None')    {$Global:CurrentCtrl.Top    += 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Down'  -and $_.Modifiers -eq 'Control') {$Global:CurrentCtrl.Height += 1; $_.Handled = $true; ListProperties}
		elseif ($_.KeyCode -eq 'Delete' -and $_.Modifiers -eq 'None')   {$_.Handled = $true; RemoveCurrentCtrl;}
	}
}

# --- Controls ---------------------------------------
function GetCtrlType($ctrl) {
	return $ctrl.GetType().FullName -replace "System.Windows.Forms.", ""
}

function RemoveCurrentCtrl {
	$Global:frmDesign.Controls.Remove($Global:CurrentCtrl)
	$Global:CurrentCtrl = $Global:frmDesign
	ListControls
}

function SelectCurrentCtrlOnListControls {
	$dgvControls.Rows |% {if ($_.Cells[0].Value -eq $Global:CurrentCtrl.Name) {$_.Selected=$true; return}}
}

function ListControls {
	function EnumerateControls($container){
		foreach ($ctrl in $container.Controls) {
			$type = GetCtrlType $ctrl
			if ($type -eq 'GroupBox') {
				EnumerateControls $ctrl
			}
			$dgvControls.Rows.Add($ctrl.Name, $type, $ctrl)
		}
	}

	$dgvControls.Rows.Clear()
	$dgvControls.Rows.Add($Global:frmDesign.Name, 'Form', $Global:frmDesign)
	EnumerateControls $Global:frmDesign
	SelectCurrentCtrlOnListControls
}

function SetCurrentCtrl($arg){
	if ($arg.GetType().FullName -eq 'System.Int32') { # щелчок по ряду $dgvControls
		$Global:CurrentCtrl = $dgvControls.Rows[$arg].Cells[2].Value
	} else { # щелчок по контолу на $frmDesign или программный выбор
		$Global:CurrentCtrl = $arg
		SelectCurrentCtrlOnListControls
	}

	$tmp_back = $Global:CurrentCtrl.BackColor
	for ($i = 0; $i -lt 3; $i++){
		$Global:CurrentCtrl.BackColor = 'Yellow'
		Start-Sleep -m 100
		$Global:CurrentCtrl.BackColor = 'Red'
		Start-Sleep -m 100
	}
	$Global:CurrentCtrl.BackColor = $tmp_back

	$Global:CurrentCtrl.Focus()
	ListAvailableProperties
	ListProperties
	ListAvailableEvents
	ListEvents
}

$btnAddControl_Click = {
	function CreateNewCtrlName($ctrl_type) {
		$arrCtrlNames = $dgvControls.Rows | % {$_.Cells[0].Value}
		$num = 0
		do {
			$NewCtrlName = $ctrl_type + $num
			$num += 1
		} while ($arrCtrlNames -contains $NewCtrlName)
		return $NewCtrlName
	}

	$ctrl_type = $cbAddControl.Items[$cbAddControl.SelectedIndex]
	$Control = New-Object System.Windows.Forms.$ctrl_type
	$Control.Name = CreateNewCtrlName $ctrl_type
	$Control.Cursor = 'SizeAll'
	if ($ctrl_type -eq 'ComboBox')    {$Control.IntegralHeight = $false}
	elseif ($ctrl_type -eq 'ListBox') {$Control.IntegralHeight = $false}
	$Control.Tag = @('Name','Left','Top','Width','Height')
	if (@('Button', 'CheckBox', 'GroupBox', 'Label', 'RadioButton') -contains $ctrl_type) {
		$Control.Text = $Control.Name
		$Control.Tag += 'Text'
	}
	$Control.Add_PreviewKeyDown({$_.IsInputKey = $true})
	$Control.Add_KeyDown({ResizeAndMoveWithKeyboard})
	$Control.Add_MouseDown({MouseDown})
	$Control.Add_MouseMove({MouseMove})
	$Control.Add_MouseUP({MouseUP})
	$Control.Add_Click({SetCurrentCtrl $this})
	$cur_ctrl_type = GetCtrlType $Global:CurrentCtrl
	if ($cur_ctrl_type -eq 'GroupBox') {
		$Global:CurrentCtrl.Controls.Add($Control)
	} else {
		$Global:frmDesign.Controls.Add($Control)
		SetCurrentCtrl $Control
	}
	ListControls
}

# --- Properties ---------------------------------------
function ListAvailableProperties {
	$cbAddProp.Items.Clear()
	$Global:CurrentCtrl | Get-Member -membertype properties | % {$cbAddProp.Items.Add($_.Name)}
}

function ListProperties {
	try {$dgvProps.Rows.Clear()} catch {return}
	[array]$props = $Global:CurrentCtrl | Get-Member -membertype properties
	foreach ($prop in $props) {
		$pname = $prop.Name
		if ($Global:CurrentCtrl.Tag -contains $pname) {
			$value = $Global:CurrentCtrl.$pname
			if ($value.GetType().FullName -eq 'System.Drawing.Font') {
				$value = $value.Name + ', ' + $value.SizeInPoints + ', ' + $value.Style
			}
			$value = $value -replace 'Color \[(\w+)\]', '$1'
			$dgvProps.Rows.Add($pname, $value)
		}
	}
}

function AddProperty($prop_name){
	$Global:CurrentCtrl.Tag += $prop_name
	ListProperties
}

$dgvProps_CellEndEdit = {
	$prop_name = $dgvProps.CurrentRow.Cells[0].Value
	$value = $dgvProps.CurrentRow.Cells[1].Value

	$arrMatches = [regex]::matches($value, '^([\w ]+),\s*(\d+),\s*(\w+)$')
	if ($arrMatches.Success) { # Font
		foreach ($m in $arrMatches) {
			$font_name = [string]$m.Groups[1]
			$font_size = [string]$m.Groups[2]
			$font_style = [string]$m.Groups[3]
			$Global:CurrentCtrl.Font = New-Object System.Drawing.Font($font_name, $font_size, [System.Drawing.FontStyle]::$font_style)
		}
	} else {
		if ($value -eq 'True') {$value = $true}
		elseif ($value -eq 'False') {$value = $false}
		$Global:CurrentCtrl.$prop_name = $value
	}
	if ($Global:CurrentCtrl.Tag -notcontains $prop_name) {$Global:CurrentCtrl.Tag += $prop_name}
	if ($prop_name -eq 'Name') {ListControls}
	ListProperties
}

# --- Events ---------------------------------------
function ListAvailableEvents {
	$cbAddEvent.Items.Clear()
	$Global:CurrentCtrl | Get-Member | % {if ($_ -like '*EventHandler*') {$cbAddEvent.Items.Add($_.Name)}}
}

function ListEvents {
	$dgvEvents.Rows.Clear()
	[array]$props = $Global:CurrentCtrl | Get-Member | ? {$_ -like '*EventHandler*'}
	foreach ($prop in $props) {
		$pname = $prop.Name
		if ($Global:CurrentCtrl.Tag -like "Add_$pname(*") {
			$dgvEvents.Rows.Add($pname)
		}
	}
}

$btnAddEvent_Click = {
	$event = $cbAddEvent.Items[$cbAddEvent.SelectedIndex]
	$Global:CurrentCtrl.Tag += 'Add_' + $event + '($' + $Global:CurrentCtrl.Name + '_' + $event + ')'
	ListEvents
}

# --- New Form ---------------------------------------
function EnableButtons{
	$btnSaveForm.Enabled = $true
	$btnAddControl.Enabled = $true
	$btnRemoveControl.Enabled = $true
	$btnAddProp.Enabled = $true
	$btnNewForm.Enabled = $false
	$btnOpenForm.Enabled = $false
}

$btnNewForm_Click = {
	$Global:frmDesign = New-Object System.Windows.Forms.Form
	$Global:frmDesign.Name = 'Form0'
	$Global:frmDesign.Text = 'Form0'
	$Global:frmDesign.Tag = @('Name','Width','Height','Text')
	$Global:frmDesign.Add_ResizeEnd({ListProperties})
	$Global:frmDesign.Add_FormClosing({$_.Cancel = $true})
	$Global:frmDesign.Show()
	$Global:CurrentCtrl = $Global:frmDesign
	ListControls
	ListAvailableProperties
	ListProperties
	ListAvailableEvents
	ListEvents
	EnableButtons
}

# --- Save Form ---------------------------------------
function GetFilename($dlg_name)  {
	$Dialog = New-Object System.Windows.Forms.$dlg_name
	$Dialog.Filter = "Powershell Script (*.ps1)|*.ps1|All files (*.*)|*.*"
	$Dialog.ShowDialog() | Out-Null
	return $Dialog.filename
}

$btnSaveForm_Click = {
	function EnumerateSaveControls ($container){
		$newline = "`r`n"
		$Global:Source += '#' + $newline + '#' + $container.Name + $newline + '#' + $newline
		$ctrl_type = GetCtrlType $container
		$Global:Source += '$' + $container.Name + ' = New-Object System.Windows.Forms.' + $ctrl_type + $newline
		$left = 0; $top = 0; $width = 0; $height = 0;
		[array]$props = $container | Get-Member -membertype properties
		foreach ($prop in $props) {
			$pname = $prop.Name
			if ($container.Tag -contains $pname -and $pname -ne "Name") {
				if     ($pname -eq "Left")   {$left = $container.Left}
				elseif ($pname -eq "Top")    {$top = $container.Top}
				elseif ($pname -eq "Width")  {$width = $container.Width}
				elseif ($pname -eq "Height") {$height = $container.Height}
				else {
					$value = $container.$pname
					if ($value.GetType().FullName -eq 'System.Drawing.Font') {
						$font_name = $value.Name
						$font_size = $value.SizeInPoints
						$font_style = $value.Style
						$value = 'New-Object System.Drawing.Font("' + $font_name + '", ' + $font_size + ', [System.Drawing.FontStyle]::' + $font_style + ")"
					} else {
						$value = $value -replace 'True', '$true' -replace 'False', '$false' -replace 'Color \[(\w+)\]', '$1'
						if ($value -ne '$true' -and $value -ne '$false') {$value = '"' + $value + '"'}
					}
					$Global:Source += '$' + $container.Name + '.' + $pname + ' = ' + $value + $newline
				}
			}
		}

		foreach ($event in $container.Tag) {
			if ($event -like "Add_*") {$Global:Source += '$' + $container.Name + '.' + $event + $newline}
		}

		if ($ctrl_type -eq 'Form') { # --- Form ----------
			$width = $container.ClientSize.Width
			$height = $container.ClientSize.Height
			$Global:Source += '$' + $container.Name + '.ClientSize = New-Object System.Drawing.Size(' + $width + ', ' + $height + ')' + $newline
		} else { # ------------ Other controls ------------
			if ($width -ne 0 -and $height -ne 0) {
				$Global:Source += '$' + $container.Name + '.Size = New-Object System.Drawing.Size(' + $width + ', ' + $height + ')' + $newline
			}

			$Global:Source += '$' + $container.Name + '.Location = New-Object System.Drawing.Point(' + $left + ', ' + $top + ')' + $newline
			$Global:Source += '$' + $container.Parent.Name + '.Controls.Add($' + $container.Name + ')' + $newline
		}
		# ------------ Containers ------------
		if ($ctrl_type -eq 'Form' -or $ctrl_type -eq 'GroupBox') {
			foreach ($ctrl in $container.Controls) {
				EnumerateSaveControls $ctrl
			}
		}
	}

	$newline = "`r`n"
	$Global:Source  = 'Add-Type -AssemblyName System.Windows.Forms' + $newline
	$Global:Source += 'Add-Type -AssemblyName System.Drawing' + $newline
	$Global:Source += '[Windows.Forms.Application]::EnableVisualStyles()' + $newline

	EnumerateSaveControls $Global:frmDesign

	$Global:Source += $newline + '[void]$' + $Global:frmDesign.Name + '.ShowDialog()' + $newline
	$filename = ''
	$filename = GetFilename 'SaveFileDialog'
	if ($filename -notlike '') {$Global:Source > $filename}
}

# --- Open Exist Form ---------------------------------------
$btnOpenForm_Click = {
	function SetControlTag($ctrl){ # Находим свойства и события контрола, которые были заданы в коде и добавляем их в $ctrl.Tag
		$pattern = '(.*)\$' + $ctrl.Name + '\.(?:(\w+)\s*=|(Add_[^\r\n]+))'
		$arrMatches = [regex]::matches($Global:Source, $pattern)
		$arrTags = @()
		foreach ($m in $arrMatches) {
			[string]$comment = $m.Groups[1]
			if (-not $comment.Contains('#')) {
				$prop_name = [string]$m.Groups[2]
				if ($prop_name) {
					if ($prop_name -eq 'Location')                                 {$arrTags += @('Left','Top')}
					elseif ($prop_name -eq 'Size' -or $prop_name -eq 'ClientSize') {$arrTags += @('Width','Height')}
					else {$arrTags += $prop_name}
				}
				$event_handler = [string]$m.Groups[3]
				if ($event_handler) {
					$arrTags += $event_handler
				}
			}
		}
		if ($arrTags -notcontains 'Name') {$arrTags += 'Name'}
		$ctrl.Tag = $arrTags
	}

	function EnumerateLoadControls($container) {
		foreach ($ctrl in $container.Controls) {
			SetControlTag $ctrl
			$ctrl_type = GetCtrlType $ctrl
			if ($ctrl_type -eq 'GroupBox') {
				EnumerateLoadControls $ctrl
			}
			if ($ctrl_type -eq 'ComboBox')    {$ctrl.IntegralHeight = $false}
			elseif ($ctrl_type -eq 'ListBox') {$ctrl.IntegralHeight = $false}
			elseif ($ctrl_type -ne 'WebBrowser') {
				$ctrl.Cursor = 'SizeAll'
				$ctrl.Add_PreviewKeyDown({$_.IsInputKey = $true})
				$ctrl.Add_KeyDown({ResizeAndMoveWithKeyboard})
				$ctrl.Add_MouseDown({MouseDown})
				$ctrl.Add_MouseMove({MouseMove})
				$ctrl.Add_MouseUP({MouseUP})
				$ctrl.Add_Click({SetCurrentCtrl $this})
			}
		}
	}

	$filename = GetFilename 'OpenFileDialog'
	if ($filename -notlike ''){
		$Global:Source = get-content $filename | Out-String
		# Анализ текста кода - поиск объявления формы
		$pattern = '(.*)\$(\w+)\s*=\s*New\-Object\s+(System\.)?Windows\.Forms\.Form'
		$arrMatches = [regex]::matches($Global:Source, $pattern)
		foreach ($m in $arrMatches) {
			[string]$comment = $m.Groups[1]
			if (-not $comment.Contains('#')) {
				$form_name = $m.Groups[2]
			}
		}
		if ($form_name) { # если в тексте удалось найти имя формы
			$find = '\$' + $form_name + '\.Show(Dialog)?\(\)'
			$Global:Source = $Global:Source -replace $find, '' # удаляем строку ее запуска

			Invoke-Expression -Command $Global:Source # Выполнение кода содержащего форму

			try {$Global:frmDesign = Get-Variable -ValueOnly $form_name} catch {} # Ищем в переменных PowerShell имя формы
			if ($Global:frmDesign) {
				# Добавляем всем контролам на форме property Name, равной имени переменной, хранящей их
				Get-Variable | where {[string]$_.Value -like 'System.Windows.Forms.*'} | where {try {$_.Value.Name = $_.Name} catch {}}

				# Задаем нужные свойства и эвенты всем контролам на форме
				EnumerateLoadControls $Global:frmDesign
				# И самой форме тоже
				$Global:frmDesign.Name = $form_name
				SetControlTag $Global:frmDesign
				$Global:frmDesign.Add_ResizeEnd({ListProperties})
				$Global:frmDesign.Add_FormClosing({$_.Cancel = $true})
				$Global:frmDesign.Show()

				$Global:CurrentCtrl = $Global:frmDesign
				ListControls
				ListAvailableProperties
				ListProperties
				ListAvailableEvents
				ListEvents
				EnableButtons
			} else {
				$message = "Can't find variable $" + $form_name + "`nPlease open ONLY SOURCE OF FORM.`nExclude other code."
				[System.Windows.Forms.MessageBox]::Show($message, 'Error to open exist Form', 'OK', 'Error')
			}
		} else {
			$message = 'Your code not contain any form!'
			[System.Windows.Forms.MessageBox]::Show($message, 'Error to open exist Form', 'OK', 'Error')
		}
	}
}

# --- Show Main Window ---------------------------------------
function ShowMainWindow {
	#
	#frmPSFD
	#
	$frmPSFD = New-Object System.Windows.Forms.Form
	$frmPSFD.ClientSize = New-Object System.Drawing.Size(549, 524)
	$frmPSFD.FormBorderStyle = 'Fixed3D'
	$frmPSFD.MaximizeBox = $false
	$frmPSFD.Text = 'PowerShell Form Designer ' + $Version
	#
	#btnNewForm
	#
	$btnNewForm = New-Object System.Windows.Forms.Button
	$btnNewForm.Location = New-Object System.Drawing.Point(12, 12)
	$btnNewForm.Size = New-Object System.Drawing.Size(88, 23)
	$btnNewForm.Text = "New Form"
	$btnNewForm.Add_Click($btnNewForm_Click)
	$frmPSFD.Controls.Add($btnNewForm)
	#
	#btnOpenForm
	#
	$btnOpenForm = New-Object System.Windows.Forms.Button
	$btnOpenForm.Location = New-Object System.Drawing.Point(114, 12)
	$btnOpenForm.Size = New-Object System.Drawing.Size(88, 23)
	$btnOpenForm.Text = "Open Form"
	$btnOpenForm.Add_Click($btnOpenForm_Click)
	$frmPSFD.Controls.Add($btnOpenForm)
	#
	#btnSaveForm
	#
	$btnSaveForm = New-Object System.Windows.Forms.Button
	$btnSaveForm.Location = New-Object System.Drawing.Point(450, 12)
	$btnSaveForm.Size = New-Object System.Drawing.Size(88, 23)
	$btnSaveForm.Text = "Save Form"
	$btnSaveForm.Enabled = $false
	$btnSaveForm.Add_Click($btnSaveForm_Click)
	$frmPSFD.Controls.Add($btnSaveForm)
	# --------------------------------------------------------
	#gbControls
	#
	$gbControls = New-Object Windows.Forms.GroupBox
	$gbControls.Location = New-Object System.Drawing.Point(12, 41)
	$gbControls.Size = New-Object System.Drawing.Size(260, 472)
	$gbControls.Text = "Controls:"
	$frmPSFD.Controls.Add($gbControls)
	#
	#cbAddControl
	#
	$cbAddControl = New-Object Windows.Forms.ComboBox
	$cbAddControl.Location = New-Object System.Drawing.Point(8, 14)
	$cbAddControl.Size = New-Object System.Drawing.Size(182, 21)
	$null = $cbAddControl.Items.Add("Button")
	$null = $cbAddControl.Items.Add("CheckBox")
	$null = $cbAddControl.Items.Add("ComboBox")
	$null = $cbAddControl.Items.Add("DataGridView")
	$null = $cbAddControl.Items.Add("DateTimePicker")
	$null = $cbAddControl.Items.Add("GroupBox")
	$null = $cbAddControl.Items.Add("Label")
	$null = $cbAddControl.Items.Add("ListBox")
	$null = $cbAddControl.Items.Add("ListView")
	$null = $cbAddControl.Items.Add("RadioButton")
	$null = $cbAddControl.Items.Add("PictureBox")
	$null = $cbAddControl.Items.Add("RichTextBox")
	$null = $cbAddControl.Items.Add("TextBox")
	$null = $cbAddControl.Items.Add("TreeView")
	$gbControls.Controls.Add($cbAddControl)
	#
	#btnAddControl
	#
	$btnAddControl = New-Object System.Windows.Forms.Button
	$btnAddControl.Location = New-Object System.Drawing.Point(196, 14)
	$btnAddControl.Size = New-Object System.Drawing.Size(58, 23)
	$btnAddControl.Text = "Add"
	$btnAddControl.Add_Click($btnAddControl_Click)
	$btnAddControl.Enabled = $false
	$gbControls.Controls.Add($btnAddControl)
	#
	#btnRemoveControl
	#
	$btnRemoveControl = New-Object System.Windows.Forms.Button
	$btnRemoveControl.Location = New-Object System.Drawing.Point(196, 43)
	$btnRemoveControl.Size = New-Object System.Drawing.Size(58, 23)
	$btnRemoveControl.Text = "Remove"
	$btnRemoveControl.Enabled = $false
	$btnRemoveControl.Add_Click({RemoveCurrentCtrl})
	$gbControls.Controls.Add($btnRemoveControl)
	#
	#lvControls
	#
	$dgvControls = New-Object System.Windows.Forms.DataGridView
	$dgvControls.Location = New-Object System.Drawing.Point(6, 70)
	$dgvControls.Size = New-Object System.Drawing.Size(248, 396)
	$null = $dgvControls.Columns.Add("", "Name")
	$null = $dgvControls.Columns.Add("", "Type")
	$null = $dgvControls.Columns.Add("", "LinkToControl")
	$dgvControls.Columns[0].Width = 159
	$dgvControls.Columns[1].Width = 86
	$dgvControls.Columns[2].Width = 0
	$dgvControls.Columns[0].ReadOnly = $true
	$dgvControls.Columns[1].ReadOnly = $true
	$dgvControls.ColumnHeadersHeightSizeMode = 'DisableResizing'
	$dgvControls.RowHeadersVisible = $false
	$dgvControls.MultiSelect = $false
	$dgvControls.ScrollBars = 'Vertical'
	$dgvControls.SelectionMode = 'FullRowSelect'
	$dgvControls.AllowUserToResizeRows = $false
	$dgvControls.AllowUserToAddRows = $false
	$dgvControls.Add_CellClick({SetCurrentCtrl $dgvControls.CurrentRow.Index})
	$gbControls.Controls.Add($dgvControls)
	#--------------------------------------------------------
	#gbProps
	#
	$gbProps = New-Object Windows.Forms.GroupBox
	$gbProps.Location = New-Object System.Drawing.Point(278, 41)
	$gbProps.Size = New-Object System.Drawing.Size(260, 350)
	$gbProps.Text = 'Properties:'
	$frmPSFD.Controls.Add($gbProps)
	#
	#cbAddProp
	#
	$cbAddProp = New-Object Windows.Forms.ComboBox
	$cbAddProp.Location = New-Object System.Drawing.Point(6, 14)
	$cbAddProp.Size = New-Object System.Drawing.Size(182, 21)
	$gbProps.Controls.Add($cbAddProp)
	#
	#btnAddProp
	#
	$btnAddProp = New-Object System.Windows.Forms.Button
	$btnAddProp.Location = New-Object System.Drawing.Point(194, 14)
	$btnAddProp.Size = New-Object System.Drawing.Size(58, 23)
	$btnAddProp.Text = "Add"
	$btnAddProp.Add_Click({AddProperty $cbAddProp.Text})
	$btnAddProp.Enabled = $false
	$gbProps.Controls.Add($btnAddProp)
	#
	#lblTooltip
	#
	$lblTooltip = New-Object System.Windows.Forms.Label
	$lblTooltip.Text = "Use Arrow keys and Ctrl to move and resize"
	$lblTooltip.Location = New-Object System.Drawing.Point(6, 44)
	$lblTooltip.Size = New-Object System.Drawing.Size(245, 16)
	$lblTooltip.Enabled = $false
	$gbProps.Controls.Add($lblTooltip)
	#
	#dgvProps
	#
	$dgvProps = New-Object System.Windows.Forms.DataGridView
	$dgvProps.Location = New-Object System.Drawing.Point(6, 70)
	$dgvProps.Size = New-Object System.Drawing.Size(248, 274)
	$null = $dgvProps.Columns.Add("", "Property")
	$null = $dgvProps.Columns.Add("", "Value")
	$dgvProps.Columns[0].Width = 75
	$dgvProps.Columns[1].Width = 170
	$dgvProps.Columns[0].ReadOnly = $true
	$dgvProps.ColumnHeadersHeightSizeMode = 'DisableResizing'
	$dgvProps.RowHeadersVisible = $false
	$dgvProps.AllowUserToResizeRows = $false
	$dgvProps.AllowUserToAddRows = $false
	$dgvProps.Add_CellEndEdit($dgvProps_CellEndEdit)
	$gbProps.Controls.Add($dgvProps)
	#--------------------------------------------------------
	#gbEvents
	#
	$gbEvents = New-Object System.Windows.Forms.GroupBox
	$gbEvents.Text = "Event Handlers:"
	$gbEvents.Size = New-Object System.Drawing.Size(260, 114)
	$gbEvents.Location = New-Object System.Drawing.Point(278, 398)
	$frmPSFD.Controls.Add($gbEvents)
	#
	#cbEvents
	#
	$cbAddEvent = New-Object System.Windows.Forms.ComboBox
	$cbAddEvent.Size = New-Object System.Drawing.Size(182, 21)
	$cbAddEvent.Location = New-Object System.Drawing.Point(6, 14)
	$gbEvents.Controls.Add($cbAddEvent)
	#
	#btnAddEvent
	#
	$btnAddEvent = New-Object System.Windows.Forms.Button
	$btnAddEvent.Text = "Add"
	$btnAddEvent.Size = New-Object System.Drawing.Size(58, 23)
	$btnAddEvent.Location = New-Object System.Drawing.Point(197, 14)
	$btnAddEvent.Add_Click($btnAddEvent_Click)
	$gbEvents.Controls.Add($btnAddEvent)
	#
	#dgvEvents
	#
	$dgvEvents = New-Object System.Windows.Forms.DataGridView
	$dgvEvents.Size = New-Object System.Drawing.Size(248, 66)
	$dgvEvents.Location = New-Object System.Drawing.Point(6, 43)
	$null = $dgvEvents.Columns.Add("", "Event")
	$dgvEvents.Columns[0].Width = 245
	$dgvEvents.ColumnHeadersVisible = $false
	$dgvEvents.RowHeadersVisible = $false
	$dgvEvents.AllowUserToResizeRows = $false
	$dgvEvents.AllowUserToAddRows = $false
	$dgvEvents.ScrollBars = 'Vertical'
	$gbEvents.Controls.Add($dgvEvents)
	#--------------------------------------------------------
	[void]$frmPSFD.ShowDialog()
}
ShowMainWindow
