# Purpose: Task Dashboard — General-purpose PowerShell utilities.

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  Title="PowerShell Cockpit"
  Width="300"
  MinWidth ="200"
  SizeToContent="Height"
  WindowStyle="ToolWindow">
    <Grid Margin="5">
      <Grid.ColumnDefinitions>
          <ColumnDefinition Width="50*"></ColumnDefinition>
          <ColumnDefinition Width="50*"></ColumnDefinition>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
          <RowDefinition Height="Auto"></RowDefinition>
          <RowDefinition Height="Auto"></RowDefinition>
          <RowDefinition Height="*"></RowDefinition>
      </Grid.RowDefinitions>
  
      <Button Name="Job1" Width="80" Height="30" Margin="5" Grid.Column="0" Grid.Row="0">Task 1</Button>
      <Button Name="Job2" Width="80" Height="30" Margin="5" Grid.Column="1" Grid.Row="0">Task 2</Button>
      <Button Name="Job3" Width="80" Height="30" Margin="5" Grid.Column="0" Grid.Row="1">Task 3</Button>
      <Button Name="Job4" Width="80" Height="30" Margin="5" Grid.Column="1" Grid.Row="1">Task 4</Button>
      <Button Name="Job5" Width="80" Height="30" Margin="5" Grid.Column="0" Grid.Row="2">Task 5</Button>
      <Button Name="Job6" Width="80" Height="30" Margin="5" Grid.Column="1" Grid.Row="2">Task 6</Button>

    
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

# helper function to run code in separate thread:
function Start-InNewThread
{
    param
    (
        [ScriptBlock]$Code,
    
        [Hashtable]$Parameters = @{}
    )
  
    $powershell = [PowerShell]::Create()
    $action = {
   
        $status = $event.SourceEventArgs.InvocationStateInfo.State
    
        if ($status -eq 'Completed')
        {
            try
            {
                $powershell = $event.Sender
                $powershell.Runspace.Close()
                $powershell.Dispose()
                Unregister-Event -SourceIdentifier $event.SourceIdentifier 
            }
            catch
            {
                Write-Warning "$_"
            }
        }
    }
  
    $null = Register-ObjectEvent -InputObject $powershell -Action $action -EventName InvocationStateChanged 
    $null = $powershell.AddScript($Code)
  
    foreach($key in $Parameters.Keys)
    {
        $null = $powershell.AddParameter($key, $Parameters.$key)
    }
 
    $handle = $powershell.BeginInvoke()
}


$window = Convert-XAMLtoWindow -XAML $xaml

# Define Tasks:
$code1 = { [Console]::Beep(1000,1000) }
$code2 = { param($UI)
$UI.WriteLine('You clicked me!') }
$code3 = { Get-Service }
$code4 = { param($UI)
$UI.WriteLine((Get-Service | Out-String)) }
$code5 = { param($UI)
    $UI.WriteWarningLine('Sleeping for 5 sec while UI stays responsive')
Start-Sleep -Seconds 5}
$code6 = { $answer = [Windows.MessageBox]::Show('Do you want this?', 'My Dialog', 'YesNo') }

# Assign action to buttons:
$window.Job1.add_Click({ Start-InNewThread -Code $code1 })
$window.Job2.add_Click({ Start-InNewThread -Code $code2 -Parameter @{UI=$Host.UI} })
$window.Job3.add_Click({ Start-InNewThread -Code $code3 })
$window.Job4.add_Click({ Start-InNewThread -Code $code4 -Parameter @{UI=$Host.UI} })
$window.Job5.add_Click({ Start-InNewThread -Code $code5 -Parameter @{UI=$Host.UI} })
$window.Job6.add_Click({ Start-InNewThread -Code $code6 })

Show-WPFWindow -Window $window