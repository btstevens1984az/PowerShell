# Purpose: Grid Splitter — General-purpose PowerShell utilities.

$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   MinHeight="350"
   Width="525"
   SizeToContent="WidthAndHeight"
   Title="PowerShell WPF Window"
   Topmost="True">
   
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto" MinWidth="100"/>
            <ColumnDefinition Width="5"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
       
        <GridSplitter Grid.Column="1" HorizontalAlignment="Left" VerticalAlignment="Stretch" Width="5"/>
        <ListBox Name="L1" Grid.Column="0" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Background="Red" Foreground="White" />
        <ListBox Name="L2" Grid.Column="2" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Background="Green" Foreground="Wheat" />
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



$window = Convert-XAMLtoWindow -XAML $xaml

$window.L1.DisplayMemberPath = "DisplayName"
$window.L1.ItemsSource = Get-Service
$window.L2.DisplayMemberPath = "Name"
$window.L2.ItemsSource = Get-Process | Where-Object { $_.MainWindowHandle }

Show-WPFWindow -Window $window
