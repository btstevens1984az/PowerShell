# Purpose: HelpOverview — General-purpose PowerShell utilities.
﻿Function Open-PoshPAIGHelp {
	$rs=[RunspaceFactory]::CreateRunspace()
	$rs.ApartmentState = "STA"
	$rs.ThreadOptions = "ReuseThread"
	$rs.Open()
	$ps = [PowerShell]::Create()
	$ps.Runspace = $rs
    $ps.Runspace.SessionStateProxy.SetVariable("pwd",$pwd)
	[void]$ps.AddScript({ 
[xml]$xaml = @"
<Window
    xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
    xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
    x:Name='Window' Title='Help For PowerShell Audit/Install GUI' Height = '600' Width = '800' WindowStartupLocation = 'CenterScreen' 
    ResizeMode = 'NoResize' ShowInTaskbar = 'True'>    
    <Window.Background>
        <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
            <LinearGradientBrush.GradientStops> <GradientStop Color='#C4CBD8' Offset='0' /> <GradientStop Color='#E6EAF5' Offset='0.2' /> 
            <GradientStop Color='#CFD7E2' Offset='0.9' /> <GradientStop Color='#C4CBD8' Offset='1' /> </LinearGradientBrush.GradientStops>
        </LinearGradientBrush>
    </Window.Background>    
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width ='30*'> </ColumnDefinition>
            <ColumnDefinition Width ='Auto'> </ColumnDefinition>
            <ColumnDefinition Width ='75*'> </ColumnDefinition>
        </Grid.ColumnDefinitions>
        <TreeView Name = 'HelpTree' FontSize='10pt'>
            <TreeViewItem x:Name = 'RequirementsView' Header = 'Requirements' />
            <TreeViewItem Header = 'Server List' />
            <TreeViewItem Header = 'Audit Patches' />
            <TreeViewItem Header = 'Install Patches' />
            <TreeViewItem Header = 'Reporting' />
            <TreeViewItem Header = 'Rebooting Servers' />    
            <TreeViewItem Header = 'Services Check' /> 
            <TreeViewItem Header = 'Ping Sweep' /> 
            <TreeViewItem Header = 'Pending Reboot Check' /> 
            <TreeViewItem Header = 'Installed Updates' /> 
            <TreeViewItem Header = 'Windows Update Log' /> 
            <TreeViewItem Header = 'Manage 31.39.1.252 Client Services' /> 
            <TreeViewItem Header = 'Reporting' />
            <TreeViewItem Header = 'Keyboard Shortcuts' />   
        </TreeView>
        <GridSplitter Grid.Column='1' Width='6' HorizontalAlignment = 'Center' VerticalAlignment = 'Stretch'>
        </GridSplitter>
        <Frame Name = 'Frame' Grid.Column = '2'>
            <Frame.Content>
            <Page Title = "Home">
                <FlowDocumentReader>
                    <FlowDocument>
                        <Paragraph FontSize = "20">
                            <Bold> PowerShell Audit/Install GUI </Bold>
                        </Paragraph>
                        <Paragraph>
                            Please click on one of the links on the left to view the various help items.
                        </Paragraph>
                        <Paragraph> <Image Source = '$pwd\HelpFiles\Images\PoshPAIG.JPG' /> </Paragraph>
                    </FlowDocument>
                </FlowDocumentReader>
            </Page>
            </Frame.Content>
        </Frame>
    </Grid>
</Window>

"@
#Load XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$HelpWindow=[Windows.Markup.XamlReader]::Load( $reader )

#Requirements Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Requirements">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Requirements for the PowerShell Audit/Install GUI </Bold>
            </Paragraph>
            <Paragraph FontSize = "14">
            It is highly recommended that you run this utility from you local machine and not from a UNC path. Using an account with Administrator rights is also recommended.
            </Paragraph>
            <Paragraph FontSize = "14">
            The basic requirements for using the PowerShell Audit/Install GUI are the following items:
            </Paragraph>
            <Paragraph FontSize = "14">
<Bold> PSexec.exe </Bold> is used for the installation of patches on remote systems. Without this file being in the same directory as the script, patch installation
will not be available. Download PSExec here: <Hyperlink x:Name = 'psexeclink'> http://technet.microsoft.com/en-us/sysinternals/bb896649 </Hyperlink>
            </Paragraph>          
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$Requirements=[Windows.Markup.XamlReader]::Load( $reader )

#ServerList Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Server List">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Adding servers to the Computer List. </Bold>
            </Paragraph>
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$ServerList=[Windows.Markup.XamlReader]::Load( $reader )

#AuditPatches Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Audit Patches">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Auditing patches on servers. </Bold>
            </Paragraph>
           <Paragraph FontSize = "14">
                Before you can begin Auditing patches, make sure that the Radio Button is checked for <Bold> Audit Patches </Bold>.
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\AuditRadioChecked.JPG' Width = '291' />
            </Paragraph>
            <Paragraph FontSize = "15">
                <Bold> Audit patches on all servers in server list </Bold>
            </Paragraph>
            <Paragraph FontSize = "14">
            Audting patches on all of the servers in the server list can be done by simply clicking the <Bold> Run </Bold> button.  Once you click run, the patch
auditing will begin iterating through each server in the list.  You can track the activity at the bottom via the progress and status bar.      
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\AuditAllServers.JPG' />
            </Paragraph>            
            <Paragraph FontSize = "15">
                <Bold> Audit patches on a single server in server list </Bold>
            </Paragraph>     
            <Paragraph FontSize = "14">
            To audit patches on a single server, you will need to double click on the selected server while the radio button is checked to Audit Patches. After you 
double click the server, the auditing of patches on that server will begin.    
            </Paragraph>              
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$AuditPatches=[Windows.Markup.XamlReader]::Load( $reader )

#InstallPatches Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Install Patches">
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Installing patches on servers. </Bold>
            </Paragraph>
            <Paragraph FontSize = "14">
                Before you can begin installing patches, make sure that the Radio Button is checked for <Bold> Install Patches </Bold>.
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\InstallRadioChecked.JPG' Width = '291' />
            </Paragraph>
            <Paragraph FontSize = "15">
                <Bold> Install patches on all servers in server list </Bold>
            </Paragraph>
            <Paragraph FontSize = "14">
            Installing patches on all of the servers in the server list can be done by simply clicking the <Bold> Run </Bold> button.  Once you click run, the patch
installation will begin iterating through each server in the list.  You can track the activity at the bottom via the progress and status bar.      
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\InstallAllServers.JPG' />
            </Paragraph>            
            <Paragraph FontSize = "15">
                <Bold> Install patches on a single server in server list </Bold>
            </Paragraph>     
            <Paragraph FontSize = "14">
            To install patches on a single server, you will need to double click on the selected server while the radio button is checked to Install Patches. After you 
double click the server, the installation of patches on that server will begin.    
            </Paragraph>                   
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$InstallPatches=[Windows.Markup.XamlReader]::Load( $reader )

#ReportingPatches Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Report Patches">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Reporting Patches. </Bold>
            </Paragraph>
           <Paragraph FontSize = "14">
                Before you can begin Rebooting Servers, make sure that the Radio Button is checked for <Bold> Reboot Servers </Bold>.
            </Paragraph>             
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$ReportPatches=[Windows.Markup.XamlReader]::Load( $reader )

#RebootServers Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Reboot Servers">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> Rebooting Servers. </Bold>
            </Paragraph>
           <Paragraph FontSize = "14">
                Before you can begin Rebooting Servers, make sure that the Radio Button is checked for <Bold> Reboot Servers </Bold>.
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\RebootRadioChecked.JPG' Width = '291' />
            </Paragraph>
            <Paragraph FontSize = "15">
                <Bold> Reboot All Servers </Bold>
            </Paragraph>
            <Paragraph FontSize = "14">
            Once the radio button is checked for rebooting servers, click the Run button and all of the servers in the server list will
be rebooted. You can monitor which server is being rebooted by checking the progress and status bar. The utiliy does not monitor reboots 
so this will have to be done manally via another method.     
            </Paragraph>
            <Paragraph>
                <Image Source = '$pwd\HelpFiles\Images\RebootAllServers.JPG' />
            </Paragraph>            
            <Paragraph FontSize = "15">
                <Bold> Reboot a single server </Bold>
            </Paragraph>     
            <Paragraph FontSize = "14">
            To reboot a single server, just double click on the server and the utility will reboot the specified server.    
            </Paragraph>             
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$RebootServers=[Windows.Markup.XamlReader]::Load( $reader )

#Keyboard Shortcuts Help
[xml]$data = @"
<Page
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title = "Keyboard Shortcuts">    
    <FlowDocumentReader>
        <FlowDocument>
            <Paragraph FontSize = "18" TextAlignment="Center">   
                <Bold> List of Keyboard Shortcuts for PoshPAIG </Bold>
            </Paragraph>
            <List>
                <ListItem><Paragraph> <Bold>F1:</Bold> Display Help </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>F5:</Bold> Run the selected command. Ex. Audit Patches,Install Patches </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>F8:</Bold> Run a select report to generate </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>Ctrl+E:</Bold> Exits the PoshPAIG applicaton </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>Ctrl+A:</Bold> Select all systems in the Computer List </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>Ctrl+O:</Bold> Opens up the Options menu </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>Ctrl+S:</Bold> Opens window up to add more systems to Computer List </Paragraph></ListItem>
                <ListItem><Paragraph> <Bold>Ctrl+D:</Bold> Removes a selected System or Systems </Paragraph></ListItem>
            </List>
        </FlowDocument>
    </FlowDocumentReader>
</Page>
"@
$reader=(New-Object System.Xml.XmlNodeReader $data)
$KeyboardShortcuts=[Windows.Markup.XamlReader]::Load( $reader )


#Connect to all controls
$psexeclink = $Requirements.FindName("psexeclink")
$HelpTree = $HelpWindow.FindName("HelpTree")
$Frame = $HelpWindow.FindName("Frame")
$RequirementsView = $HelpWindow.FindName("RequirementsView")

##Events
#HelpTree event
$HelpTree.Add_SelectedItemChanged({
    Switch ($This.SelectedItem.Header) {
        "Requirements" {
            $Frame.Content = $Requirements        
            }
        "Server List" {
            $Frame.Content = $ServerList
            }
        "Audit Patches" {
            $Frame.Content = $AuditPatches
            }
        "Install Patches" {
            $Frame.Content = $InstallPatches
            }
        "Reporting" {
            $Frame.Content = $ReportPatches
            }
        "Rebooting Servers" {
            $Frame.Content = $RebootServers
            }  
        "Keyboard Shortcuts" {
            $Frame.Content = $KeyboardShortcuts
        }  
        Default {
            $Frame.Content = "Default"
            }
        }
    })
#PsexecLink Event
$psexeclink.Add_Click({
    Start-Process "http://technet.microsoft.com/en-us/sysinternals/bb896649"
    })

[void]$HelpWindow.showDialog()

}).BeginInvoke()
}