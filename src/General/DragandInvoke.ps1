# Purpose: DragandInvoke — General-purpose PowerShell utilities.
#Taken from: http://blogs.msdn.com/b/powershell/archive/2008/05/24/wpf-powershell-part-3-handling-events.aspx
Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase
$window = New-Object Windows.Window 
$window.SizeToContent = "WidthAndHeight" 
$label = New-Object Windows.Controls.Label 
$window.Title = $label.Content = "Drag Scipts Here, DoubleClick to Run" 
$listBox = New-Object Windows.Controls.Listbox 
$listBox.Height = 200 
$listBox.AllowDrop = $true 
$listBox.add_MouseDoubleClick({Invoke-Expression "$($listbox.SelectedItem)" -ea SilentlyContinue })    
$displayedFiles = @() 
$listBox.add_Drop({ 
    $files = $_.Data.GetFileDropList() 
    foreach ($file in $files) { 
       if ($file -is [IO.FileInfo]) { 
          $displayedFiles = $file 
       } else { 
          $displayedFiles += dir $file -recurse | ? { $_ -is [IO.FileInfo]} | % { $_.FullName } 
       } 
    } 
    $listBox.ItemsSource = $displayedFiles | sort 
}) 
$runButton = New-Object Windows.Controls.Button 
$runButton.Content = "Run" 
$runButton.add_Click({Invoke-Expression "$($listbox.SelectedItem)" -ea SilentlyContinue }) 
$clearButton = New-Object Windows.Controls.Button 
$clearButton.Content = "Clear" 
$clearButton.add_Click({$listBox.ItemsSource = @()}) 
$stackPanel = New-Object Windows.Controls.StackPanel 
$stackPanel.Orientation="Vertical" 
$children = $label, $listbox, $runButton, $clearButton 
foreach ($child in $children) { $null = $stackPanel.Children.Add($child) } 
$window.Content = $stackPanel 
$null = $window.ShowDialog() 

