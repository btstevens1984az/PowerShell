# Purpose: Get-ServicesXAMLGUI — Standalone GUI applications and utilities.
# PowerShell GUI to get, start, stop services. Any help and comments are much appreciated. I'm always learning. 
# Date: Saturday, July 13, 2024

Add-Type -AssemblyName PresentationFramework

Function Check-Service($se){
  $serv=$se.trim()
  $re=Get-Service -Name "$serv" | where -Property Status -EQ "Running"
  $res.text += "Service running - $serv`r`n"
  }

Function Stopping-Service($se){
  $serv=$se.trim()
  $re=Stop-Service -Name "$serv"
  $res.text += "Service Stopped - $serv`r`n"
  }

Function Starting-Service($se){
  $serv=$se.trim()
  $re=Start-Service -Name "$serv"
  $res.text += "Service Started - $serv`r`n"
  }

  #Spooler
  [xml]$Form = @"
  <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Event Viewer" Height="350" Width="525" Background="#FF262626">
        <Grid>
        <Label Name="Service" Content="Service" HorizontalAlignment="Left" Height="26" Margin="10,41,0,0" VerticalAlignment="Top" Width="69" Foreground="White"/>
        <Label Name="Res" Content="Results" HorizontalAlignment="Left" Height="24" Margin="10,114,0,0" VerticalAlignment="Top" Width="92" Foreground="White" FontWeight="Bold"/>
        <TextBox Name="Serv" HorizontalAlignment="Left" Height="26" Margin="79,41,0,0" TextWrapping="Wrap" Text=" " VerticalAlignment="Top" Width="155" BorderBrush="#7.242.157.190"/>
        <TextBox Name="Results" HorizontalAlignment="Left" Height="156" Margin="10,141,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="495" BorderBrush="#7.242.157.190"/>
        <Button Name="Find" Content="Find Service" HorizontalAlignment="Left" Height="25" Margin="279,10,0,0" VerticalAlignment="Top" Width="226" Background="#7.242.157.190" Foreground="#FFFDFDFD" FontSize="21" FontWeight="Bold"/>
        <Button Name="Stop" Content="Stop Service" HorizontalAlignment="Left" Height="25" Margin="279,45,0,0" VerticalAlignment="Top" Width="226" Background="#7.242.157.190" Foreground="#FFFDFDFD" FontSize="21" FontWeight="Bold"/>
        <Button Name="Start" Content="Start Service" HorizontalAlignment="Left" Height="25" Margin="279,80,0,0" VerticalAlignment="Top" Width="226" Background="#7.242.157.190" Foreground="#FFFDFDFD" FontSize="21" FontWeight="Bold"/>
        </Grid>
  </Window>
"@

$NR=(New-Object System.Xml.XmlNodeReader $Form)
$Win=[Windows.Markup.XamlReader]::Load( $NR )

$find = $Win.FindName("Find")
$Stop = $win.FindName("Stop")
$Start = $Win.FindName("Start")
$serv = $Win.FindName("Serv")
$res = $Win.FindName("Results")

$find.Add_Click({
    $service=$serv.text
    If($service -eq ""){
      [System.Windows.MessageBox]::Show("Please add a service name", "Missing Service Name!")
    }ELSE{
      Check-Service $service}
})

$Stop.Add_Click({
    $service=$serv.text
    If($service -eq ""){
      [System.Windows.MessageBox]::Show("Please add a service name", "Missing Service Name!")
    }ELSE{
      Stopping-Service $service}
})

$start.Add_Click({
    $service=$serv.text
    If($service -eq ""){
      [System.Windows.MessageBox]::Show("Please add a service name", "Missing Service Name!")
    }ELSE{
      Starting-Service $service}
})

$Win.ShowDialog()
