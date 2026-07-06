# Purpose: CreateGraph — IT reporting and dashboard generation.
Function Create-Graph {
# load the appropriate assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
# create chart object 
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
$Chart.Width = 1000 
$Chart.Height = 800 
$Chart.Left = 40 
$Chart.Top = 30
# create a chartarea to draw on and add to chart 
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$Chart.ChartAreas.Add($ChartArea)
# add data to chart 
$Cities = @{London=7556900; Berlin=3429900; Madrid=3213271; Rome=2726539;Paris=2188500} 
[void]$Chart.Series.Add("Data") 
$Chart.Series["Data"].Points.DataBindXY($Cities.Keys, $Cities.Values)
# display the chart on a form 
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
#$Form = New-Object Windows.Forms.Form 
#$Form.Text = "PowerShell Chart" 
#$Form.Width = 800 
#$Form.Height = 600 
#$Form.controls.add($Chart) 
#$Form.Add_Shown({$Form.Activate()}) 
#$Form.ShowDialog()
# add title and axes labels 
[void]$Chart.Titles.Add("Top 5 European Cities by Population") 
$ChartArea.AxisX.Title = "European Cities" 
$ChartArea.AxisY.Title = "Population"
# Find point with max/min values and change their colour 
$maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue() 
$maxValuePoint.Color = [System.Drawing.Color]::Red
$minValuePoint = $Chart.Series["Data"].Points.FindMinByValue() 
$minValuePoint.Color = [System.Drawing.Color]::Green
$Chart.BackColor = [System.Drawing.Color]::Transparent
# make bars into 3d cylinders 
$Chart.Series["Data"]["DrawingStyle"] = "Cylinder"
# add a save button 
$SaveButton = New-Object Windows.Forms.Button 
$SaveButton.Text = "Save" 
$SaveButton.Top = 500 
$SaveButton.Left = 450 
$SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right 
$SaveButton.add_click({$Chart.SaveImage($Env:USERPROFILE + "\Desktop\Chart.png", "PNG")})
$Form.controls.add($SaveButton)
# save chart to file 
$Chart.SaveImage($HOME + "\Desktop\Chart.png", "PNG")
}
