# Purpose: Event Sample — General-purpose PowerShell utilities.


$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   Width="525"
   SizeToContent="Height"
   Title="Hover Example" Topmost="True">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <TextBox Name="InputBox" Height="120" Grid.Row="0" TextWrapping="Wrap" Text="Hover over me!" Margin="5"  HorizontalAlignment="Stretch" VerticalAlignment="Top" />
        <Button Name="OK" Width="80" Height="25" Grid.Row="1"  HorizontalAlignment="Right" Margin="5" VerticalAlignment="Bottom">OK</Button>
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


$window.InputBox.add_MouseLeave{
    $window.InputBox.Background = "#FFFFFF"
  }

$window.InputBox.add_MouseEnter{
    $window.InputBox.Background = "#AAFFAA"
  }
$window.OK.add_Click{
    $window.DialogResult = $true
}

$null = Show-WPFWindow -Window $window

