# Purpose: Validating Input — General-purpose PowerShell utilities.

$xaml = @'
<Window
 xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
 xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
 Title='Enter IPv4' FontSize="15"
  Width="600" Height="200">
    <Viewbox Stretch="Fill">
        <Grid HorizontalAlignment="Stretch" Margin="10">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto" />
                <RowDefinition Height="28" />
                <RowDefinition Height="*" />

            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto" />
                <ColumnDefinition Width="*" MinWidth="400" />
            </Grid.ColumnDefinitions>

            <Label Grid.Row="0" Grid.Column="0" Content="IPv4" Width="60"/>
            <TextBox Name='IPv4' FontFamily="Consolas" FontSize="20" Grid.Column="1" Grid.Row="0" Margin="3" />
            <Button Name='ButtonOK' Grid.Column="1" Grid.Row="1" IsEnabled="False" HorizontalAlignment="Right" MinWidth="80" Margin="3" Content="OK" />


        </Grid>
    </Viewbox>
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


$window.IPv4.add_TextChanged{
    $window.ButtonOK.IsEnabled = $window.IPv4.Text -like '*.*.*.*' -and $window.IPv4.Text -as [System.Net.IPAddress]
}
$window.ButtonOK.add_Click{
    # remove param() block if access to event information is not required
    $window.DialogResult = $true
}


$null = $window.IPv4.Focus()

$null = Show-WPFWindow -Window $window
$ip = $window.IPv4.Text
"You entered $ip"