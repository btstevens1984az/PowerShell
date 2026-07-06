# Purpose: Movie Player — General-purpose PowerShell utilities.

$XAML = @'
<Window Name="Window1"
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   Width="700" Height="500"
   Title="Movie Player" Topmost="True">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
            <MediaElement Margin="10" Grid.Row="0" Name="VideoPlayer" LoadedBehavior="Manual" UnloadedBehavior="Stop" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" />
            <Label Name="Status" Grid.Row="1" Content="Not playing..." HorizontalContentAlignment="Center" Margin="5" />
            <ProgressBar Name="Progress" Grid.Row="2" HorizontalAlignment="Stretch" Value="0" Height="20" Margin="5"></ProgressBar>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Grid.Row="3">
                <Button Content="Pause" Name="PauseButton" IsEnabled="True" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75"/>
                <Button Content="Play" Name="PlayButton" IsEnabled="False" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75"/>
            </StackPanel>
        
    </Grid>
</Window>
'@
function Convert-XAMLtoWindow
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $XAML
    )
    
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
     
    $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
    $result = [Windows.Markup.XAMLReader]::Load($reader)
    $reader.Close()
    $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
    while ($reader.Read())
    {
        $name=$reader.GetAttribute('Name')
        if (!$name) { $name=$reader.GetAttribute('x:Name') }
        if($name)
        {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
    }
    $reader.Close()
    $result
}


function Show-WPFWindow
{
    param
    (
        [Parameter(Mandatory)]
        [Windows.Window]
        $Window
    )
    
    $result = $null
    $null = $window.Dispatcher.InvokeAsync{
        $result = $window.ShowDialog()
        Set-Variable -Name result -Value $result -Scope 1
    }.Wait()
    $result
}

$window = Convert-XAMLtoWindow -XAML $XAML

# adjust the movie path 
[uri]$VideoSource = "$env:windir\Performance\WinSAT\Clip_1080_5sec_VC1_15mbps.wmv"


 
$window.VideoPlayer.Volume = 100
$window.VideoPlayer.Source = $VideoSource
$window.VideoPlayer.Play()
 
$window.PlayButton.Add_Click{
    $window.VideoPlayer.Play()
    $window.PauseButton.IsEnabled = $true
    $window.PlayButton.IsEnabled = $false
    
    $timer.Start()
}

$window.PauseButton.Add_Click{
    $window.VideoPlayer.Pause()
    $window.PauseButton.IsEnabled = $false
    $window.PlayButton.IsEnabled = $true
}
$window.Window1.add_SourceInitialized{
    Add-Type -AssemblyName WindowsBase
    $script:timer = new-object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]"0:0:0.1"          
    $timer.Add_Tick{
        
        if($window.VideoPlayer.Source -ne $null)
        {
            if($window.VideoPlayer.NaturalDuration.HasTimeSpan)
            {
                $currentPosition = $window.VideoPlayer.Position
                $duration = $window.VideoPlayer.NaturalDuration.TimeSpan
                $window.Status.Content = "{0} / {1}" -f $currentPosition.ToString("mm\:ss"), $duration.ToString("mm\:ss")
                $percent = $currentPosition.TotalSeconds * 100 / $duration.TotalSeconds
                $window.Progress.Value = $percent
            }
        } 
        else 
        {
            $window.Status.Content = "No file selected..."
        }
    }          

    $timer.Start()         
}
$window.VideoPlayer.add_MediaEnded{
    $window.VideoPlayer.Stop()
    $window.Progress.Value = 100
    $timer.Stop()
    $window.Status.Content = 'Movie has ended.'
    $window.VideoPlayer.Position = New-TimeSpan 
    $window.PauseButton.IsEnabled = $false
    $window.PlayButton.IsEnabled = $true
}


 
$null = Show-WPFWindow -Window $window
