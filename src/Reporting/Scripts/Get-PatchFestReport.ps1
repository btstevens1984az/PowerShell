<#
    .SYNOPSIS
        Get-PatchFestServerReport - Creates detailed reports of one or more computer systems.
   
       	Brandon Stevens
    	
	
    .DESCRIPTION
        Creates detailed reports of one or more computer systems.

        The following information is reported upon:
            System Information
                Summary
                    OS
                    OS Architecture
                    OS Service Pack
                    OS SKU
                    OS Version
                    Server Chassis Type
                    Server Model
                    Serial Number
                    CPU Architecture
                    CPU Sockets
                    Total CPU Cores
                    Virtual
                    Virtual Type    
                    Total Physical RAM
                    Free Physical RAM
                    Total Virtual RAM
                    Free Virtual RAM
                    Total Memory Slots
                    Memory Slots Utilized
                    Uptime
                    Install Date
                    Last Boot
                    System Time
                Extended Summary 
                    Registered Owner
                    Registered Organization
                    System Root
                    Product Key
                    Product Key (64 bit)
                    NTP Type
                    NTP Servers
                Dell Warranty Information
                    Type
                    Model
                    Service Tag
                    Ship Date
                    Start Date
                    End Date
                    Days Left
                    Service Level
                Disk Report
                    Drive
                    Type
                    Disk
                    Model
                    Partition
                    Size
                    Free Space
                    Disk Usage (graph)
                Environmental Variables
                    Name
                    Value
                    System Variable
                    User Name
                Memory Banks
                    Bank
                    Label
                    Capacity
                    Speed
                    Detail
                    Form Factor
                Scheduled Tasks
                    Name
                    Author
                    Description
                    Last Run
                    Next Run
                    Last Results
                Startup Commands
                    Command
                    User
                    Caption
                Top Processes by Memory
                    Name
                    ID
                    Memory Usage
                Automatic Services which are Stopped
                    Service Name
                    State
                    Start Mode
                Services starting with non-standard credentials
                    Service Name
                    State
                    Start Mode
                    Start As
            Event Log Information
                Event Logs
                    Log Name
                    Status
                    OverWrite
                    Entries
                    Max File Size
                Event Log Entries
                    Log
                    Type
                    Source
                    Event
                    Message
                    Time
            Networking Information
                Network Adapters
                    Network Name
                    Index
                    Address
                    Subnet
                    MAC
                    Gateway
                    DHCP
                    Status
                    Promiscuous
                Local Hosts File
                    IP
                    Host Entry
                Local DNS Cache
                    Name
                    Value
                    Type
                Route Table
                    Destination
                    Mask
                    Next Hop
                    Persistent
                    Metric
                    Interface Index
                    Type
            Software Audit
                Installed Windows Updates
                    Hotfix ID
                    Description
                    Installed By
                    Installed On
                    Link
                Installed Applications
                    Display Name
                    Version
                    Publisher
                31.39.1.252 Settings
                    (All 31.39.1.252 registry entries)
            File/Print
                Shares
                    Name
                    Status
                    Type
                    Allow Maximum
                Share session information
                    Share Name
                    Sessions
                Printers
                    Name
                    Status
                    Shared
                    Share Name
                    Published
                    Port Name
                    Current Jobs
                    Jobs Printed
                    Pages Printed
                    Job Errors
                Shadow Volumes
                    Drive
                    Drive Capacity
                    Shadow Copy Maximum Size
                    Shadow Space Used
                    Shadow Percent Used
                    Drive Percent Used
                VSS Writers
                    Name
                    State
                    Last Error
            Local Security
                Firewall Settings
                    All Zones, their status, and their log path
                Firewall Rules
                    Profile
                    Name
                    Direction
                    Action
                Local Group Membership 
                    Group Name
                    Member
                    Type
                Applied GPOs
                    Name
                    Enabled
                    Source OU
                    Link Order
                    Applied Order
                    No Override
            HP Hardware Health
                HP General Hardware Health
                    Manufacturer
                    Status
                HP Ethernet Team Health
                    Name
                    Description
                    Status
                HP Ethernet Health
                    Name
                    Port Type
                    Port Number
                    Status
                HP Array Controller Health
                    Name
                    Array Status
                    Battery Status
                    Controller Status
                HP Fan Health
                    Name
                    Removal Conditions
                    Status
                HP HBA Health
                    Name
                    Manufacturer
                    Model
                    Status
                HP PSU Health
                    Name
                    Type
                    Status
                HP Temp Sensor Status
                    Description
                    Percent To Critical
            Dell Hardware Health
                Dell Overall Hardware Health
                    Model
                    Overall Status
                    Esm Log Status
                    Fan Status
                    Memory Status
                    CPU Status
                    Temperature Status
                    Volt Status
                Dell Fan Health
                    Name
                    Status
                Dell Sensor Health
                    Name
                    Status
                    Description
                    Reading
                Dell Temp Sensor Health
                    Name
                    Reading
                    Threshold
                    Percent To Critical
                Dell ESM Logs
                    Record
                    Status
                    Time
                    Log
	.PARAMETER ReportFormat
        One of three report formats to use; HTML, Excel, and Custom. The first two are precanned options, 
        the last requires custom code further on in the script.
    
        HTML - This is the default option. Saves the report locally.
        Excel - This can be used to spit out all the report elements to excel, each section in its own 
                workbook.
        Custom - You will need to supply your own mix of parameters later in the code to use this.
	
	.PARAMETER PromptForInput
    	By default global variables are used (which can be found shortly after the parameters section). 
        If PromptForInput is set then the report variables will be prompted for at the console.
    
	.EXAMPLE
        Generate the HTML report using the predefined global variables and preselected html reports. 
        
        .\Get-PatchFestServerReport.ps1 -Verbose
    	
    .EXAMPLE
        Generate the Excel report, prompt for report variables. Be verbose.
        
        .\Get-PatchFestServerReport.ps1 -PromptForInput -ReportFormat 'Excel' -Verbose
        
    .EXAMPLE
        Generate the HTML reports, use AD selection dialog box for systems to scan. Prompt for 
        alternate credentials. Be verbose.
        
        .\Get-PatchFestServerReport.ps1 -ADDialog -PromptForCredentials -Verbose

    .EXAMPLE
        Generate the HTML reports against Server1 and Server2. Prompt for 
        alternate credentials. Be verbose.
        
        $Servers = @('Server1','Server2')
        .\Get-PatchFestServerReport.ps1 -Computers $Servers -PromptForCredentials -Verbose

    .EXAMPLE
        # Generate HTML reports on remote servers using alternate credentials 
        $Servers = @('BTS','99.117.107.147') 
        $cred = get-credential 
        ./Get-PatchFestServerReport.ps1 -Computers $Servers -Credential $cred -ReportFormat Excel -ReportType FullDocumentation -PromptForInput

            1.0 username Created PowerShell Function
             
#>
Function Get-PatchFestServerReport {
[CmdletBinding()] 
param ( 
    [Parameter(HelpMessage='Format of report(s) to generate.')]
    [ValidateSet('HTML','Excel','Custom')]
    [string]
    $ReportFormat='HTML',
    
    [Parameter(HelpMessage='Type of report to generate.')]
    [ValidateSet('FullDocumentation','Troubleshooting')]
    [string]
    $ReportType='FullDocumentation',
    
    [Parameter(HelpMessage='Use AD dialog box for selecting systems to run report against (overwrites Computers parameter if present).')]
    [switch]
    $ADDialog,
    
    [Parameter(HelpMessage='Prompt for report variables.')]
    [switch]
    $PromptForInput,
    
    [Parameter(HelpMessage='Prompt for alternate credentials.')]
    [switch]
    $PromptForCredentials,
    
    [Parameter(HelpMessage='Alternate credentials.')]
    [Alias("RunAs")]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty,
    
    [Parameter(HelpMessage='Save the data gathered for later report generation.')]
    [switch]
    $SaveData,
    
    [Parameter(HelpMessage='Load previously saved data and generate reports.')]
    [switch]
    $LoadData,
    
    [Parameter(HelpMessage='Data file used when saving or loading data.')]
    [String]
    $DataFile='SaveData.xml',
    
    [Parameter(HelpMessage='Systems to run report against')]
    [string[]]
    $Computers = $env:COMPUTERNAME
)

#region System Report General Options
$Option_EventLogPeriod = 24                 # in hours
$Option_EventLogResults = 5                 # Number of event logs per log type returned
$Option_TotalProcessesByMemory = 5          # Number of top memory using processes to return
$Option_TotalProcessesByMemoryWarn = 100    # Warning highlight on processes over MB amount
$Option_TotalProcessesByMemoryAlert = 300   # Alert highlight on processes over MB amount
$Option_DriveUsageWarningThreshold = 80     # Warning at this percentage of drive space used
$Option_DriveUsageAlertThreshold = 90       # Alert at this percentage of drive space used
$Option_DriveUsageWarningColor = 'Orange'
$Option_DriveUsageAlertColor = 'Red'
$Option_DriveUsageColor = 'Green'
$Option_DriveFreeSpaceColor = 'Transparent'

# Used if calling script from command line
$Verbosity = ($PSBoundParameters['Verbose'] -eq $true)

# Used for splatting and if prompt for input is used
$PromptForCreds = $PromptForCredentials

If ($PromptForInput)
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)

    $result = $Host.UI.PromptForChoice("Verbose?","Do you want verbose output?",$choices,0)
    $Verbosity = ($result -ne $true)
    
    $result = $Host.UI.PromptForChoice("Credential Prompt?","Alternate Credentials being used?",$choices,0)
    $PromptForCreds = ($result -ne $true)
}

# Try to keep this as an even number for the best results. The larger you make this
# number the less flexible your columns will be in html reports.
$DiskGraphSize = 26
#endregion System Report General Options

#region Global Options
# Change this to allow for more or less result properties to span horizontally
#  anything equal to or above this threshold will get displayed vertically instead.
#  (NOTE: This only applies to sections set to be dynamic in html reports)
$HorizontalThreshold = 10
#endregion Global Options

#region System Report Section Postprocessing Definitions
# If you are going to do some post-processing love then be cognizent of the following:
#  - The only variable which goes through post-processing is the section table as html.
#    This variable is aptly called $Table and will contain a string with a full html table.
#  - When you are done doing whatever processing you are aiming to do please return the fully formated 
#    html.
#  - I don't know whether to be proud or ashamed of this code. I think probably ashamed....
#  - These are assigned later on in the report structure as hash key entries 'PostProcessing'
# For this example I've performed two colorize table checks on the memory utilization.
$ProcessesByMemory_Postprocessing = 
@'
    [scriptblock]$scriptblock = {[float]$($args[0]|ConvertTo-MB) -gt [int]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'Memory Usage (WS)' -ColumnValue $Option_TotalProcessesByMemoryWarn -Attr 'class' -AttrValue 'warn' -WholeRow
            Format-HTMLTable $temp -Scriptblock $scriptblock -Column 'Memory Usage (WS)' -ColumnValue $Option_TotalProcessesByMemoryAlert -Attr 'class' -AttrValue 'alert' -WholeRow
'@

$RouteTable_Postprocessing = 
@'
    $temp = Format-HTMLTable $Table -Column 'Persistent' -ColumnValue 'True' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp -Column 'Type' -ColumnValue 'Invalid' -Attr 'class' -AttrValue 'alert'
            Format-HTMLTable $temp -Column 'Persistent' -ColumnValue 'False' -Attr 'class' -AttrValue 'alert'
'@

$EventLogs_Postprocessing =
@'
    $temp = Format-HTMLTable $Table -Column 'Type' -ColumnValue 'Warning' -Attr 'class' -AttrValue 'warn' -WholeRow
    $temp = Format-HTMLTable $temp  -Column 'Type' -ColumnValue 'Error' -Attr 'class' -AttrValue 'alert' -WholeRow
            Format-HTMLTable $temp -Column 'Log' -ColumnValue 'Security' -Attr 'class' -AttrValue 'security' -WholeRow
'@

$HPServerHealth_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
            Format-HTMLTable $temp -Scriptblock $scriptblock -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'    
'@

$HPServerHealthArrayController_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table  -Scriptblock $scriptblock -Column 'Battery Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'    
    $temp = Format-HTMLTable $temp -Column 'Battery Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Controller Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'    
    $temp = Format-HTMLTable $temp -Column 'Controller Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Array Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'    
            Format-HTMLTable $temp -Column 'Array Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
'@

$DellServerHealth_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'Overall Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'    
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'ESM Log Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Fan Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Memory Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'CPU Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Temperature Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp  -Scriptblock $scriptblock -Column 'Volt Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp                            -Column 'Overall Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp                            -Column 'Esm Log Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp                            -Column 'Fan Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp                            -Column 'Memory Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp                            -Column 'CPU Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp                            -Column 'Temperature Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
            Format-HTMLTable $temp                            -Column 'Volt Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
'@

$DellESMLog_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert' -WholeRow
            Format-HTMLTable $temp                           -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
'@

$DellSensor_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'alert'
            Format-HTMLTable $temp                            -Column 'Status' -ColumnValue 'OK' -Attr 'class' -AttrValue 'healthy'
'@

$Printer_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -ne [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock  -Column 'Status' -ColumnValue 'Idle' -Attr 'class' -AttrValue 'warn'
    $temp = Format-HTMLTable $temp -Scriptblock $scriptblock  -Column 'Job Errors' -ColumnValue '0' -Attr 'class' -AttrValue 'warn'
    $temp = Format-HTMLTable $temp -Column 'Status' -ColumnValue 'Idle' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp -Column 'Shared' -ColumnValue 'True' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp -Column 'Shared' -ColumnValue 'False' -Attr 'class' -AttrValue 'alert'
    $temp = Format-HTMLTable $temp -Column 'Published' -ColumnValue 'True' -Attr 'class' -AttrValue 'healthy'
            Format-HTMLTable $temp -Column 'Published' -ColumnValue 'False' -Attr 'class' -AttrValue 'alert'
'@

$VSSWriter_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -notmatch [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'State' -ColumnValue 'Stable' -Attr 'class' -AttrValue 'warn'
    $temp = Format-HTMLTable $temp -Scriptblock $scriptblock -Column 'Last Error' -ColumnValue 'No error' -Attr 'class' -AttrValue 'warn'
    [scriptblock]$scriptblock = {[string]$args[0] -match [string]$args[1]}
    $temp = Format-HTMLTable $temp -Scriptblock $scriptblock -Column 'State' -ColumnValue 'Stable' -Attr 'class' -AttrValue 'healthy'
            Format-HTMLTable $temp -Scriptblock $scriptblock -Column 'Last Error' -ColumnValue 'No error' -Attr 'class' -AttrValue 'healthy'
'@

$NetworkAdapter_Postprocessing =
@'
    [scriptblock]$scriptblock = {[string]$args[0] -notmatch [string]$args[1]}
    $temp = Format-HTMLTable $Table -Scriptblock $scriptblock -Column 'Status' -ColumnValue 'Connected' -Attr 'class' -AttrValue 'warn'
    $temp = Format-HTMLTable $temp -Column 'Status' -ColumnValue 'Connected' -Attr 'class' -AttrValue 'healthy'
    $temp = Format-HTMLTable $temp -Column 'DHCP' -ColumnValue 'True' -Attr 'class' -AttrValue 'warn'
    $temp = Format-HTMLTable $temp -Column 'Promiscuous' -ColumnValue 'True' -Attr 'class' -AttrValue 'warn'
            Format-HTMLTable $temp -Column 'Promiscuous' -ColumnValue 'False' -Attr 'class' -AttrValue 'healthy'
'@

$ComputerReportPreProcessing =
@'
    Get-RemoteSystemInformation @credsplat @VerboseDebug `
               -ComputerName $AssetNames `
               -ReportContainer $ReportContainer `
               -SortedRpts $SortedReports
'@
#endregion Report Section Postprocessing Definitions

#region System Report Structure
<#
 This hash deserves some explanation.
 
 CONFIGURATION:
 Overall report configuration variables.
  TOC - ($true/$false)
    For future use.
  Preprocessing - ([string])
    The code to invoke for gathering the data for each section of the report.
  SkipSectionBreaks - ($true/$false)
    Skip over any section type of 'SectionBreak'
  ReportTypes - ([string[]])
    here will be the default used if none are specified
    
 SECTION:
 For each section there are several subkeys:
  Enabled - ($true/$false)
    Determines if the section is enabled. Use this to disable/enable a section
    for ALL report types.
  ShowSectionEvenWithNoData - ($true/$false)
    Determines if the section will still process when there is no data. Use this 
    to force report layouts into a specific patterns if data is variable.
    
  Order - ([int])
    Hash tables in powershell v2 have no easy way to maintain a specific order. This is used to 
    workaround that limitation is a hackish way. You can have duplicates but then section order
    will become unpredictable.
    
  AllData - ([hashtable])
    This holds a hashtable with all data which is being reported upon. You will load this up
    in Get-RemoteSystemInformation. It is up to you to fill the data appropriately if a new type
    of report is being templated out for your poject. AllData expects a hash of names with their
    value being an array of values.
    
  Title - ([string])
    The section title for the top of the table. This spans across all columns and looks nice.
  
  Type - ([string])
    The section type. Currently only Section and SectionBreak are supported.
    
  Comment - ([string])
    A comment for the section which appears below the table title but above the data in a standard section.

  PostProcessing - ([string])
    Used to colorize table elements before putting them into an html report
    
  ReportTypes - [hashtable]
    This is the meat and potatoes of each section. For each report type you have defined there will 
    generally be several properties which are selected directly from the AllData hashes which
    make up your report. Several advanced report type definitions have been included for the
    system report as examples. Generally each section contains the same report types as top
    level hash keys. There are some special keys which can be defined with each report type
    that allow you to manually manipulate how reports are generated per section. These are:
    
      SectionOverride - ($true/$false)
        of the prior section group. This is an advanced layout option. This is almost always
        going to be $false.
        
      ContainerType - (See below)
        Use ths to force a particular report element to use a specific section container. This 
        affects how the element gets laid out on the page. So far the following values have
        been defined.
           Half    - The report section consumes half of the row. Even report sections end up on 
                     the left side, odd report sections end up on the right side.
           Full    - The report section consumes the entire width of the row.
           Third   - The report section consumes approximately a third of the row.
           TwoThirds - The report section consumes approximately 2/3rds of the row.
           Fourth  - The section consumes a fourth of the row.
           ThreeFourths - Ths section condumes 3/4ths of the row.
           
        You can end up with some wonky looking reports if you don't plan the sections appropriately
        to match your sectional data. So a section with 20 properties and a horizontal layout will
        look like crap taking up only a 4th of the page.
        
      TableType - (See below) 
        Use this to force a particular report element to use a specific table layout. Thus far
        the following vales have been defined.
           Vertical   - Data headers are the first row of the table
           Horizontal - Data headers are the first column of the table
           Dynamic    - If the number of data properties equals or surpasses the HorizontalThreshold 
                        the table is presented vertically. Otherwise it displays horizontally
#>
$SystemReport = @{
    'Configuration' = @{
        'TOC'               = $true #Possibly used in the future to create a table of contents
        'PreProcessing'     = $ComputerReportPreProcessing
        'SkipSectionBreaks' = $false
        'ReportTypes'       = @('Troubleshooting','FullDocumentation')
        'Assets'            = @()
        'PostProcessingEnabled' = $true
    }
    'Sections' = @{
        'Break_Summary' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 0
            'AllData' = @{}
            'Title' = 'System Information'
            'Type' = 'SectionBreak'
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'Summary' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 1
            'AllData' = @{}
            'Title' = 'System Summary'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Vertical'
                    'Properties' = @(
                        @{n='Uptime';e={$_.Uptime}},
                        @{n='OS';e={$_.OperatingSystem}},
                        @{n='Total Physical RAM';e={$_.PhysicalMemoryTotal}},
                        @{n='Free Physical RAM';e={$_.PhysicalMemoryFree}},
                        @{n='Total RAM Utilization';e={"$($_.PercentPhysicalMemoryUsed)%"}}
                    )
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Vertical'
                    'Properties' = @(
                        @{n='OS';e={$_.OperatingSystem}},
                        @{n='OS Architecture';e={$_.OSArchitecture}},
                        @{n='OS Service Pack';e={$_.OSServicePack}},
                        @{n='OS SKU';e={$_.OSSKU}},
                        @{n='OS Version';e={$_.OSVersion}},
                        @{n='Server Chassis Type';e={$_.ChassisModel}},
                        @{n='Server Model';e={$_.Model}},
                        @{n='Serial Number';e={$_.SerialNumber}},
                        @{n='CPU Architecture';e={$_.SystemArchitecture}},
                        @{n='CPU Sockets';e={$_.CPUSockets}},
                        @{n='Total CPU Cores';e={$_.CPUCores}},
                        @{n='Virtual';e={$_.IsVirtual}},
                        @{n='Virtual Type';e={$_.VirtualType}},
                        @{n='Total Physical RAM';e={$_.PhysicalMemoryTotal}},
                        @{n='Free Physical RAM';e={$_.PhysicalMemoryFree}},
                        @{n='Total Virtual RAM';e={$_.VirtualMemoryTotal}},
                        @{n='Free Virtual RAM';e={$_.VirtualMemoryFree}},
                        @{n='Total Memory Slots';e={$_.MemorySlotsTotal}},
                        @{n='Memory Slots Utilized';e={$_.MemorySlotsUsed}},
                        @{n='Uptime';e={$_.Uptime}},
                        @{n='Install Date';e={$_.InstallDate}},
                        @{n='Last Boot';e={$_.LastBootTime}},
                        @{n='System Time';e={$_.SystemTime}}
                    )
                }
            }
        }
        'ExtendedSummary' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 2
            'AllData' = @{}
            'Title' = 'Extended Summary'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $true
                    'TableType' = 'Vertical'
                    'Properties' =
                        @{n='Registered Owner';e={$_.RegisteredOwner}},
                        @{n='Registered Organization';e={$_.RegisteredOrganization}},
                        @{n='System Root';e={$_.SystemRoot}},
                        @{n='Product Key';e={ConvertTo-ProductKey $_.DigitalProductId}},
                        @{n='Product Key (64 bit)';e={ConvertTo-ProductKey $_.DigitalProductId4 -x64}},
                        @{n='NTP Type';e={$_.NTPType}},
                        @{n='NTP Servers';e={$_.NTPServers}}
                }
            }
        }
        'DellWarrantyInformation' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 3
            'AllData' = @{}
            'Title' = 'Dell Warranty Information'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Vertical'
                    'Properties' =                    
                        @{n='Type';e={$_.Type}},
                        @{n='Model';e={$_.Model}},                    
                        @{n='Service Tag';e={$_.ServiceTag}},
                        @{n='Ship Date';e={$_.ShipDate}},
                        @{n='Start Date';e={$_.StartDate}},
                        @{n='End Date';e={$_.EndDate}},
                        @{n='Days Left';e={$_.DaysLeft}},
                        @{n='Service Level';e={$_.ServiceLevel}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $true
                    'TableType' = 'Vertical'
                    'Properties' =                    
                        @{n='Type';e={$_.Type}},
                        @{n='Model';e={$_.Model}},                    
                        @{n='Service Tag';e={$_.ServiceTag}},
                        @{n='Ship Date';e={$_.ShipDate}},
                        @{n='Start Date';e={$_.StartDate}},
                        @{n='End Date';e={$_.EndDate}},
                        @{n='Days Left';e={$_.DaysLeft}},
                        @{n='Service Level';e={$_.ServiceLevel}}
                }
            }
        }
        'EnvironmentVariables' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 5
            'AllData' = @{}
            'Title' = 'Environmental Variables'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Value';e={$_.VariableValue}},
                        @{n='System Variable';e={$_.SystemVariable}},
                        @{n='User Name';e={$_.UserName}}
                }
            }
        }
        'StartupCommands' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 6
            'AllData' = @{}
            'Title' = 'Startup Commands'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Command';e={$_.Command}},
                        @{n='User';e={$_.User}},
                        @{n='Caption';e={$_.Caption}}
                }
            }
        }
        'ScheduledTasks' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 6
            'AllData' = @{}
            'Title' = 'Scheduled Tasks'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Author';e={$_.Author}},
                        @{n='Description';e={$_.Description}},
                        @{n='Last Run';e={$_.LastRunTime}},
                        @{n='Next Run';e={$_.NextRunTime}},
                        @{n='Last Results';e={$_.LastTaskDetails}}
                }
            }
        }
        'Disk' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 4
            'AllData' = @{}
            'Title' = 'Disk Report'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Drive';e={$_.Drive}},
                        @{n='Type';e={$_.DiskType}},
                        @{n='Size';e={$_.DiskSize}},
                        @{n='Free Space';e={$_.FreeSpace}},
                        @{n='Disk Usage';
                          e={$color = $Option_DriveUsageColor
                            if ((100 - $_.PercentageFree) -ge $Option_DriveUsageWarningThreshold)
                            {
                                if ((100 - $_.PercentageFree) -ge $Option_DriveUsageAlertThreshold)
                                {
                                    $color = $Option_DriveUsageAlertColor
                                }
                                else
                                {
                                    $color = $Option_DriveUsageWarningColor
                                }
                            }
                            New-HTMLBarGraph -GraphSize $DiskGraphSize -PercentageUsed (100 - $_.PercentageFree) `
                                             -LeftColor $color -RightColor $Option_DriveFreeSpaceColor
                            }}
                }    
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Drive';e={$_.Drive}},
                        @{n='Type';e={$_.DiskType}},
                        @{n='Disk';e={$_.Disk}},
                        #@{n='Serial Number';e={$_.SerialNumber}},
                        @{n='Model';e={$_.Model}},
                        @{n='Partition ';e={$_.Partition}},
                        @{n='Size';e={$_.DiskSize}},
                        @{n='Free Space';e={$_.FreeSpace}},
                        @{n='Disk Usage';
                          e={$color = $Option_DriveUsageColor
                            if ((100 - $_.PercentageFree) -ge $Option_DriveUsageWarningThreshold)
                            {
                                if ((100 - $_.PercentageFree) -ge $Option_DriveUsageAlertThreshold)
                                {
                                    $color = $Option_DriveUsageAlertColor
                                }
                                else
                                {
                                    $color = $Option_DriveUsageWarningColor
                                }
                            }
                            New-HTMLBarGraph -GraphSize $DiskGraphSize -PercentageUsed (100 - $_.PercentageFree) `
                                             -LeftColor $color -RightColor $Option_DriveFreeSpaceColor
                            }}
                }
            }
        }
        'Memory' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 5
            'AllData' = @{}
            'Title' = 'Memory Banks'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Bank';e={$_.Bank}},
                        @{n='Label';e={$_.Label}},
                        @{n='Capacity';e={$_.Capacity}},
                        @{n='Speed';e={$_.Speed}},
                        @{n='Detail';e={$_.Detail}},
                        @{n='Form Factor';e={$_.FormFactor}}
                }
            }
        }
        'ProcessesByMemory' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 6
            'AllData' = @{}
            'Title' = 'Top Processes by Memory'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='ID';e={$_.ProcessID}},
                        @{n='Memory Usage (WS)';e={$_.WS | ConvertTo-KMG}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='ID';e={$_.ProcessID}},
                        @{n='Memory Usage (WS)';e={$_.WS | ConvertTo-KMG}}
                }
            }
            'PostProcessing' = $ProcessesByMemory_Postprocessing
        }
        'StoppedServices' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 7
            'AllData' = @{}
            'Title' = 'Stopped Services'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Service Name';e={$_.Name}},
                        @{n='State';e={$_.State}},
                        @{n='Start Mode';e={$_.StartMode}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Service Name';e={$_.Name}},
                        @{n='State';e={$_.State}},
                        @{n='Start Mode';e={$_.StartMode}}
                }
            }
        }
        'NonStandardServices' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 8
            'AllData' = @{}
            'Title' = 'NonStandard Service Accounts'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Service Name';e={$_.Name}},
                        @{n='State';e={$_.State}},
                        @{n='Start Mode';e={$_.StartMode}},
                        @{n='Start As';e={$_.StartName}}
                }
            }
        }
        'Break_EventLogs' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 10
            'AllData' = @{}
            'Title' = 'Event Log Information'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'EventLogSettings' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 11
            'AllData' = @{}
            'Title' = 'Event Logs'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Log Name';e={$_.LogfileName}},
                        @{n='Status';e={$_.Status}},
                        @{n='OverWrite';e={$_.OverWritePolicy}},
                        @{n='Entries';e={$_.NumberOfRecords}},
                        #@{n='Archive';e={$_.Archive}},
                        #@{n='Compressed';e={$_.Compressed}},
                        @{n='Max File Size';e={$_.MaxFileSize}}
                }
            }
        }
        'EventLogs' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 12
            'AllData' = @{}
            'Title' = 'Event Log Entries'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Log';e={$_.LogFile}},
                        @{n='Type';e={$_.Type}},
                        @{n='Source';e={$_.SourceName}},
                        @{n='Event';e={$_.EventCode}},
                        @{n='Message';e={$_.Message}},
                        @{n='Time';e={([wmi]'').ConvertToDateTime($_.TimeGenerated)}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Log';e={$_.LogFile}},
                        @{n='Type';e={$_.Type}},
                        @{n='Source';e={$_.SourceName}},
                        @{n='Event';e={$_.EventCode}},
                        @{n='Message';e={$_.Message}},
                        @{n='Time';e={([wmi]'').ConvertToDateTime($_.TimeGenerated)}}
                }
            }
            'PostProcessing' = $EventLogs_Postprocessing
        }
        'Break_Network' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 20
            'AllData' = @{}
            'Title' = 'Networking Information'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'Network' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 21
            'AllData' = @{}
            'Title' = 'Network Adapters'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Network Name';e={$_.NetworkName}},
                       # @{n='Adapter Name';e={$_.AdapterName}},
                        @{n='Index';e={$_.Index}},
                        @{n='Address';e={$_.IpAddress -join ', '}},
                        @{n='Subnet';e={$_.IpSubnet -join ', '}},
                        @{n='MAC';e={$_.MACAddress}},
                        @{n='Gateway';e={$_.DefaultIPGateway}},
                       # @{n='Description';e={$_.Description}},
                       # @{n='Interface Index';e={$_.InterfaceIndex}},
                        @{n='DHCP';e={$_.DHCPEnabled}},
                        @{n='Status';e={$_.ConnectionStatus}},
                        @{n='Promiscuous';e={$_.PromiscuousMode}}
                }         
            }
            'PostProcessing' = $NetworkAdapter_Postprocessing

        }
        'RouteTable' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 23
            'AllData' = @{}
            'Title' = 'Route Table'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Destination';e={$_.Destination}},
                        @{n='Mask';e={$_.Mask}},
                        @{n='Next Hop';e={$_.NextHop}},
                        @{n='Persistent';e={$_.Persistent}},
                        @{n='Metric';e={$_.Metric}},
                        @{n='Interface Index';e={$_.InterfaceIndex}},
                        @{n='Type';e={$_.Type}}
                }         
            }
            'PostProcessing' = $RouteTable_Postprocessing
        }
        'HostsFile' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 22
            'AllData' = @{}
            'Title' = 'Local Hosts File'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='IP';e={$_.IP}},
                        @{n='Host Entry';e={$_.HostEntry}}
                }         
            }
            'PostProcessing' = $false
        }
        'DNSCache' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $False
            'Order' = 23
            'AllData' = @{}
            'Title' = 'Local DNS Cache'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Value';e={$_.Value}},
                        @{n='Type';e={$_.Type}}
                }         
            }
            'PostProcessing' = $false
        }
        'Break_SoftwareAudit' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 30
            'AllData' = @{}
            'Title' = 'Software Audit'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'InstalledUpdates' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 31
            'AllData' = @{}
            'Title' = 'Installed Windows Updates'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'ThreeFourths'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Hotfix ID';e={$_.HotFixID}},
                        @{n='Description';e={$_.Description}},
                        @{n='Installed By';e={$_.InstalledBy}},
                        @{n='Installed On';e={$_.InstalledOn}},
                        @{n='Link';e={'<a href="'+ $_.Caption + '">' + $_.Caption + '</a>'}}
                }
            }
        } 
        'Applications' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 32
            'AllData' = @{}
            'Title' = 'Installed Applications'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'ThreeFourths'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Display Name';e={$_.DisplayName}},
                        @{n='Version';e={$_.Version}},
                        @{n='Publisher';e={$_.Publisher}}
                }
            }
        }
        'WSUSSettings' = @{
            'Enabled' = $false
            'ShowSectionEvenWithNoData' = $false
            'Order' = 33
            'AllData' = @{}
            'Title' = '31.39.1.252 Settings'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $true
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='31.39.1.252 Setting';e={$_.Key}},
                        @{n='Value';e={$_.KeyValue}}
                }
            }
        }
        'Break_FilePrint' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 40
            'AllData' = @{}
            'Title' = 'File Print'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'Shares' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 41
            'AllData' = @{}
            'Title' = 'Shares'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Share Name';e={$_.Name}},
                        @{n='Status';e={$_.Status}},
                        @{n='Type';e={$ShareType[[string]$_.Type]}},
                        @{n='Allow Maximum';e={$_.AllowMaximum}}
                        #@{n='Maximum Allowed';e={$_.MaximumAllowed}}
                }
            }
        }    
        'ShareSessionInfo' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 42
            'AllData' = @{}
            'Title' = 'Share Sessions'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Share Name';e={$_.Name}},
                        @{n='Sessions';e={$_.Count}}
                }
            }
        }
        'Printers' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 43
            'AllData' = @{}
            'Title' = 'Printers'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Status';e={$_.Status}},
          #              @{n='Location';e={$_.Location}},
                        @{n='Shared';e={$_.Shared}},
                        @{n='Share Name';e={$_.ShareName}},
                        @{n='Published';e={$_.Published}},
          #              @{n='Local';e={$_.Local}},
          #              @{n='Network';e={$_.Network}},
          #              @{n='Keep Printed Jobs';e={$_.KeepPrintedJobs}},
          #              @{n='Driver Name';e={$_.DriverName}},
                        @{n='Port Name';e={$_.PortName}},
          #              @{n='Default';e={$_.Default}},
                        @{n='Current Jobs';e={$_.CurrentJobs}},
                        @{n='Jobs Printed';e={$_.TotalJobsPrinted}},
                        @{n='Pages Printed';e={$_.TotalPagesPrinted}},
                        @{n='Job Errors';e={$_.JobErrors}}
                }
            }
            'PostProcessing' = $Printer_Postprocessing
        } 
        'VSSWriters' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 45
            'AllData' = @{}
            'Title' = 'VSS Writers'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.WriterName}},
                        @{n='State';e={$_.State}},
                        @{n='Last Error';e={$_.LastError}}
                }
            }
            'PostProcessing' = $VSSWriter_Postprocessing
        } 
        'ShadowVolumes' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 44
            'AllData' = @{}
            'Title' = 'Shadow Volumes'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Drive';e={$_.Drive}},
                        @{n='Drive Capacity';e={$_.DriveCapacity}},
                        @{n='Shadow Copy Maximum Size';e={$_.ShadowSizeMax}},
                        @{n='Shadow Space Used';e={$_.ShadowSizeUsed}},
                        @{n='Shadow Percent Used ';e={$_.ShadowCapacityUsed}},
                        @{n='Drive Percent Used';e={$_.VolumeCapacityUsed}}
                }
            }
            'PostProcessing' = $false
        } 
        'Break_LocalSecurity' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $true
            'Order' = 50
            'AllData' = @{}
            'Title' = 'Local Security'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'LocalGroupMembership' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 51
            'AllData' = @{}
            'Title' = 'Local Group Membership'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Group Name';e={$_.Group}},
                        @{n='Member';e={$_.GroupMember}},
                        @{n='Member Type';e={$_.MemberType}}
                }
            }
        }
        'AppliedGPOs' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 52
            'AllData' = @{}
            'Title' = 'Applied Group Policies'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Enabled';e={$_.Enabled}},
                        @{n='Source OU';e={$_.SourceOU}},
                        @{n='Link Order';e={$_.linkOrder}},
                        @{n='Applied Order';e={$_.appliedOrder}},
                        @{n='No Override';e={$_.noOverride}}
                }
            }
        }
        'FirewallSettings' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 53
            'AllData' = @{}
            'Title' = 'Firewall Settings'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Vertical'
                    'Properties' =
                       # @{n='Firewall Enabled';e={$_.FirewallEnabled}},
                        @{n='Domain Enabled';e={$_.DomainZoneEnabled}},
                        @{n='Domain Log Path';e={$_.DomainZoneLogPath}},
                        @{n='Domain Log Size';e={$_.DomainZoneLogSize}},
                        @{n='Public Enabled';e={$_.PublicZoneEnabled}},
                        @{n='Public Log Path';e={$_.PublicZoneLogPath}},
                        @{n='Public Log Size';e={$_.PublicZoneLogSize}},
                        @{n='Default Enabled';e={$_.PublicZoneEnabled}},
                        @{n='Default Log Path';e={$_.PublicZoneLogPath}},
                        @{n='Default Log Size';e={$_.PublicZoneLogSize}}
                }
            }
        }
        'FirewallRules' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 54
            'AllData' = @{}
            'Title' = 'Firewall Rules'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Profile';e={$_.Profile}},
                        @{n='Name';e={$_.Name}},
                        @{n='Direction';e={$_.Dir}},
                        @{n='Action';e={$_.Action}}
                       # @{n='Rule Type';e={$_.RuleType}}
                }
            }
        }
        'Break_HardwareHealth' = @{
            'Enabled' = $false
            'ShowSectionEvenWithNoData' = $true
            'Order' = 80
            'AllData' = @{}
            'Title' = 'Hardware Health'
            'Type' = 'SectionBreak'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' = $true
                }
            }
        }
        'HP_GeneralHardwareHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 90
            'AllData' = @{}
            'Title' = 'HP Overall Hardware Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Manufacturer';e={$_.Manufacturer}},
                        @{n='Status';e={$_.HealthState}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Manufacturer';e={$_.Manufacturer}},
                        @{n='Status';e={$_.HealthState}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_EthernetTeamHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 91
            'AllData' = @{}
            'Title' = 'HP Ethernet Team Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Description';e={$_.Description}},
                        @{n='Status';e={$_.RedundancyStatus}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Description';e={$_.Description}},
                        @{n='Status';e={$_.RedundancyStatus}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_ArrayControllerHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 92
            'AllData' = @{}
            'Title' = 'HP Array Controller Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' =  @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.ArrayName}},
                        @{n='Array Status';e={$_.ArrayStatus}},
                        @{n='Battery Status';e={$_.BatteryStatus}},
                        @{n='Controller Status';e={$_.ControllerStatus}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.ArrayName}},
                        @{n='Array Status';e={$_.ArrayStatus}},
                        @{n='Battery Status';e={$_.BatteryStatus}},
                        @{n='Controller Status';e={$_.ControllerStatus}}
                }
            }
            'PostProcessing' = $HPServerHealthArrayController_Postprocessing
        }
        'HP_EthernetHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 93
            'AllData' = @{}
            'Title' = 'HP Ethernet Adapter Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Port Type';e={$_.PortType}},
                        @{n='Port Number';e={$_.PortNumber}},
                        @{n='Status';e={$_.HealthState}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Port Type';e={$_.PortType}},
                        @{n='Port Number';e={$_.PortNumber}},
                        @{n='Status';e={$_.HealthState}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_FanHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 94
            'AllData' = @{}
            'Title' = 'HP Fan Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Removal Conditions';e={$_.RemovalConditions}},
                        @{n='Status';e={$_.HealthState}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Removal Conditions';e={$_.RemovalConditions}},
                        @{n='Status';e={$_.HealthState}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_HBAHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 95
            'AllData' = @{}
            'Title' = 'HP HBA Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Manufacturer';e={$_.Manufacturer}},
                        @{n='Model';e={$_.Model}},
                        #@{n='Location';e={$_.OtherIdentifyingInfo}},
                        @{n='Status';e={$_.OperationalStatus}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Manufacturer';e={$_.Manufacturer}},
                        @{n='Model';e={$_.Model}},
                        #@{n='Location';e={$_.OtherIdentifyingInfo}},
                        @{n='Status';e={$_.OperationalStatus}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_PSUHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 96
            'AllData' = @{}
            'Title' = 'HP Power Supply Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Type';e={$_.Type}},
                        @{n='Status';e={$_.HealthState}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Type';e={$_.Type}},
                        @{n='Status';e={$_.HealthState}}
                }
            }
            'PostProcessing' = $HPServerHealth_Postprocessing
        }
        'HP_TempSensors' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 97
            'AllData' = @{}
            'Title' = 'HP Temperature Sensors'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Half'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Description';e={$_.Description}},
                        @{n='Percent To Critical';e={$_.PercentToCritical}}
                }
            }
        }
        'Dell_GeneralHardwareHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 100
            'AllData' = @{}
            'Title' = 'Dell Overall Hardware Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Model';e={$_.Model}},
                        @{n='Overall Status';e={$_.Status}},
                        @{n='Esm Log Status';e={$_.EsmLogStatus}},
                        @{n='Fan Status';e={$_.FanStatus}},
                        @{n='Memory Status';e={$_.MemStatus}},
                        @{n='CPU Status';e={$_.ProcStatus}},
                        @{n='Temperature Status';e={$_.TempStatus}},
                        @{n='Volt Status';e={$_.VoltStatus}}
                }
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Model';e={$_.Model}},
                        @{n='Overall Status';e={$_.Status}},
                        @{n='Esm Log Status';e={$_.EsmLogStatus}},
                        @{n='Fan Status';e={$_.FanStatus}},
                        @{n='Memory Status';e={$_.MemStatus}},
                        @{n='CPU Status';e={$_.ProcStatus}},
                        @{n='Temperature Status';e={$_.TempStatus}},
                        @{n='Volt Status';e={$_.VoltStatus}}
                }
            }
            'PostProcessing' = $DellServerHealth_Postprocessing
        }
        'Dell_FanHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 101
            'AllData' = @{}
            'Title' = 'Dell Fan Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Status';e={$_.Status}}
                }
            }
            'PostProcessing' = $DellSensor_Postprocessing
        }
        'Dell_SensorHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 102
            'AllData' = @{}
            'Title' = 'Dell Sensor Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Status';e={$_.Status}},
                        @{n='Description';e={$_.Description}},
                        @{n='Reading';e={$_.CurrentReading}}
                }
            }
            'PostProcessing' = $DellSensor_Postprocessing
        }
        'Dell_TempSensorHealth' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 103
            'AllData' = @{}
            'Title' = 'Dell Temperature Health'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Third'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Name';e={$_.Name}},
                        @{n='Reading';e={$_.CurrentReading}},
                        @{n='Threshold';e={$_.UpperThresholdCritical}},
                        @{n='Percent To Critical';e={$_.PercentToCritical}}
                }
            }
            'PostProcessing' = $False
        }
        'Dell_ESMLogs' = @{
            'Enabled' = $true
            'ShowSectionEvenWithNoData' = $false
            'Order' = 105
            'AllData' = @{}
            'Title' = 'Dell ESM Logs'
            'Type' = 'Section'
            'Comment' = $false
            'ReportTypes' = @{
                'Troubleshooting' = $false
                'FullDocumentation' = @{
                    'ContainerType' = 'Full'
                    'SectionOverride' = $false
                    'TableType' = 'Horizontal'
                    'Properties' =
                        @{n='Record';e={$_.RecordNumber}},
                        @{n='Status';e={$_.Status}},
                        @{n='Time';e={([wmi]'').ConvertToDateTime($_.EventTime)}},
                        @{n='Log';e={$_.LogRecord}}
                }
            }
            'PostProcessing' = $DellESMLog_Postprocessing
        }
    }
}
#endregion System Report Structure

#region System Report Static Variables
# Generally you don't futz with these, they are mostly just registry locations anyway
#31.39.1.252 Settings
$reg_WSUSSettings = "SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
# Product key (and other) settings
# for 32-bit: DigitalProductId
# for 64-bit: DigitalProductId4
$reg_ExtendedInfo = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$reg_NTPSettings = 'SYSTEM\CurrentControlSet\Services\W32Time\Parameters'
$ShareType = @{
    '0' = 'Disk Drive'
    '1' = 'Print Queue'
    '2' = 'Device'
    '3' = 'IPC'
    '2147483648' = 'Disk Drive Admin'
    '2147483649' = 'Print Queue Admin'
    '2147483650' = 'Device Admin'
    '2147483651' = 'IPC Admin'
}
#endregion System Report Static Variables

#region HTML Template Variables
# This is the meat and potatoes of how the reports are spit out. Currently it is
# broken down by html component -> rendering style.
$HTMLRendering = @{
    # Markers: 
    #   <0> - Server Name
    'Header' = @{
        'DynamicGrid' = @'
<!DOCTYPE html>
<!-- HTML5 Mobile Boilerplate -->
<!--[if IEMobile 7]><html class="no-js iem7"><![endif]-->
<!--[if (gt IEMobile 7)|!(IEMobile)]><!--><html class="no-js" lang="en"><!--<![endif]-->

<!-- HTML5 Boilerplate -->
<!--[if lt IE 7]><html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if (IE 7)&!(IEMobile)]><html class="no-js lt-ie9 lt-ie8" lang="en"><![endif]-->
<!--[if (IE 8)&!(IEMobile)]><html class="no-js lt-ie9" lang="en"><![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"><!--<![endif]-->

<head>

    <meta charset="utf-8">
    <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>System Report</title>
    <meta http-equiv="cleartype" content="on">
    <link rel="shortcut icon" href="/favicon.ico">

    <!-- Responsive and mobile friendly stuff -->
    <meta name="HandheldFriendly" content="True">
    <meta name="MobileOptimized" content="320">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Stylesheets 
    <link rel="stylesheet" href="css/html5reset.css" media="all">
    <link rel="stylesheet" href="css/responsivegridsystem.css" media="all">
    <link rel="stylesheet" href="css/col.css" media="all">
    <link rel="stylesheet" href="css/2cols.css" media="all">
    <link rel="stylesheet" href="css/3cols.css" media="all">
    -->
    <!--<link rel="stylesheet" href="AllStyles.css" media="all">-->
        <!-- Responsive Stylesheets 
    <link rel="stylesheet" media="only screen and (max-width: 1024px) and (min-width: 769px)" href="/css/1024.css">
    <link rel="stylesheet" media="only screen and (max-width: 768px) and (min-width: 481px)" href="/css/768.css">
    <link rel="stylesheet" media="only screen and (max-width: 480px)" href="/css/480.css">
    -->
    <!-- All JavaScript at the bottom, except for Modernizr which enables HTML5 elements and feature detects -->
    <!-- <script src="js/modernizr-2.5.3-min.js"></script> -->

    <style type="text/css">
    <!--
        /* html5reset.css - 01/11/2011 */
        html, body, div, span, object, iframe,
        h1, h2, h3, h4, h5, h6, p, blockquote, pre,
        abbr, address, cite, code,
        del, dfn, em, img, ins, kbd, q, samp,
        small, strong, sub, sup, var,
        b, i,
        dl, dt, dd, ol, ul, li,
        fieldset, form, label, legend,
        table, caption, tbody, tfoot, thead, tr, th, td,
        article, aside, canvas, details, figcaption, figure, 
        footer, header, hgroup, menu, nav, section, summary,
        time, mark, audio, video {
            margin: 0;
            padding: 0;
            border: 0;
            outline: 0;
            font-size: 100%;
            vertical-align: baseline;
            background: transparent;
        }
        body {
            line-height: 1;
        }
        article,aside,details,figcaption,figure,
        footer,header,hgroup,menu,nav,section { 
            display: block;
        }
        nav ul {
            list-style: none;
        }
        blockquote, q {
            quotes: none;
        }
        blockquote:before, blockquote:after,
        q:before, q:after {
            content: '';
            content: none;
        }
        a {
            margin: 0;
            padding: 0;
            font-size: 100%;
            vertical-align: baseline;
            background: transparent;
        }
        /* change colours to suit your needs */
        ins {
            background-color: #ff9;
            color: #000;
            text-decoration: none;
        }
        /* change colours to suit your needs */
        mark {
            background-color: #ff9;
            color: #000; 
            font-style: italic;
            font-weight: bold;
        }
        del {
            text-decoration:  line-through;
        }
        abbr[title], dfn[title] {
            border-bottom: 1px dotted;
            cursor: help;
        }
        table {
            border-collapse: collapse;
            border-spacing: 0;
        }
        /* change border colour to suit your needs */
        hr {
            display: block;
            height: 1px;
            border: 0;   
            border-top: 1px solid #cccccc;
            margin: 1em 0;
            padding: 0;
        }
        input, select {
            vertical-align: middle;
        }
        /* RESPONSIVE GRID SYSTEM =============================================================================  */
        /* BASIC PAGE SETUP ============================================================================= */
        body { 
        margin : 0 auto;
        padding : 0;
        font : 100%/1.4 'lucida sans unicode', 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif;     
        color : #000; 
        text-align: center;
        background: #fff url(/images/bodyback.png) left top;
        }
        button, 
        input, 
        select, 
        textarea { 
        font-family : MuseoSlab100, lucida sans unicode, 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif; 
        color : #333; }
        /*  HEADINGS  ============================================================================= */
        h1, h2, h3, h4, h5, h6 {
        font-family:  MuseoSlab300, 'lucida sans unicode', 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif;
        font-weight : normal;
        margin-top: 0px;
        letter-spacing: -1px;
        }
        h1 { 
        font-family:  LeagueGothicRegular, 'lucida sans unicode', 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif;
        color: #000;
        margin-bottom : 0.0em;
        font-size : 4em; /* 40 / 16 */
        line-height : 1.0;
        }
        h2 { 
        color: #222;
        margin-bottom : .5em;
        margin-top : .5em;
        font-size : 2.75em; /* 40 / 16 */
        line-height : 1.2;
        }
        h3 { 
        color: #333;
        margin-bottom : 0.3em;
        letter-spacing: -1px;
        font-size : 1.75em; /* 28 / 16 */
        line-height : 1.3; }
        h4 { 
        color: #444;
        margin-bottom : 0.5em;
        font-size : 1.5em; /* 24 / 16  */
        line-height : 1.25; }
            footer h4 { 
                color: #ccc;
            }
        h5 { 
        color: #555;
        margin-bottom : 1.25em;
        font-size : 1em; /* 20 / 16 */ }
        h6 { 
        color: #666;
        font-size : 1em; /* 16 / 16  */ }
        /*  TYPOGRAPHY  ============================================================================= */
        p, ol, ul, dl, address { 
        margin-bottom : 1.5em; 
        font-size : 1em; /* 16 / 16 = 1 */ }
        p {
        hyphens : auto;  }
        p.introtext {
        font-family:  MuseoSlab100, 'lucida sans unicode', 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif;
        font-size : 2.5em; /* 40 / 16 */
        color: #333;
        line-height: 1.4em;
        letter-spacing: -1px;
        margin-bottom: 0.5em;
        }
        p.handwritten {
        font-family:  HandSean, 'lucida sans unicode', 'lucida grande', 'Trebuchet MS', verdana, arial, helvetica, helve, sans-serif; 
        font-size: 1.375em; /* 24 / 16 */
        line-height: 1.8em;
        margin-bottom: 0.3em;
        color: #666;
        }
        p.center {
        text-align: center;
        }
        .and {
        font-family: GoudyBookletter1911Regular, Georgia, Times New Roman, sans-serif;
        font-size: 1.5em; /* 24 / 16 */
        }
        .heart {
        font-family: Pictos;
        font-size: 1.5em; /* 24 / 16 */
        }
        ul, 
        ol { 
        margin : 0 0 1.5em 0; 
        padding : 0 0 0 24px; }
        li ul, 
        li ol { 
        margin : 0;
        font-size : 1em; /* 16 / 16 = 1 */ }
        dl, 
        dd { 
        margin-bottom : 1.5em; }
        dt { 
        font-weight : normal; }
        b, strong { 
        font-weight : bold; }
        hr { 
        display : block; 
        margin : 1em 0; 
        padding : 0;
        height : 1px; 
        border : 0; 
        border-top : 1px solid #ccc;
        }
        small { 
        font-size : 1em; /* 16 / 16 = 1 */ }
        sub, sup { 
        font-size : 75%; 
        line-height : 0; 
        position : relative; 
        vertical-align : baseline; }
        sup { 
        top : -.5em; }
        sub { 
        bottom : -.25em; }
        .subtext {
            color: #666;
            }
        /* LINKS =============================================================================  */
        a { 
        color : #cc1122;
        -webkit-transition: all 0.3s ease;
        -moz-transition: all 0.3s ease;
        -o-transition: all 0.3s ease;
        transition: all 0.3s ease;
        text-decoration: none;
        }
        a:visited { 
        color : #ee3344; }
        a:focus { 
        outline : thin dotted; 
        color : rgb(0,0,0); }
        a:hover, 
        a:active { 
        outline : 0;
        color : #dd2233;
        }
        footer a { 
        color : #ffffff;
        -webkit-transition: all 0.3s ease;
        -moz-transition: all 0.3s ease;
        -o-transition: all 0.3s ease;
        transition: all 0.3s ease;
        }
        footer a:visited { 
        color : #fff; }
        footer a:focus { 
        outline : thin dotted; 
        color : rgb(0,0,0); }
        footer a:hover, 
        footer a:active { 
        outline : 0;
        color : #fff;
        }
        /* IMAGES ============================================================================= */
        img {
        border : 0;
        max-width: 100%;}
        img.floatleft { float: left; margin: 0 10px 0 0; }
        img.floatright { float: right; margin: 0 0 0 10px; }
        /* TABLES ============================================================================= */
        table { 
        border-collapse : collapse;
        border-spacing : 0;
        margin-bottom : 0em; 
        width : 100%; }
        th, td, caption { 
        padding : .25em 10px .25em 5px; }
        tfoot { 
        font-style : italic; }
        caption { 
        background-color : transparent; }
        /*  MAIN LAYOUT    ============================================================================= */
        #skiptomain { display: none; }
        #wrapper {
            width: 100%;
            position: relative;
            text-align: left;
        }
            #headcontainer {
                width: 100%;
            }
                header {
                    clear: both;
                    width: 100%; /* 1000px / 1250px */
                    font-size: 0.6125em; /* 13 / 16 */
                    max-width: 92.3em; /* 1200px / 13 */
                    margin: 0 auto;
                    padding: 5px 0px 0px 0px;
                    position: relative;
                    color: #000;
                    text-align: center ;
                }
            #maincontentcontainer {
                width: 100%;
            }
                .standardcontainer {
                }
                .darkcontainer {
                    background: rgba(102, 102, 102, 0.05);
                }
                .lightcontainer {
                    background: rgba(255, 255, 255, 0.25);
                }
                    #maincontent{
                        clear: both;
                        width: 80%; /* 1000px / 1250px */
                        font-size: 0.8125em; /* 13 / 16 */
                        max-width: 92.3em; /* 1200px / 13 */
                        margin: 0 auto;
                        padding: 1em 0px;
                        color: #333;
                        line-height: 1.5em;
                        position: relative;
                    }
                    .maincontent{
                        clear: both;
                        width: 80%; /* 1000px / 1250px */
                        font-size: 0.8125em; /* 13 / 16 */
                        max-width: 92.3em; /* 1200px / 13 */
                        margin: 0 auto;
                        padding: 1em 0px;
                        color: #333;
                        line-height: 1.5em;
                        position: relative;
                    }
            #footercontainer {
                width: 100%;    
                border-top: 1px solid #000;
                background: #222 url(/images/footerback.png) left top;
            }
                footer {
                    clear: both;
                    width: 80%; /* 1000px / 1250px */
                    font-size: 0.8125em; /* 13 / 16 */
                    max-width: 92.3em; /* 1200px / 13 */
                    margin: 0 auto;
                    padding: 20px 0px 10px 0px;
                    color: #999;
                }
                footer strong {
                    font-size: 1.077em; /* 14 / 13 */
                    color: #aaa;
                }
                footer a:link, footer a:visited { color: #999; text-decoration: underline; }
                footer a:hover { color: #fff; text-decoration: underline; }
                ul.pagefooterlist, ul.pagefooterlistimages {
                    display: block;
                    float: left;
                    margin: 0px;
                    padding: 0px;
                    list-style: none;
                }
                ul.pagefooterlist li, ul.pagefooterlistimages li {
                    clear: left;
                    margin: 0px;
                    padding: 0px 0px 3px 0px;
                    display: block;
                    line-height: 1.5em;
                    font-weight: normal;
                    background: none;
                }
                ul.pagefooterlistimages li {
                    height: 34px;
                }
                ul.pagefooterlistimages li img {
                    padding: 5px 5px 5px 0px;
                    vertical-align: middle;
                    opacity: 0.75;
                    -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=75)";
                    filter: alpha( opacity  = 75);
                    -webkit-transition: all 0.3s ease;
                    -moz-transition: all 0.3s ease;
                    -o-transition: all 0.3s ease;
                    transition: all 0.3s ease;
                }
                ul.pagefooterlistimages li a
                {
                    text-decoration: none;
                }
                ul.pagefooterlistimages li a:hover img {
                    opacity: 1.0;
                    -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)";
                    filter: alpha( opacity  = 100);
                }
                    #smallprint {
                        margin-top: 20px;
                        line-height: 1.4em;
                        text-align: center;
                        color: #999;
                        font-size: 0.923em; /* 12 / 13 */
                    }
                    #smallprint p{
                        vertical-align: middle;
                    }
                    #smallprint .twitter-follow-button{
                        margin-left: 1em;
                        vertical-align: middle;
                    }
                    #smallprint img {
                        margin: 0px 10px 15px 0px;
                        vertical-align: middle;
                        opacity: 0.5;
                        -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=50)";
                        filter: alpha( opacity  = 50);
                        -webkit-transition: all 0.3s ease;
                        -moz-transition: all 0.3s ease;
                        -o-transition: all 0.3s ease;
                        transition: all 0.3s ease;
                    }
                    #smallprint a:hover img {
                        opacity: 1.0;
                        -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)";
                        filter: alpha( opacity  = 100);
                    }
                    #smallprint a:link, #smallprint a:visited { color: #999; text-decoration: none; }
                    #smallprint a:hover { color: #999; text-decoration: underline; }
        /*  SECTIONS  ============================================================================= */
        .section {
            clear: both;
            padding: 0px;
            margin: 0px;
        }
        /*  CODE  ============================================================================= */
        pre.code {
            padding: 0;
            margin: 0;
            font-family: monospace;
            white-space: pre-wrap;
            font-size: 1.1em;
        }
        strong.code {
            font-weight: normal;
            font-family: monospace;
            font-size: 1.2em;
        }
        /*  EXAMPLE  ============================================================================= */
        #example .col {
            background: #ccc;
            background: rgba(204, 204, 204, 0.85);
        }
        /*  NOTES  ============================================================================= */
        .note {
            position:relative;
            padding:1em 1.5em;
            margin: 0 0 1em 0;
            background: #fff;
            background: rgba(255, 255, 255, 0.5);
            overflow:hidden;
        }
        .note:before {
            content:"";
            position:absolute;
            top:0;
            right:0;
            border-width:0 16px 16px 0;
            border-style:solid;
            border-color:transparent transparent #cccccc #cccccc;
            background:#cccccc;
            -webkit-box-shadow:0 1px 1px rgba(0,0,0,0.3), -1px 1px 1px rgba(0,0,0,0.2);
            -moz-box-shadow:0 1px 1px rgba(0,0,0,0.3), -1px 1px 1px rgba(0,0,0,0.2);
            box-shadow:0 1px 1px rgba(0,0,0,0.3), -1px 1px 1px rgba(0,0,0,0.2);
            display:block; width:0; /* Firefox 3.0 damage limitation */
        }
        .note.rounded {
            -webkit-border-radius:5px 0 5px 5px;
            -moz-border-radius:5px 0 5px 5px;
            border-radius:5px 0 5px 5px;
        }
        .note.rounded:before {
            border-width:8px;
            border-color:#ff #ff transparent transparent;
            background: url(/images/bodyback.png);
            -webkit-border-bottom-left-radius:5px;
            -moz-border-radius:0 0 0 5px;
            border-radius:0 0 0 5px;
        }
        /*  SCREENS  ============================================================================= */
        .siteimage {
            max-width: 90%;
            padding: 5%;
            margin: 0 0 1em 0;
            background: transparent url(/images/stripe-bg.png);
            -webkit-transition: background 0.3s ease;
            -moz-transition: background 0.3s ease;
            -o-transition: background 0.3s ease;
            transition: background 0.3s ease;
        }
        .siteimage:hover {
            background: #bbb url(/images/stripe-bg.png);
            position: relative;
            top: -2px;
            
        }
        /*  COLUMNS  ============================================================================= */
        .twocolumns{
            -moz-column-count: 2;
            -moz-column-gap: 2em;
            -webkit-column-count: 2;
            -webkit-column-gap: 2em;
            column-count: 2;
            column-gap: 2em;
          }
        /*  GLOBAL OBJECTS ============================================================================= */
        .breaker { clear: both; }
        .group:before,
        .group:after {
            content:"";
            display:table;
        }
        .group:after {
            clear:both;
        }
        .group {
            zoom:1; /* For IE 6/7 (trigger hasLayout) */
        }
        .floatleft {
            float: left;
        }
        .floatright {
            float: right;
        }
        /* VENDOR-SPECIFIC ============================================================================= */
        html { 
        -webkit-overflow-scrolling : touch; 
        -webkit-tap-highlight-color : rgb(52,158,219); 
        -webkit-text-size-adjust : 100%; 
        -ms-text-size-adjust : 100%; }
        .clearfix { 
        zoom : 1; }
        ::-webkit-selection { 
        background : rgb(23,119,175); 
        color : rgb(250,250,250); 
        text-shadow : none; }
        ::-moz-selection { 
        background : rgb(23,119,175); 
        color : rgb(250,250,250); 
        text-shadow : none; }
        ::selection { 
        background : rgb(23,119,175); 
        color : rgb(250,250,250); 
        text-shadow : none; }
        button, 
        input[type="button"], 
        input[type="reset"], 
        input[type="submit"] { 
        -webkit-appearance : button; }
        ::-webkit-input-placeholder {
        font-size : .875em; 
        line-height : 1.4; }
        input:-moz-placeholder { 
        font-size : .875em; 
        line-height : 1.4; }
        .ie7 img,
        .iem7 img { 
        -ms-interpolation-mode : bicubic; }
        input[type="checkbox"], 
        input[type="radio"] { 
        box-sizing : border-box; }
        input[type="search"] { 
        -webkit-box-sizing : content-box;
        -moz-box-sizing : content-box; }
        button::-moz-focus-inner, 
        input::-moz-focus-inner { 
        padding : 0;
        border : 0; }
        p {
        /* http://www.w3.org/TR/css3-text/#hyphenation */
        -webkit-hyphens : auto;
        -webkit-hyphenate-character : "\2010";
        -webkit-hyphenate-limit-after : 1;
        -webkit-hyphenate-limit-before : 3;
        -moz-hyphens : auto; }
        /*  SECTIONS  ============================================================================= */
        .section {
            clear: both;
            padding: 0px;
            margin: 0px;
        }
        /*  GROUPING  ============================================================================= */
        .group:before,
        .group:after {
            content:"";
            display:table;
        }
        .group:after {
            clear:both;
        }
        .group {
            zoom:1; /* For IE 6/7 (trigger hasLayout) */
        }
        /*  GRID COLUMN SETUP   ==================================================================== */
        .col {
            display: block;
            float:left;
            margin: 1% 0 1% 1.6%;
        }
        .col:first-child { margin-left: 0; } /* all browsers except IE6 and lower */
        /*  REMOVE MARGINS AS ALL GO FULL WIDTH AT 480 PIXELS */
        @media only screen and (max-width: 480px) {
            .col { 
                margin: 1% 0 1% 0%;
            }
        }
        /*  GRID OF TWO   ============================================================================= */
        .span_2_of_2 {
            width: 100%;
        }
        .span_1_of_2 {
            width: 49.2%;
        }
        /*  GO FULL WIDTH AT LESS THAN 480 PIXELS */
        @media only screen and (max-width: 480px) {
            .span_2_of_2 {
                width: 100%; 
            }
            .span_1_of_2 {
                width: 100%; 
            }
        }
        /*  GRID OF THREE   ============================================================================= */
        .span_3_of_3 {
            width: 100%; 
        }
        .span_2_of_3 {
            width: 66.1%; 
        }
        .span_1_of_3 {
            width: 32.2%; 
        }
        /*  GO FULL WIDTH AT LESS THAN 480 PIXELS */
        @media only screen and (max-width: 480px) {
            .span_3_of_3 {
                width: 100%; 
            }
            .span_2_of_3 {
                width: 100%; 
            }
            .span_1_of_3 {
                width: 100%;
            }
        }
        /*  GRID OF FOUR   ============================================================================= */
        .span_4_of_4 {
            width: 100%; 
        }
        .span_3_of_4 {
            width: 74.6%; 
        }
        .span_2_of_4 {
            width: 49.2%; 
        }
        .span_1_of_4 {
            width: 23.8%; 
        }
        /*  GO FULL WIDTH AT LESS THAN 480 PIXELS */
        @media only screen and (max-width: 480px) {
            .span_4_of_4 {
                width: 100%; 
            }
            .span_3_of_4 {
                width: 100%; 
            }
            .span_2_of_4 {
                width: 100%; 
            }
            .span_1_of_4 {
                width: 100%; 
            }
        }
        
        body {
            font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
        }
        
        table{
            border-collapse: collapse;
            border: none;
            font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
            color: black;
            margin-bottom: 0px;
        }
        table td{
            font-size: 10px;
            padding-left: 0px;
            padding-right: 20px;
            text-align: left;
        }
        table td:last-child{
            padding-right: 5px;
        }
        table th {
            font-size: 12px;
            font-weight: bold;
            padding-left: 0px;
            padding-right: 20px;
            text-align: left;
            border-bottom: 1px  grey solid;
        }
        h2{ 
            clear: both;
            font-size: 200%; 
            margin-left: 20px;
			font-weight: bold;
        }
        h3{
            clear: both;
            font-size: 115%;
            margin-left: 20px;
            margin-top: 30px;
        }
        p{ 
            margin-left: 20px; font-size: 12px;
        }
        table.list{
            float: left;
        }
        table.list td:nth-child(1){
            font-weight: bold;
            border-right: 1px grey solid;
            text-align: right;
        }
        table.list td:nth-child(2){
            padding-left: 7px;
        }
        table tr:nth-child(even) td:nth-child(even){ background: #CCCCCC; }
        table tr:nth-child(odd) td:nth-child(odd){ background: #F2F2F2; }
        table tr:nth-child(even) td:nth-child(odd){ background: #DDDDDD; }
        table tr:nth-child(odd) td:nth-child(even){ background: #E5E5E5; }
        
        /*  Error and warning highlighting - Row*/
        table tr.warn:nth-child(even) td:nth-child(even){ background: #FFFF88; }
        table tr.warn:nth-child(odd) td:nth-child(odd){ background: #FFFFBB; }
        table tr.warn:nth-child(even) td:nth-child(odd){ background: #FFFFAA; }
        table tr.warn:nth-child(odd) td:nth-child(even){ background: #FFFF99; }
        
        table tr.alert:nth-child(even) td:nth-child(even){ background: #204.202.246.222; }
        table tr.alert:nth-child(odd) td:nth-child(odd){ background: #FFBBBB; }
        table tr.alert:nth-child(even) td:nth-child(odd){ background: #FFAAAA; }
        table tr.alert:nth-child(odd) td:nth-child(even){ background: #122.52.193.92; }
        
        table tr.healthy:nth-child(even) td:nth-child(even){ background: #88FF88; }
        table tr.healthy:nth-child(odd) td:nth-child(odd){ background: #BBFFBB; }
        table tr.healthy:nth-child(even) td:nth-child(odd){ background: #AAFFAA; }
        table tr.healthy:nth-child(odd) td:nth-child(even){ background: #99FF99; }
        
        /*  Error and warning highlighting - Cell*/
        table tr:nth-child(even) td.warn:nth-child(even){ background: #FFFF88; }
        table tr:nth-child(odd) td.warn:nth-child(odd){ background: #FFFFBB; }
        table tr:nth-child(even) td.warn:nth-child(odd){ background: #FFFFAA; }
        table tr:nth-child(odd) td.warn:nth-child(even){ background: #FFFF99; }
        
        table tr:nth-child(even) td.alert:nth-child(even){ background: #204.202.246.222; }
        table tr:nth-child(odd) td.alert:nth-child(odd){ background: #FFBBBB; }
        table tr:nth-child(even) td.alert:nth-child(odd){ background: #FFAAAA; }
        table tr:nth-child(odd) td.alert:nth-child(even){ background: #122.52.193.92; }
        
        table tr:nth-child(even) td.healthy:nth-child(even){ background: #88FF88; }
        table tr:nth-child(odd) td.healthy:nth-child(odd){ background: #BBFFBB; }
        table tr:nth-child(even) td.healthy:nth-child(odd){ background: #AAFFAA; }
        table tr:nth-child(odd) td.healthy:nth-child(even){ background: #99FF99; }
        
        /* security highlighting */
        table tr.security:nth-child(even) td:nth-child(even){ 
            border-color: #66.236.231.170; 
            border: 1px #66.236.231.170 solid;
        }
        table tr.security:nth-child(odd) td:nth-child(odd){ 
            border-color: #66.236.231.170; 
            border: 1px #66.236.231.170 solid;
        }
        table tr.security:nth-child(even) td:nth-child(odd){
            border-color: #66.236.231.170; 
            border: 1px #66.236.231.170 solid;
        }
        table tr.security:nth-child(odd) td:nth-child(even){
            border-color: #66.236.231.170; 
            border: 1px #66.236.231.170 solid;
        }
        table th.title{ 
            text-align: center;
            background: #848482;
            border-bottom: 1px  black solid;
            font-weight: bold;
            color: white;
        }
        table th.sectioncomment{ 
            text-align: left;
            background: #848482;
            font-style : italic;
            color: white;
            font-weight: normal;
			border-color: black;
			border-top: 1px black solid;
        }
        table th.sectionbreak{ 
            text-align: center;
            background: #848482;
            border: 2px black solid;
            font-weight: bold;
            color: white;
            font-size: 130%;
        }
        table th.reporttitle{ 
            text-align: center;
            background: #848482;
            border: 2px black solid;
            font-weight: bold;
            color: white;
            font-size: 150%;
        }
        table tr.divide{
            border-bottom: 1px  grey solid;
        }
    -->
    </style></head>

<body>
<div id="wrapper">
'@
        'EmailFriendly' = @'
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Frameset//EN' 'http://www.w3.org/TR/html4/frameset.dtd'>
<html><head><title><0></title>
<style type='text/css'>
<!--
body {
    font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
}
table{
   border-collapse: collapse;
   border: none;
   font: 10pt Verdana, Geneva, Arial, Helvetica, sans-serif;
   color: black;
   margin-bottom: 10px;
   margin-left: 20px;
}
table td{
   font-size: 12px;
   padding-left: 0px;
   padding-right: 20px;
   text-align: left;
   border:1px solid black;
}
table th {
   font-size: 12px;
   font-weight: bold;
   padding-left: 0px;
   padding-right: 20px;
   text-align: left;
}

h1{ clear: both;
    font-size: 150%; 
    text-align: center;
  }
h2{ clear: both; font-size: 130%; }

h3{
   clear: both;
   font-size: 115%;
   margin-left: 20px;
   margin-top: 30px;
}

p{ margin-left: 20px; font-size: 12px; }

table.list{ float: left; }
   table.list td:nth-child(1){
   font-weight: bold;
   border: 1px grey solid;
   text-align: right;
}

table th.title{ 
    text-align: center;
    background: #848482;
    border: 2px  grey solid;
    font-weight: bold;
    color: white;
}
table tr.divide{
    border-bottom: 5px  grey solid;
}
.odd { background-color:#ffffff; }
.even { background-color:#dddddd; }
.warn { background-color:yellow; }
.alert { background-color:salmon; }
.healthy { background-color:palegreen; }
-->
</style>
</head>
<body>
'@
    }
    'Footer' = @{
        'DynamicGrid' = @'
</div>
</body>
</html>        
'@
        'EmailFriendly' = @'
</div>
</body>
</html>       
'@
    }

    # Markers: 
    #   <0> - Server Name
    'ServerBegin' = @{
        'DynamicGrid' = @'
    
    <hr noshade size="3" width='100%'>
    <div id="headcontainer">
        <table>        
            <tr>
                <th class="reporttitle"><0></th>
            </tr>
        </table>
    </div>
    <div id="maincontentcontainer">
        <div id="maincontent">
            <div class="section group">
                <hr noshade size="3" width='100%'>
            </div>
            <div>

       
'@
        'EmailFriendly' = @'
    <div id='report'>
    <hr noshade size=3 width='100%'>
    <h1><0></h1>

    <div id="maincontentcontainer">
    <div id="maincontent">
      <div class="section group">
        <hr noshade="noshade" size="3" width="100%" style=
        "display:block;height:1px;border:0;border-top:1px solid #ccc;margin:1em 0;padding:0;" />
      </div>
      <div>

'@    
    }
    'ServerEnd' = @{
        'DynamicGrid' = @'

            </div>
        </div>
    </div>
</div>

'@
        'EmailFriendly' = @'

            </div>
        </div>
    </div>
</div>

'@
    }
    
    # Markers: 
    #   <0> - columns to span title
    #   <1> - Table header title
    'TableTitle' = @{
        'DynamicGrid' = @'
        
            <tr>
                <th class="title" colspan=<0>><1></th>
            </tr>
'@
        'EmailFriendly' = @'
            
            <tr>
              <th class="title" colspan="<0>"><1></th>
            </tr>
              
'@
    }
    
    'TableComment' = @{
        'DynamicGrid' = @'
        
            <tr>
                <th class="sectioncomment" colspan=<0>><1></th>
            </tr>
'@
        'EmailFriendly' = @'
            
            <tr>
              <th class="sectioncomment" colspan="<0>"><1></th>
            </tr>
              
'@
    }    

    'SectionContainers' = @{
        'DynamicGrid'  = @{
            'Half' = @{
                'Head' = @'
        
        <div class="col span_2_of_4">
'@
                'Tail' = @'
        </div>
'@
            }
            'Full' = @{
                'Head' = @'
        
        <div class="col span_4_of_4">
'@
                'Tail' = @'
        </div>
'@
            }
            'Third' = @{
                'Head' = @'
        
        <div class="col span_1_of_3">
'@
                'Tail' = @'
        </div>
'@
            }
            'TwoThirds' = @{
                'Head' = @'
        
        <div class="col span_2_of_3">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'Fourth'        = @{
                'Head' = @'
        
        <div class="col span_1_of_4">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'ThreeFourths'  = @{
                'Head' = @'
               
        <div class="col span_3_of_4">
'@
                'Tail'          = @'
        
        </div>
'@
            }
        }
        'EmailFriendly'  = @{
            'Half' = @{
                'Head' = @'
        
        <div class="col span_2_of_4">
        <table><tr WIDTH="50%">
'@
                'Tail' = @'
        </tr></table>       
        </div>
'@
            }
            'Full' = @{
                'Head' = @'
        
        <div class="col span_4_of_4">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'Third' = @{
                'Head' = @'
        
        <div class="col span_1_of_3">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'TwoThirds' = @{
                'Head' = @'
        
        <div class="col span_2_of_3">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'Fourth'        = @{
                'Head' = @'
        
        <div class="col span_1_of_4">
'@
                'Tail' = @'
                
        </div>
'@
            }
            'ThreeFourths'  = @{
                'Head' = @'
               
        <div class="col span_3_of_4">
'@
                'Tail'          = @'
        
        </div>
'@
            }
        }
    }
    
    'SectionContainerGroup' = @{
        'DynamicGrid' = @{ 
            'Head' = @'
        
        <div class="section group">
'@
            'Tail' = @'
        </div>
'@
        }
        'EmailFriendly' = @{
            'Head' = @'
    
        <div class="section group">
'@
            'Tail' = @'
        </div>
'@
        }
    }
    
    'CustomSections' = @{
        # Markers: 
        #   <0> - Header
        'SectionBreak' = @'
    
    <div class="section group">        
        <div class="col span_4_of_4"><table>        
            <tr>
                <th class="sectionbreak"><0></th>
            </tr>
        </table>
        </div>
    </div>
'@
    }
}
#endregion HTML Template Variables
#endregion Globals

#region Functions
#region Functions - Multiple Runspace
Function Get-RemoteRouteTable
{
    <#
    .SYNOPSIS
       Gathers remote system route entries.
    .DESCRIPTION
       Gathers remote system route entries, including persistent routes. Utilizes multiple runspaces and
       alternate credentials if desired.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > Get-RemoteRouteTable

       <output>
       
       Description
       -----------
       <Placeholder>

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/31/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Route Table: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Route Table: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Route Table: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Route Table: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Route Table: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Route Table: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Route Table: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $ResultSet = @()
                $PSDateTime = Get-Date
                $RouteType = @('Unknown','Other','Invalid','Direct','Indirect')
                $Routes = @()
                
                #region Routes
                Write-Verbose -Message ('Remote Route Table: Runspace {0}: Route table information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Routes')
                                         
                # WMI data
                $wmi_routes = Get-WmiObject @WMIHast -Class win32_ip4RouteTable
                $wmi_persistedroutes = Get-WmiObject @WMIHast -Class win32_IP4PersistedRouteTable
                foreach ($iproute in $wmi_routes)
                {
                    $Persistant = $false
                    foreach ($piproute in $wmi_persistedroutes)
                    {
                        if (($iproute.Destination -eq $piproute.Destination) -and
                            ($iproute.Mask -eq $piproute.Mask) -and
                            ($iproute.NextHop -eq $piproute.NextHop))
                        {
                            $Persistant = $true
                        }
                    }
                    $RouteProperty = @{
                        'InterfaceIndex' = $iproute.InterfaceIndex
                        'Destination' = $iproute.Destination
                        'Mask' = $iproute.Mask
                        'NextHop' = $iproute.NextHop
                        'Metric' = $iproute.Metric1
                        'Persistent' = $Persistant
                        'Type' = $RouteType[[int]$iproute.Type]
                    }
                    $Routes += New-Object -TypeName PSObject -Property $RouteProperty
                }
                # Setup the default properties for output
                $ResultObject = New-Object PSObject -Property @{
                                                                'PSComputerName' = $ComputerName
                                                                'ComputerName' = $ComputerName
                                                                'PSDateTime' = $PSDateTime
                                                                'Routes' = $Routes
                                                               }
                $ResultObject.PSObject.TypeNames.Insert(0,'My.RouteTable.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                #endregion Routes

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Remote Route Table: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Route Table: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Route Table: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Route Table: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Route Table: Getting info'
                        Status = 'Remote Route Table: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Route Table: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
     END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Route Table: Getting route table information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Route Table: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function New-RemoteCommand
{
    <#
    .SYNOPSIS
        Uses WMI to send a command to a remote system and store the results in a local file. 
    .DESCRIPTION
        Uses WMI and file copying trickery to get the results of a remotely executed command.
    .PARAMETER ComputerName
        Specifies the target computer for data query.
    .PARAMETER cmdTimeOutValue
        Time, in seconds, in which we should wait for the remote command process ID to complete. Default
        is 10 seconds.
    .PARAMETER cmdResultsLocation
        Location on the remote system to store the results of the command. Default is the env:systemroot\TEMP
        directory (usually C:\Windows\TEMP)
    .PARAMETER $cmdUniqueID
        A unique identifier to use for the remote results file name to utilize in its name. By default it is the
        current time in UTC converted to ticks. You can modify this if you always want the same name to be used.
        (Note: The remote results file name is in the format of <ComputerName>_<UniqueID>.tmp
    .PARAMETER ThrottleLimit
        Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
        Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > New-RemoteCommand

       <output>
       
       Description
       -----------
       <Placeholder>

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/31/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter(HelpMessage='Command to execute on remote system')]
        [string]
        $RemoteCMD,
        
        [Parameter(HelpMessage='Time to wait for remote command to complete (in seconds) before giving up.')]
        [int]
        $cmdTimeOutValue = 10,
        
        [Parameter(HelpMessage='Alternate location to copy command result files on the remote host. Default is to the %systemroot%\temp directory')]
        [string]
        $cmdResultsLocation,
        
        [Parameter(HelpMessage='Command unique identifier. Defaults to random(ish) string')]
        [string]
        $cmdUniqueID = (Get-Date).touniversaltime().ticks,
        
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Command Execution: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Command Execution: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Command Execution: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Command Execution: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Command Execution: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Command Execution: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [string]
                $RemoteCMD,
                
                [Parameter()]
                [int]
                $cmdTimeOutValue,
                
                [Parameter()]
                [string]
                $cmdResultsLocation,
                
                [Parameter()]
                [string]
                $cmdUniqueID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Command Execution: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                
                $BitsCred = @{
                    ErrorAction = 'Stop'                    
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                    $wshcred_user =  $Credential.GetNetworkCredential().UserName
                    $wshcred_pwd = $Credential.GetNetworkCredential().Password
                }

                # General variables
                $PSDateTime = Get-Date
                
                #region Remote Command
                Write-Verbose -Message ('Remote Command Execution: Runspace {0}: information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','RemoteOutputFullSharePath','CommandResults')

                # Get the system root information to store our temp file
                if (($cmdResultsLocation -eq $null) -or ($cmdResultsLocation -eq ''))
                {
                    $reg_ExtendedInfo = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion'
                    $wmi_registry = Get-WmiObject @WMIHast -Class StdRegProv -Namespace 'root\default' -List:$true
                    $RemoteSystemRoot = ($wmi_registry.GetStringValue('2147483650',$reg_ExtendedInfo,'SystemRoot')).sValue
                    $cmdResultsLocalPath = "$($RemoteSystemRoot)\TEMP"
                }
                else
                {
                    $cmdResultsLocalPath = $cmdResultsLocation
                }
                
                $cmdResultsFileName  = "$($ComputerName)_$($cmdUniqueID).tmp"
                $cmdResultsLocalFullPath = "$($cmdResultsLocalPath)\$($cmdResultsFileName)"
                $cmdResultsSharePath = "\\$($ComputerName)\$($cmdResultsLocalPath -replace ':','$')"
                $cmdResultsFullSharePath = "$($cmdResultsSharePath)\$($cmdResultsFileName)"
                Write-Verbose -Message ('Remote Command Execution: Runspace {0}: Remote Path - {1}' -f $ComputerName,$cmdResultsLocalPath)
                Write-Verbose -Message ('Remote Command Execution: Runspace {0}: Temp File - {1}' -f $ComputerName,$cmdResultsFileName)
                $CMD = "$($RemoteCMD) > $cmdResultsLocalFullPath"
                
                Write-Verbose -Message ('Remote Command Execution: Runspace {0}: Command - {1}' -f $ComputerName,$CMD)
                
                # Kick off the remote command and grab the process id
                $processId = (Invoke-WmiMethod @WMIHast `
                                               -Class Win32_Process `
                                               -Name create `
                                               -ArgumentList $CMD).ProcessId
                                            
                $runningCheck = {Get-WmiObject @WMIHast -Class Win32_Process -Filter "ProcessId='$processId'"}

                $SecondsRun = 0
                $TimedOut = $false
                while (((& $runningCheck) -ne $null) -and (!$TimedOut))
                {
                    Start-Sleep -Seconds 1
                    $SecondsRun = $SecondsRun + 1
                    if ($SecondsRun -eq $CommandTimeLimit)
                    {
                        $TimedOut = $true
                    }
                }
                
                if ($TimedOut)
                {
                    Write-Warning ('Remote Command Execution: Runspace {0}: WARNING - Command started but took too long to complete ProcessID {1} ' -f $ComputerName,$ProcessID)
                }
                else
                {
                    $ResultProperty = @{
                        'PSComputerName' = $ComputerName
                        'PSDateTime' = $PSDateTime
                        'ComputerName' = $ComputerName
                        'RemoteOutputFileName' = $cmdResultsFileName
                        'RemoteOutputLocalPath' = $cmdResultsLocalFullPath
                        'RemoteOutputSharePath' = $cmdResultsSharePath
                        'RemoteOutputFullLocalPath' = $cmdResultsLocalFullPath
                        'RemoteOutputFullSharePath' = $cmdResultsFullSharePath
                    }
                    $ResultObject += New-Object -TypeName PSObject -Property $ResultProperty
                }                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.RemoteCMD.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
                #endregion
            }
            catch
            {
                Write-Warning -Message ('Remote Command Execution: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Command Execution: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers.($runspace.ID)
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Command Execution: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Command Execution: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Command Execution: Getting info'
                        Status = 'Remote Command Execution: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('RemoteCMD',$RemoteCMD)
            $null = $psCMD.AddParameter('cmdTimeOutValue',$cmdTimeOutValue)
            $null = $psCMD.AddParameter('cmdUniqueID',$cmdUniqueID)
            $null = $psCMD.AddParameter('cmdResultsLocation',$cmdResultsLocation)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Command Execution: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Command Execution: Sending command' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Command Execution: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()

    }
}

Function Get-RemoteFirewallStatus
{
    <#
    .SYNOPSIS
       Retrieves firewall status from remote systems via the registry.
    .DESCRIPTION
       Retrieves firewall status from remote systems via the registry.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > (Get-RemoteFirewallStatus).Rules | where {$_.Active -eq 'TRUE'} | Select Name,Dir
       
       Description
       -----------
       Displays the name and direction of all active firewall rules defined in the registry of the
       local system.
    .EXAMPLE
       PS > (Get-RemoteFirewallStatus).FirewallEnabled

       Description
       -----------
       Displays the status of the local firewall.
       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 10/02/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Maximum number of concurrent runspaces.")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a runspaces stops trying to gather the information.")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function.")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials.")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials.")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Firewall Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Firewall Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Firewall Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Firewall Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Firewall Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Firewall Information: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,

                [Parameter()]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Firewall Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }
                $FwProtocols = @{
                    1="ICMPv4"
                    2="IGMP"
                    6="TCP"
                    17="UDP"
                    41="IPv6"
                    43="IPv6Route"
                    44="IPv6Frag"
                    47="GRE"
                    58="ICMPv6"
                    59="IPv6NoNxt"
                    60="IPv6Opts"
                    112="VRRP"
                    113="PGM"
                    115="L2TP"
                }
                  
                #region Firewall Settings
                Write-Verbose -Message ('Firewall Information: Runspace {0}: Gathering registry information' -f $ComputerName)
                $defaultProperties    = @('ComputerName','FirewallEnabled')
                $HKLM = '2147483650'
                $BasePath = 'System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy'
                $FW_DomainProfile = "$BasePath\DomainProfile"
                $FW_PublicProfile = "$BasePath\PublicProfile"
                $FW_StandardProfile = "$BasePath\StandardProfile"
                $FW_DomainLogPath = "$($FW_DomainProfile)\Logging"
                $FW_PublicLogPath = "$($FW_PublicProfile)\Logging"
                $FW_StandardLogPath = "$($FW_StandardProfile)\Logging"
                
                $reg = Get-WmiObject @WMIHast -Class StdRegProv -Namespace 'root\default' -List:$true
                $DomainEnabled = [bool]($reg.GetDwordValue($HKLM, $FW_DomainProfile, "EnableFirewall")).uValue
                $PublicEnabled = [bool]($reg.GetDwordValue($HKLM, $FW_PublicProfile, "EnableFirewall")).uValue
                $StandardEnabled = [bool]($reg.GetDwordValue($HKLM, $FW_StandardProfile, "EnableFirewall")).uValue
                $FirewallEnabled = $false
                $FirewallKeys = @() 
                $FirewallKeys += 'System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules'
                $FirewallKeys += 'Software\Policies\Microsoft\WindowsFirewall\FirewallRules'
                $RuleList = @()
                
                foreach ($Key in $FirewallKeys) 
                { 
                    $FirewallRules = $reg.EnumValues($HKLM,$Key)
                    for ($i = 0; $i -lt $FirewallRules.Types.Count; $i++) 
                    {
                        $Rule = ($reg.GetStringValue($HKLM,$Key,$FirewallRules.sNames[$i])).sValue
                        
                        # Prepare hashtable 
                        $HashProps = @{ 
                            NameOfRule = ($FirewallRules.sNames[$i])
                            RuleVersion = ($Rule -split '\|')[0] 
                            Action = $null 
                            Active = $null 
                            Dir = $null 
                            Proto = $null 
                            LPort = $null 
                            App = $null 
                            Name = $null 
                            Desc = $null 
                            EmbedCtxt = $null 
                            Profile = 'All' 
                            RA4 = $null 
                            RA6 = $null 
                            Svc = $null 
                            RPort = $null 
                            ICMP6 = $null 
                            Edge = $null 
                            LA4 = $null 
                            LA6 = $null 
                            ICMP4 = $null 
                            LPort2_10 = $null 
                            RPort2_10 = $null 
                        } 
             
                        # Determine if this is a local or a group policy rule and display this in the hashtable 
                        if ($Key -match 'System\\CurrentControlSet') 
                        { 
                            $HashProps.RuleType = 'Local' 
                        } 
                        else 
                        { 
                            $HashProps.RuleType = 'GPO'
                        } 
             
                        # Iterate through the value of the registry key and fill PSObject with the relevant data 
                        foreach ($FireWallRule in ($Rule -split '\|')) 
                        { 
                            switch (($FireWallRule -split '=')[0]) { 
                                'Action' {$HashProps.Action = ($FireWallRule -split '=')[1]} 
                                'Active' {$HashProps.Active = ($FireWallRule -split '=')[1]} 
                                'Dir' {$HashProps.Dir = ($FireWallRule -split '=')[1]} 
                                'Protocol' {$HashProps.Proto = $FwProtocols[[int](($FireWallRule -split '=')[1])]} 
                                'LPort' {$HashProps.LPort = ($FireWallRule -split '=')[1]} 
                                'App' {$HashProps.App = ($FireWallRule -split '=')[1]} 
                                'Name' {$HashProps.Name = ($FireWallRule -split '=')[1]} 
                                'Desc' {$HashProps.Desc = ($FireWallRule -split '=')[1]} 
                                'EmbedCtxt' {$HashProps.EmbedCtxt = ($FireWallRule -split '=')[1]} 
                                'Profile' {$HashProps.Profile = ($FireWallRule -split '=')[1]} 
                                'RA4' {[array]$HashProps.RA4 += ($FireWallRule -split '=')[1]} 
                                'RA6' {[array]$HashProps.RA6 += ($FireWallRule -split '=')[1]} 
                                'Svc' {$HashProps.Svc = ($FireWallRule -split '=')[1]} 
                                'RPort' {$HashProps.RPort = ($FireWallRule -split '=')[1]} 
                                'ICMP6' {$HashProps.ICMP6 = ($FireWallRule -split '=')[1]} 
                                'Edge' {$HashProps.Edge = ($FireWallRule -split '=')[1]} 
                                'LA4' {[array]$HashProps.LA4 += ($FireWallRule -split '=')[1]} 
                                'LA6' {[array]$HashProps.LA6 += ($FireWallRule -split '=')[1]} 
                                'ICMP4' {$HashProps.ICMP4 = ($FireWallRule -split '=')[1]} 
                                'LPort2_10' {$HashProps.LPort2_10 = ($FireWallRule -split '=')[1]} 
                                'RPort2_10' {$HashProps.RPort2_10 = ($FireWallRule -split '=')[1]} 
                                Default {} 
                            }
                            if ($HashProps.Name -match '\@')
                            {
                                $HashProps.Name = $HashProps.NameOfRule
                            }
                        } 
                     
                        # Create and output object using the properties defined in the hashtable 
                        $RuleList += New-Object -TypeName 'PSCustomObject' -Property $HashProps 
                    }
                }

                if ($DomainEnabled -or $PublicEnabled -or $StandardEnabled)
                {
                    $FirewallEnabled = $true
                }
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'FirewallEnabled' = $FirewallEnabled
                    'DomainZoneEnabled' = $DomainEnabled
                    'DomainZoneLogPath' = [string]($reg.GetStringValue($HKLM,$FW_DomainLogPath, "LogFilePath").sValue)
                    'DomainZoneLogSize' = [int]($reg.GetDWORDValue($HKLM,$FW_DomainLogPath,"LogFileSize").uValue)
                    'PublicZoneEnabled' = $PublicEnabled
                    'PublicZoneLogPath' = [string]($reg.GetStringValue($HKLM,$FW_PublicLogPath, "LogFilePath").sValue)
                    'PublicZoneLogSize' = [int]($reg.GetDWORDValue($HKLM,$FW_PublicLogPath,"LogFileSize").uValue)
                    'StandardZoneEnabled' = $StandardEnabled
                    'StandardZoneLogPath' = [string]($reg.GetStringValue($HKLM,$FW_StandardLogPath, "LogFilePath").sValue)
                    'StandardZoneLogSize' = [int]($reg.GetDWORDValue($HKLM,$FW_StandardLogPath,"LogFileSize").uValue)
                    'Rules' = $RuleList
                }

                $ResultObject = New-Object PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.RemoteFirewall.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Firewall Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Firewall Information: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Firewall Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Firewall Information: Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Firewall Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting installed programs'
                        Status = 'Firewall Information: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Firewall Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Firewall Information: Getting program listing' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Firewall Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteShadowCopyInformation
{
    <#
    .SYNOPSIS
       Gathers shadow copy volume information from a system.
    .DESCRIPTION
       Gathers shadow copy volume information from a system. Utilizes remote runspaces and alternate
       credentials.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > (Get-RemoteShadowCopyInformation -ComputerName '63.53.28.206' -Credential $cred).ShadowCopyVolumes

       ShadowSizeMax      : 16,384.00 PB
        VolumeCapacityUsed : 228.09
        Drive              : C:\
        ShadowCapacityUsed : 0
        DriveCapacity      : 20.00 GB
        ShadowSizeUsed     : 45.63 GB
       
       Description
       -----------
       Gathers shadow copy information from Server2 using alternate credentials and displays arguably the
       most useful information, the shadow copy volume information.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/15/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Shadow Copy Function: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Shadow Copy Function: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Shadow Copy Function: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Shadow Copy Function: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Shadow Copy Function: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Shadow Copy Function: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            Filter ConvertTo-KMG 
            {
                $bytecount = $_
                switch ([math]::truncate([math]::log($bytecount,1024))) 
                {
                      0 {"$bytecount Bytes"}
                      1 {"{0:n2} KB" -f ($bytecount / 1kb)}
                      2 {"{0:n2} MB" -f ($bytecount / 1mb)}
                      3 {"{0:n2} GB" -f ($bytecount / 1gb)}
                      4 {"{0:n2} TB" -f ($bytecount / 1tb)}
                Default {"{0:n2} PB" -f ($bytecount / 1pb)}
                }
            }
            try
            {
                Write-Verbose -Message ('Shadow Copy Function: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $PSDateTime = Get-Date
                
                #region Data Collection
                Write-Verbose -Message ('Shadow Copy Function: Runspace {0}: Share session information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','ShadowCopyVolumes','ShadowCopySettings', `
                                          'ShadowCopyProviders','ShadowCopies')

                $wmi_shadowcopyareas = Get-WmiObject @WMIHast -Class win32_shadowstorage
		        $wmi_volumeinfo =  Get-WmiObject @WMIHast -Class win32_volume
                $wmi_shadowcopyproviders = Get-WmiObject @WMIHast -Class Win32_ShadowProvider
                $wmi_shadowcopysettings = Get-WmiObject @WMIHast -Class Win32_ShadowContext
                $wmi_shadowcopies = Get-WmiObject @WMIHast -Class Win32_ShadowCopy
                $ShadowCopyVolumes = @()
                $ShadowCopyProviders = @()
                $ShadowCopySettings = @()
                $ShadowCopies = @()
                foreach ($shadow in $wmi_shadowcopyareas)
                {
                    foreach ($volume in $wmi_volumeinfo)
                    {
                        if ($shadow.Volume -like "*$($volume.DeviceId.trimstart("\\?\Volume").trimend("\"))*")
                        {
                            $ShadowCopyVolumeProperty = 
                            @{
                                'Drive' = $volume.Name
                                'DriveCapacity' = $volume.Capacity | ConvertTo-KMG
        					    'ShadowSizeMax' = $shadow.MaxSpace  | ConvertTo-KMG
        					    'ShadowSizeUsed' = $shadow.UsedSpace  | ConvertTo-KMG
                                'ShadowCapacityUsed' = [math]::round((($shadow.UsedSpace/$shadow.MaxSpace) * 100),2)
                                'VolumeCapacityUsed' = [math]::round((($shadow.UsedSpace/$volume.Capacity) * 100),2)
                             }
                            $ShadowCopyVolumes += New-Object -TypeName PSObject -Property $ShadowCopyVolumeProperty
                        }
                    }
                }
                foreach ($scprovider in $wmi_shadowcopyproviders)
                {
                    $SCCopyProviderProp = @{
                        'Name' = $scprovider.Name
                        'CLSID' = $scprovider.CLSID
                        'ID' = $scprovider.ID
                        'Type' = $scprovider.Type
                        'Version' = $scprovider.Version
                        'VersionID' = $scprovider.VersionID
                    }
                    $ShadowCopyProviders += 
                        New-Object -TypeName PSObject -Property $SCCopyProviderProp
                }
                foreach ($scsetting in $wmi_shadowcopysettings)
                {
                    $SCSettingProperty = @{
                        'Name' = $scsetting.Name
                        'ClientAccessible' = $scsetting.ClientAccessible
                        'Differential' = $scsetting.Differential
                        'ExposedLocally' = $scsetting.ExposedLocally
                        'ExposedRemotely' = $scsetting.ExposedRemotely
                        'HardwareAssisted' = $scsetting.HardwareAssisted
                        'Imported' = $scsetting.Imported
                        'NoAutoRelease' = $scsetting.NoAutoRelease
                        'NotSurfaced' = $scsetting.NotSurfaced
                        'NoWriters' = $scsetting.NoWriters
                        'Persistent' = $scsetting.Persistent
                        'Plex' = $scsetting.Plex
                        'Transportable' = $scsetting.Transportable
                     }
                     $ShadowCopySettings += New-Object -TypeName PSObject -Property $SCSettingProperty

                }                
                foreach ($shadowcopy in $wmi_shadowcopies)
                {
                    $SCProperty = @{
                        'ID' = $shadowcopy.ID
                        'ClientAccessible' = $shadowcopy.ClientAccessible
                        'Count' = $shadowcopy.Count
                        'DeviceObject' = $shadowcopy.DeviceObject
                        'Differnetial' = $shadowcopy.Differential
                        'ExposedLocally' = $shadowcopy.ExposedLocally
                        'ExposedName' = $shadowcopy.ExposedName
                        'ExposedRemotely' = $shadowcopy.ExposedRemotely
                        'HardwareAssisted' = $shadowcopy.HardwareAssisted
                        'Imported' = $shadowcopy.Imported
                        'NoAutoRelease' = $shadowcopy.NoAutoRelease
                        'NotSurfaced' = $shadowcopy.NotSurfaced
                        'NoWriters' = $shadowcopy.NoWriters
                        'Persistent' = $shadowcopy.Persistent
                        'Plex' = $shadowcopy.Plex
                        'ProviderID' = $shadowcopy.ProviderID
                        'ServiceMachine' = $shadowcopy.ServiceMachine
                        'SetID' = $shadowcopy.SetID
                        'State' = $shadowcopy.State
                        'Transportable' = $shadowcopy.Transportable
                        'VolumeName' = $shadowcopy.VolumeName
                    }
                    $ShadowCopies += New-Object -TypeName PSObject -Property $SCProperty
                }
                
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'ShadowCopyVolumes' = $ShadowCopyVolumes
                    'ShadowCopySettings' = $ShadowCopySettings
                    'ShadowCopies' = $ShadowCopies
                    'ShadowCopyProviders' = $ShadowCopyProviders
                }
                                    
                $ResultObject += New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.ShadowCopy.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
                #endregion Data Collection
            }
            catch
            {
                Write-Warning -Message ('Shadow Copy Function: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Shadow Copy Function: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Shadow Copy Function: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Shadow Copy Function: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Shadow Copy Function: Getting info'
                        Status = 'Shadow Copy Function: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Shadow Copy Function: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
     END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Shadow Copy Function: Getting share session information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Shadow Copy Function: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteGroupMembership
{
    <#
    .SYNOPSIS
       Gather list of all assigned users in all local groups on a computer.  
    .DESCRIPTION
       Gather list of all assigned users in all local groups on a computer.  
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER IncludeEmptyGroups
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > (Get-RemoteGroupMembership -verbose).GroupMembership

       <output>
       
       Description
       -----------

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/09/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Include empty groups in results")]
        [switch]
        $IncludeEmptyGroups,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Local Group Membership: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Local Group Membership: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Local Group Membership: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Local Group Membership: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Local Group Membership: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Local Group Membership: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [switch]
                $IncludeEmptyGroups
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Local Group Membership: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $GroupMembership = @()
                $PSDateTime = Get-Date
                
                #region Group Information
                Write-Verbose -Message ('Local Group Membership: Runspace {0}: Group memberhsip information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','GroupMembership')
                $wmi_groups = Get-WmiObject @WMIHast -Class win32_group -filter "Domain = '$ComputerName'"
                foreach ($group in $wmi_groups)
                {
                    $Query = "SELECT * FROM Win32_GroupUser WHERE GroupComponent = `"Win32_Group.Domain='$ComputerName',Name='$($group.name)'`""
                    $wmi_users = Get-WmiObject @WMIHast -query $Query
                    if (($wmi_users -eq $null) -and ($IncludeEmptyGroups))
                    {
                        $MembershipProperty = @{
                            'Group' = $group.Name
                            'GroupMember' = ''
                            'MemberType' = ''
                        }
                        $GroupMembership += New-Object PSObject -Property $MembershipProperty
                    }
                    else
                    {
                        foreach ($user in $wmi_users.partcomponent)
                        {
                            if ($user -match 'Win32_UserAccount')
                            {
                                $Type = 'User Account'
                            }
                            elseif ($user -match 'Win32_Group')
                            {
                                $Type = 'Group'
                            }
                            elseif ($user -match 'Win32_SystemAccount')
                            {
                                $Type = 'System Account'
                            }
                            else
                            {
                                $Type = 'Other'
                            }
                            $MembershipProperty = @{
                                'Group' = $group.Name
                                'GroupMember' = ($user.replace("Domain="," , ").replace(",Name=","\").replace("\\",",").replace('"','').split(","))[2]
                                'MemberType' = $Type
                            }
                            $GroupMembership += New-Object PSObject -Property $MembershipProperty
                        }
                    }
                }
                
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'GroupMembership' = $GroupMembership
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.GroupMembership.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                Write-Output -InputObject $ResultObject
                #endregion Group Information
            }
            catch
            {
                Write-Warning -Message ('Local Group Membership: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Local Group Membership: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Local Group Membership: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Local Group Membership: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Local Group Membership: Getting info'
                        Status = 'Local Group Membership: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('IncludeEmptyGroups',$IncludeEmptyGroups)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Local Group Membership: Starting {0}' -f $Computer)
            
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
     END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Local Group Membership: Getting local group information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Local Group Membership: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-ComputerAssetInformation
{
    <#
    .SYNOPSIS
       Get inventory data for specified computer systems.
    .DESCRIPTION
       Gather inventory data for one or more systems using wmi. Data proccessing utilizes multiple runspaces
       and supports custom timeout parameters in case of wmi problems. You can optionally include 
       drive, memory, and network information in the results. You can view verbose information on each 
       runspace thread in realtime with the -Verbose option.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER IncludeMemoryInfo
    .PARAMETER IncludeDiskInfo
    .PARAMETER IncludeNetworkInfo
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .PARAMETER PromptForCredential
       Prompt for remote system credential prior to processing request.
    .PARAMETER Credential
       Accept alternate credential (ignored if the localhost is processed)
    .EXAMPLE
       PS > Get-ComputerAssetInformation -ComputerName 73.147.113.236
     
            ComputerName        : TEST1
            IsVirtual           : False
            Model               : ProLiant DL380 G7
            ChassisModel        : Rack Mount Unit
            OperatingSystem     : Microsoft Windows Server 2008 R2 Enterprise 
            OSServicePack       : 1
            OSVersion           : 6.1.7601
            OSSKU               : Enterprise Server Edition
            OSArchitecture      : x64
            SystemArchitecture  : x64
            PhysicalMemoryTotal : 12.0 GB
            PhysicalMemoryFree  : 621.7 MB
            VirtualMemoryTotal  : 24.0 GB
            VirtualMemoryFree   : 5.7 GB
            CPUCores            : 24
            CPUSockets          : 2
            SystemTime          : 08/04/2013 20:33:47
            LastBootTime        : 07/16/2013 07:42:01
            InstallDate         : 07/02/2011 17:52:34
            Uptime              : 19 days 12 hours 51 minutes
     
       Description
       -----------
       Query and display basic information ablout computer test1

    .EXAMPLE
       PS > $cred = Get-Credential
       PS > $b = Get-ComputerAssetInformation -ComputerName 73.147.113.236 -Credential $cred -IncludeMemoryInfo 
       PS > $b | Select MemorySlotsTotal,MemorySlotsUsed | fl

       MemorySlotsTotal : 18
       MemorySlotsUsed  : 6
       
       PS > $b._Memory | Select DeviceLocator,@{n='MemorySize'; e={$_.Capacity/1Gb}}

       DeviceLocator                                                                   MemorySize
       -------------                                                                   ----------
       PROC 1 DIMM 3A                                                                           2
       PROC 1 DIMM 6B                                                                           2
       PROC 1 DIMM 9C                                                                           2
       PROC 2 DIMM 3A                                                                           2
       PROC 2 DIMM 6B                                                                           2
       PROC 2 DIMM 9C                                                                           2
       
       Description
       -----------
       Query information about computer test1 using alternate credentials, including detailed memory information. Return
       physical memory slots available and in use. Then display the memory location and size.
    .EXAMPLE
        PS > $a = Get-ComputerAssetInformation -IncludeDiskInfo -IncludeMemoryInfo -IncludeNetworkInfo
        PS > $a._MemorySlots | ft

        Label      Bank        Detail           FormFactor      Capacity
        -----      ----        ------           ----------      --------
        BANK 0     Bank 1      Synchronous      SODIMM              4096
        BANK 2     Bank 2      Synchronous      SODIMM              4096
        
       Description
       -----------
       Query local computer for all information, store the results in $a, then show the memory slot utilization in further
       detail in tabular form.
    .EXAMPLE
        PS > (Get-ComputerAssetInformation -IncludeDiskInfo)._Disks

        Drive            : C:
        DiskType         : Partition
        Description      : Installable File System
        VolumeName       : 
        PercentageFree   : 10.64
        Disk             : \\.\PHYSICALDRIVE0
        SerialNumber     :       0SGDENZA091227
        FreeSpace        : 6.3 GB
        PrimaryPartition : True
        DiskSize         : 59.6 GB
        Model            : SAMSUNG SSD PM800 TH 64G
        Partition        : Disk #0, Partition #0

        Description
        -----------
        Query information about computer, include disk information, and immediately display it.

       Originally posted at: http://learn-powershell.net/2013/05/08/scripting-games-2013-event-2-favorite-and-not-so-favorite/
       Props To: David Lee (www.linkedin.com/pub/david-lee/2/686/482/) - Helped to troubleshoot and resolve numerous aspects of this script
       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0
       Info: WMI prefered over CIM as there no speed advantage using cimsessions in multithreading against old systems. Starting
             around line 263 you can modify the WMI_<Property>Props arrays to include extra wmi data for each element should you
             require information I may have missed. You can also change the default display properties by modifying $defaultProperties.
             Keep in mind that including extra elements like the drive space and network information will increase the processing time per
             system. You may need to increase the timeout parameter accordingly.
       
       1.2.1 - 9/09/2013
        - Fixed a regression bug for os and system architecture detection (based on processor addresslength and width)       
       1.2.0 - 9/05/2013
        - Got rid of the embedded add-member scriptblock for converting to kb/mb/gb format in
          favor of a filter. This results in string object proeprties being returned instead
          of uint64 which can cause bizzare issues with excel when importing data.
       1.1.8 - 8/30/2013
        - Included the system serial number in the default general results
       1.1.7 - 8/29/2013
        - Fixed incorrect installdate in general information
        - Prefixed all warnings and verbose messages with function specific verbage
        - Forced STA apartement state before opening a runspace
        - Added memory speed to Memory section
       1.1.6 - 8/19/2013
        - Refactored the date/time calculations to be less region specific.
        - Added PercentPhysicalMemoryUsed to general info section
       1.1.5 - 8/16/2013
        - Fixed minor powershell 2.0 compatibility issue with empty array detection in the mountpoint calculation area.
       1.1.4 - 8/15/2013
        - Fixed cpu architecture determination logic (again).
        - Included _MemorySlots in the memory results option. This includes an array of objects describing the memory
          array, which slots are utilized, and what type of ram is utilizing them.
        - Added RAM lookup tables for memory model and  details.
       1.1.3 - 8/13/2013
        - Fixed improper variable assignment for virtual platform detection
        - Changed network connection results to simply include all adapters, connected or not and include a new derived property called 
          'ConnectionStatus'. This fixes a backwards compatibility issue with pre-2008 servers  and network detection.
        - Added nic promiscuous mode detection for adapters. 
            (http://praetorianprefect.com/archives/2009/09/whos-being-promiscuous-in-your-active-directory/)
       1.1.2 - 8/12/2013
        - Fixed a backward compatibility bug with SystemArchitecture and OSArchitecture properties
        - Added the actual network adapter display name to the _Network results.
        - Added another example in the comment based help   
       1.1.1 - 8/7/2013
        - Added wmi BIOS information to results (as _BIOS)
        - Added IsVirtual and VirtualType to default result properties
       1.1.0 - 8/3/2013
        - Added several parameters
        - Removed parameter sets in favor of arrays of custom object as note properties
        - Removed ICMP response requirements
        - Included more verbose runspace logging    
       1.0.2 - 8/2/2013
        - Split out system and OS architecture (changing how each it determined)
       1.0.1 - 8/1/2013
        - Updated to include several more bits of information and customization variables
       1.0.0 - ???
        - Discovered original script on the internet and totally was blown away at how awesome it is.
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter()]
        [switch]
        $IncludeMemoryInfo,
 
        [Parameter()]
        [switch]
        $IncludeDiskInfo,
 
        [Parameter()]
        [switch]
        $IncludeNetworkInfo,
       
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter()]
        [switch]
        $ShowProgress,
        
        [Parameter()]
        [switch]
        $PromptForCredential,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Asset Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Asset Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Asset Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Asset Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Asset Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Asset Information: Defining background runspaces scriptblock'
        $ScriptBlock = 
        {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
          
                [Parameter()]
                [switch]
                $IncludeMemoryInfo,
         
                [Parameter()]
                [switch]
                $IncludeDiskInfo,
         
                [Parameter()]
                [switch]
                $IncludeNetworkInfo
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                Filter ConvertTo-KMG 
                {
                     <#
                     .Synopsis
                      Converts byte counts to Byte\KB\MB\GB\TB\PB format
                     .DESCRIPTION
                      Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
                      with decimal precision of 2
                     .EXAMPLE
                     3000 | convertto-kmg
                     #>

                     $bytecount = $_
                        switch ([math]::truncate([math]::log($bytecount,1024))) 
                        {
                            0 {"$bytecount Bytes"}
                            1 {"{0:n2} KB" -f ($bytecount / 1kb)}
                            2 {"{0:n2} MB" -f ($bytecount / 1mb)}
                            3 {"{0:n2} GB" -f ($bytecount / 1gb)}
                            4 {"{0:n2} TB" -f ($bytecount / 1tb)}
                            Default {"{0:n2} PB" -f ($bytecount / 1pb)}
                        }
                }

                #region GeneralInfo
                Write-Verbose -Message ('Remote Asset Information: Runspace {0}: General asset information' -f $ComputerName)
                ## Lookup arrays
                $SKUs   = @("Undefined","Ultimate Edition","Home Basic Edition","Home Basic Premium Edition","Enterprise Edition",`
                            "Home Basic N Edition","Business Edition","Standard Server Edition","DatacenterServer Edition","Small Business Server Edition",`
                            "Enterprise Server Edition","Starter Edition","Datacenter Server Core Edition","Standard Server Core Edition",`
                            "Enterprise ServerCoreEdition","Enterprise Server Edition for Itanium-Based Systems","Business N Edition","Web Server Edition",`
                            "Cluster Server Edition","Home Server Edition","Storage Express Server Edition","Storage Standard Server Edition",`
                            "Storage Workgroup Server Edition","Storage Enterprise Server Edition","Server For Small Business Edition","Small Business Server Premium Edition")
                $ChassisModels = @("PlaceHolder","Maybe Virtual Machine","Unknown","Desktop","Thin Desktop","Pizza Box","Mini Tower","Full Tower","Portable",`
                                   "Laptop","Notebook","Hand Held","Docking Station","All in One","Sub Notebook","Space-Saving","Lunch Box","Main System Chassis",`
                                   "Lunch Box","SubChassis","Bus Expansion Chassis","Peripheral Chassis","Storage Chassis" ,"Rack Mount Unit","Sealed-Case PC")
                $NetConnectionStatus = @('Disconnected','Connecting','Connected','Disconnecting','Hardware not present','Hardware disabled','Hardware malfunction',`
                                         'Media disconnected','Authenticating','Authentication succeeded','Authentication failed','Invalid address','Credentials required')
                $MemoryModels = @("Unknown","Other","SIP","DIP","ZIP","SOJ","Proprietary","SIMM","DIMM","TSOP","PGA","RIMM",`
                                  "SODIMM","SRIMM","SMD","SSMP","QFP","TQFP","SOIC","LCC","PLCC","BGA","FPBGA","LGA")
                $MemoryDetail = @{
                    '1' = 'Reserved'
                    '2' = 'Other'
                    '4' = 'Unknown'
                    '8' = 'Fast-paged'
                    '16' = 'Static column'
                    '32' = 'Pseudo-static'
                    '64' = 'RAMBUS'
                    '128' = 'Synchronous'
                    '256' = 'CMOS'
                    '512' = 'EDO'
                    '1024' = 'Window DRAM'
                    '2048' = 'Cache DRAM'
                    '4096' = 'Nonvolatile'
                }

                # Modify this variable to change your default set of display properties
                $defaultProperties = @('ComputerName','IsVirtual','Model','ChassisModel','SerialNumber','OperatingSystem','OSServicePack','OSVersion','OSSKU', `
                                       'OSArchitecture','SystemArchitecture','PhysicalMemoryTotal','PhysicalMemoryFree','VirtualMemoryTotal', `
                                       'VirtualMemoryFree','CPUCores','CPUSockets','SystemTime','LastBootTime','InstallDate','Uptime')
                # WMI Properties
                $WMI_OSProps = @('BuildNumber','Version','SerialNumber','ServicePackMajorVersion','CSDVersion','SystemDrive',`
                                 'SystemDirectory','WindowsDirectory','Caption','TotalVisibleMemorySize','FreePhysicalMemory',`
                                 'TotalVirtualMemorySize','FreeVirtualMemory','OSArchitecture','Organization','LocalDateTime',`
                                 'RegisteredUser','OperatingSystemSKU','OSType','LastBootUpTime','InstallDate')
                $WMI_ProcProps = @('Name','Description','MaxClockSpeed','CurrentClockSpeed','AddressWidth','NumberOfCores','NumberOfLogicalProcessors', `
                                   'DataWidth')
                $WMI_CompProps = @('DNSHostName','Domain','Manufacturer','Model','NumberOfLogicalProcessors','NumberOfProcessors','PrimaryOwnerContact', `
                                   'PrimaryOwnerName','TotalPhysicalMemory','UserName')
                $WMI_ChassisProps = @('ChassisTypes','Manufacturer','SerialNumber','Tag','SKU')
                $WMI_BIOSProps = @('Version','SerialNumber')
                
                # WMI data
                $wmi_compsystem = Get-WmiObject @WMIHast -Class Win32_ComputerSystem | select $WMI_CompProps
                $wmi_os = Get-WmiObject @WMIHast -Class Win32_OperatingSystem | select $WMI_OSProps
                $wmi_proc = Get-WmiObject @WMIHast -Class Win32_Processor | select $WMI_ProcProps
                $wmi_chassis = Get-WmiObject @WMIHast -Class Win32_SystemEnclosure | select $WMI_ChassisProps
                $wmi_bios = Get-WmiObject @WMIHast -Class Win32_BIOS | select $WMI_BIOSProps

                ## Calculated properties
                # CPU count
                if (@($wmi_proc)[0].NumberOfCores) #Modern OS
                {
                    $Sockets = @($wmi_proc).Count
                    $Cores = ($wmi_proc | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
                    $OSArchitecture = "x" + $(@($wmi_proc)[0]).AddressWidth
                    $SystemArchitecture = "x" + $(@($wmi_proc)[0]).DataWidth
                }
                else #Legacy OS
                {
                    $Sockets = @($wmi_proc | Select-Object -Property SocketDesignation -Unique).Count
                    $Cores = @($wmi_proc).Count
                    $OSArchitecture = "x" + ($wmi_proc | Select-Object -First 1 -Property AddressWidth).AddressWidth
                    $SystemArchitecture = "x" + ($wmi_proc | Select-Object -First 1 -Property DataWidth).DataWidth
                }
                
                # OperatingSystemSKU is not availble in 2003 and XP
                if ($wmi_os.OperatingSystemSKU -ne $null)
                {
                    $OS_SKU = $SKUs[$wmi_os.OperatingSystemSKU]
                }
                else
                {
                    $OS_SKU = 'Not Available'
                }
               
                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.LocalDateTime)
                $System_Time = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"

                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.LastBootUptime)
                $OS_LastBoot = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"
                
                $temptime = ([wmi]'').ConvertToDateTime($wmi_os.InstallDate)
                $OS_InstallDate = "$($temptime.ToShortDateString()) $($temptime.ToShortTimeString())"
                
                $Uptime = New-TimeSpan -Start $OS_LastBoot -End $System_Time
                $IsVirtual = $false
                $VirtualType = ''
                if ($wmi_bios.Version -match "VIRTUAL") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Hyper-V"
                }
                elseif ($wmi_bios.Version -match "A M I") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Virtual PC"
                }
                elseif ($wmi_bios.Version -like "*Xen*") 
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Xen"
                }
                elseif ($wmi_bios.SerialNumber -like "*VMware*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - VMWare"
                }
                elseif ($wmi_compsystem.manufacturer -like "*Microsoft*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - Hyper-V"
                }
                elseif ($wmi_compsystem.manufacturer -like "*VMWare*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Virtual - VMWare"
                }
                elseif ($wmi_compsystem.model -like "*Virtual*")
                {
                    $IsVirtual = $true
                    $VirtualType = "Unknown Virtual Machine"
                }
                $ResultProperty = @{
                    ### Defaults
                    'PSComputerName' = $ComputerName
                    'IsVirtual' = $IsVirtual
                    'VirtualType' = $VirtualType 
                    'Model' = $wmi_compsystem.Model
                    'ChassisModel' = $ChassisModels[$wmi_chassis.ChassisTypes[0]]
                    'SerialNumber' = $wmi_bios.SerialNumber
                    'ComputerName' = $wmi_compsystem.DNSHostName                        
                    'OperatingSystem' = $wmi_os.Caption
                    'OSServicePack' = $wmi_os.ServicePackMajorVersion
                    'OSVersion' = $wmi_os.Version
                    'OSSKU' = $OS_SKU
                    'OSArchitecture' = $OSArchitecture
                    'SystemArchitecture' = $SystemArchitecture
                    'PercentPhysicalMemoryUsed' = [math]::round(((($wmi_os.TotalVisibleMemorySize - $wmi_os.FreePhysicalMemory)/$wmi_os.TotalVisibleMemorySize) * 100),2)
                    'PhysicalMemoryTotal' = ($wmi_os.TotalVisibleMemorySize * 1024) | ConvertTo-KMG
                    'PhysicalMemoryFree' = ($wmi_os.FreePhysicalMemory * 1024) | ConvertTo-KMG
                    'VirtualMemoryTotal' = ($wmi_os.TotalVirtualMemorySize * 1024) | ConvertTo-KMG
                    'VirtualMemoryFree' = ($wmi_os.FreeVirtualMemory * 1024) | ConvertTo-KMG
                    'CPUCores' = $Cores
                    'CPUSockets' = $Sockets
                    'LastBootTime' = $OS_LastBoot
                    'InstallDate' = $OS_InstallDate
                    'SystemTime' = $System_Time
                    'Uptime' = "$($Uptime.days) days $($Uptime.hours) hours $($Uptime.minutes) minutes"
                    '_BIOS' = $wmi_bios
                    '_OS' = $wmi_os
                    '_System' = $wmi_compsystem
                    '_Processor' = $wmi_proc
                    '_Chassis' = $wmi_chassis
                }
                #endregion GeneralInfo
                
                #region Memory
                if ($IncludeMemoryInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Memory information' -f $ComputerName)
                    $WMI_MemProps = @('BankLabel','DeviceLocator','Capacity','PartNumber','Speed','Tag','FormFactor','TypeDetail')
                    $WMI_MemArrayProps = @('Tag','MemoryDevices','MaxCapacity')
                    $wmi_memory = Get-WmiObject @WMIHast -Class Win32_PhysicalMemory | select $WMI_MemProps
                    $wmi_memoryarray = Get-WmiObject @WMIHast -Class Win32_PhysicalMemoryArray | select $WMI_MemArrayProps
                    
                    # Memory Calcs
                    $Memory_Slotstotal = 0
                    $Memory_SlotsUsed = (@($wmi_memory)).Count                
                    @($wmi_memoryarray) | % {$Memory_Slotstotal = $Memory_Slotstotal + $_.MemoryDevices}
                    
                    # Add to the existing property set
                    $ResultProperty.MemorySlotsTotal = $Memory_Slotstotal
                    $ResultProperty.MemorySlotsUsed = $Memory_SlotsUsed
                    $ResultProperty._MemoryArray = $wmi_memoryarray
                    $ResultProperty._Memory = $wmi_memory
                    
                    # Add a few of these properties to our default property set
                    $defaultProperties += 'MemorySlotsTotal'
                    $defaultProperties += 'MemorySlotsUsed'
                    
                    # Add a more detailed memory slot utilization object array (cause I'm nice)
                    $membankcounter = 1
                    $MemorySlotOutput = @()
                    foreach ($obj1 in $wmi_memoryarray)
                    {
                        $slots = $obj1.MemoryDevices + 1
                            
                        foreach ($obj2 in $wmi_memory)
                        {
                            if($obj2.BankLabel -eq "")
                            {
                                $MemLabel = $obj2.DeviceLocator
                            }
                            else
                            {
                                $MemLabel = $obj2.BankLabel
                            }       
                            $slotprops = @{
                                'Bank' = "Bank " + $membankcounter
                                'Label' = $MemLabel
                                'Capacity' = $obj2.Capacity/1024/1024
                                'Speed' = $obj2.Speed
                                'FormFactor' = $MemoryModels[$obj2.FormFactor]
                                'Detail' = $MemoryDetail[[string]$obj2.TypeDetail]
                            }
                            $MemorySlotOutput += New-Object PSObject -Property $slotprops
                            $membankcounter = $membankcounter + 1
                        }
                        while($membankcounter -lt $slots)
                        {
                            $slotprops = @{
                                'Bank' = "Bank " + $membankcounter
                                'Label' = "EMPTY"
                                'Capacity' = ''
                                'Speed' = ''
                                'FormFactor' = "EMPTY"
                                'Detail' = "EMPTY"
                            }
                            $MemorySlotOutput += New-Object PSObject -Property $slotprops
                            $membankcounter = $membankcounter + 1
                        }
                    }
                    $ResultProperty._MemorySlots = $MemorySlotOutput
                }
                #endregion Memory
                
                #region Network
                if ($IncludeNetworkInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Network information' -f $ComputerName)
                    $wmi_netadapters = Get-WmiObject @WMIHast -Class Win32_NetworkAdapter
                    $alladapters = @()
                    ForEach ($adapter in $wmi_netadapters)
                    {  
                        $wmi_netconfig = Get-WmiObject @WMIHast -Class Win32_NetworkAdapterConfiguration `
                                                                -Filter "Index = '$($Adapter.Index)'"
                        $wmi_promisc = Get-WmiObject @WMIHast -Class MSNdis_CurrentPacketFilter `
                                                              -Namespace 'root\WMI' `
                                                              -Filter "InstanceName = '$($Adapter.Name)'"
                        $promisc = $False
                        if ($wmi_promisc.NdisCurrentPacketFilter -band 0x00000020)
                        {
                            $promisc = $True
                        }
                        
                        $NetConStat = ''
                        if ($adapter.NetConnectionStatus -ne $null)
                        {
                            $NetConStat = $NetConnectionStatus[$adapter.NetConnectionStatus]
                        }
                        $alladapters += New-Object PSObject -Property @{
                              NetworkName = $adapter.NetConnectionID
                              AdapterName = $adapter.Name
                              ConnectionStatus = $NetConStat
                              Index = $wmi_netconfig.Index
                              IpAddress = $wmi_netconfig.IpAddress
                              IpSubnet = $wmi_netconfig.IpSubnet
                              MACAddress = $wmi_netconfig.MACAddress
                              DefaultIPGateway = $wmi_netconfig.DefaultIPGateway
                              Description = $wmi_netconfig.Description
                              InterfaceIndex = $wmi_netconfig.InterfaceIndex
                              DHCPEnabled = $wmi_netconfig.DHCPEnabled
                              DHCPServer = $wmi_netconfig.DHCPServer
                              DNSDomain = $wmi_netconfig.DNSDomain
                              DNSDomainSuffixSearchOrder = $wmi_netconfig.DNSDomainSuffixSearchOrder
                              DomainDNSRegistrationEnabled = $wmi_netconfig.DomainDNSRegistrationEnabled
                              WinsPrimaryServer = $wmi_netconfig.WinsPrimaryServer
                              WinsSecondaryServer = $wmi_netconfig.WinsSecondaryServer
                              PromiscuousMode = $promisc
                       }
                    }
                    $ResultProperty._Network = $alladapters
                }                    
                #endregion Network
                
                #region Disk
                if ($IncludeDiskInfo)
                {
                    Write-Verbose -Message ('Remote Asset Information: Runspace {0}: Disk information' -f $ComputerName)
                    $WMI_DiskPartProps    = @('DiskIndex','Index','Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber')
                    $WMI_DiskVolProps     = @('Name','DriveLetter','Caption','Capacity','FreeSpace','SerialNumber')
                    $WMI_DiskMountProps   = @('Name','Label','Caption','Capacity','FreeSpace','Compressed','PageFilePresent','SerialNumber')
                    
                    # WMI data
                    $wmi_diskdrives = Get-WmiObject @WMIHast -Class Win32_DiskDrive | select $WMI_DiskDriveProps
                    $wmi_mountpoints = Get-WmiObject @WMIHast -Class Win32_Volume -Filter "DriveType=3 AND DriveLetter IS NULL" | select $WMI_DiskMountProps
                    
                    $AllDisks = @()
                    foreach ($diskdrive in $wmi_diskdrives) 
                    {
                        $partitionquery = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($diskdrive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
                        $partitions = @(Get-WmiObject @WMIHast -Query $partitionquery)
                        foreach ($partition in $partitions)
                        {
                            $logicaldiskquery = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
                            $logicaldisks = @(Get-WmiObject @WMIHast -Query $logicaldiskquery)
                            foreach ($logicaldisk in $logicaldisks)
                            {
                               $diskprops = @{
                                               Disk = $diskdrive.Name
                                               Model = $diskdrive.Model
                                               Partition = $partition.Name
                                               Description = $partition.Description
                                               PrimaryPartition = $partition.PrimaryPartition
                                               VolumeName = $logicaldisk.VolumeName
                                               Drive = $logicaldisk.Name
                                               DiskSize = $logicaldisk.Size | ConvertTo-KMG
                                               FreeSpace = $logicaldisk.FreeSpace | ConvertTo-KMG
                                               PercentageFree = [math]::round((($logicaldisk.FreeSpace/$logicaldisk.Size)*100), 2)
                                               DiskType = 'Partition'
                                               SerialNumber = $diskdrive.SerialNumber
                                             }
                                $AllDisks += New-Object psobject -Property $diskprops
                            }
                        }
                    }
                    # Mountpoints are wierd so we do them seperate.
                    if ($wmi_mountpoints)
                    {
                        foreach ($mountpoint in $wmi_mountpoints)
                        {                    
                            $diskprops = @{
                                   Disk = $mountpoint.Name
                                   Model = ''
                                   Partition = ''
                                   Description = $mountpoint.Caption
                                   PrimaryPartition = ''
                                   VolumeName = ''
                                   VolumeSerialNumber = ''
                                   Drive = [Regex]::Match($mountpoint.Caption, "^.:\\").Value
                                   DiskSize = $mountpoint.Capacity  | ConvertTo-KMG
                                   FreeSpace = $mountpoint.FreeSpace  | ConvertTo-KMG
                                   PercentageFree = [math]::round((($mountpoint.FreeSpace/$mountpoint.Capacity)*100), 2)
                                   DiskType = 'MountPoint'
                                   SerialNumber = $mountpoint.SerialNumber
                                 }
                            $AllDisks += New-Object psobject -Property $diskprops
                        }
                    }
                    $ResultProperty._Disks = $AllDisks
                }
                #endregion Disk
                
                # Final output
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty

                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.Asset.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Remote Asset Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Asset Information: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Asset Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Asset Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Asset Information: Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('IncludeMemoryInfo',$IncludeMemoryInfo)
            $null = $psCMD.AddParameter('IncludeDiskInfo',$IncludeDiskInfo)
            $null = $psCMD.AddParameter('IncludeNetworkInfo',$IncludeNetworkInfo)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)               # Passthrough the hidden verbose option so write-verbose works within the runspaces
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Asset Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
                })
           Get-Result
        }
    }
 
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Asset Information: Getting asset info' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Asset Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-HPServerHealth
{
    <#
    .SYNOPSIS
       Get HP server hardware health status information from WBEM wmi providers.
    .DESCRIPTION
       Get HP server hardware health status information from WBEM wmi providers. Results returned are the overall
       health status of the server by default. Optionally further health information about several individual
       components can be queries and returned as well.
    .PARAMETER ComputerName
       Specifies the target computer or computers for data query.
    .PARAMETER IncludePSUHealth
    .PARAMETER IncludeTempSensors
    .PARAMETER IncludeEthernetTeamHealth
    .PARAMETER IncludeFanHealth
    .PARAMETER IncludeEthernetHealth
    .PARAMETER IncludeHBAHealth
    .PARAMETER IncludeArrayControllerHealth
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .PARAMETER PromptForCredential
       Prompt for remote system credential prior to processing request.
    .PARAMETER Credential
       Accept alternate credential (ignored if the localhost is processed)
    .EXAMPLE
       PS> $cred = get-credential
       PS> Get-HPServerHealth -ComputerName '157.154.251.126' -Credential $cred
       
            ComputerName                       Manufacturer           HealthState
            ------------                       ------------           -----------
            TestServer                         HP                     OK       
            
       Description
       -----------
       Attempts to retrieve overall health status of TestServer.

    .EXAMPLE
       PS> $cred = get-credential
       PS> $c = Get-HPServerhealth -ComputerName '157.154.251.126' -Credential $cred 
                                   -IncludeEthernetTeamHealth 
                                   -IncludeArrayControllerHealth 
                                   -IncludeEthernetHealth 
                                   -IncludeFanHealth 
                                   -IncludeHBAHealth 
                                   -IncludePSUHealth 
                                   -IncludeTempSensors
        
       PS> $c._TempSensors | select Name, Description, PercentToCritical

        Name                         Description                                                   PercentToCritical
        ----                         -----------                                                   -----------------
        Temperature Sensor 1         Temperature Sensor 1 detects for Ambient / External /...                  41.46
        Temperature Sensor 2         Temperature Sensor 2 detects for CPU board                                48.78
        Temperature Sensor 3         Temperature Sensor 3 detects for CPU board                                48.78
        Temperature Sensor 4         Temperature Sensor 4 detects for Memory board                             29.89
        Temperature Sensor 5         Temperature Sensor 5 detects for Memory board                             28.74
        Temperature Sensor 6         Temperature Sensor 6 detects for Memory board                             32.18
        Temperature Sensor 7         Temperature Sensor 7 detects for Memory board                             33.33
        Temperature Sensor 8         Temperature Sensor 8 detects for Power Supply Bays                        42.22
        Temperature Sensor 9         Temperature Sensor 9 detects for Power Supply Bays                        47.69
        Temperature Sensor 10        Temperature Sensor 10 detects for System board                            46.67
        Temperature Sensor 11        Temperature Sensor 11 detects for System board                            38.57
        Temperature Sensor 12        Temperature Sensor 12 detects for System board                            41.11
        Temperature Sensor 13        Temperature Sensor 13 detects for I/O board                               41.43
        Temperature Sensor 14        Temperature Sensor 14 detects for I/O board                               48.57
        Temperature Sensor 15        Temperature Sensor 15 detects for I/O board                               44.29
        Temperature Sensor 19        Temperature Sensor 19 detects for System board                               30
        Temperature Sensor 20        Temperature Sensor 20 detects for System board                            38.57
        Temperature Sensor 21        Temperature Sensor 21 detects for System board                            33.75
        Temperature Sensor 22        Temperature Sensor 22 detects for System board                            33.75
        Temperature Sensor 23        Temperature Sensor 23 detects for System board                            45.45
        Temperature Sensor 24        Temperature Sensor 24 detects for System board                               40
        Temperature Sensor 25        Temperature Sensor 25 detects for System board                               40
        Temperature Sensor 26        Temperature Sensor 26 detects for System board                               40
        Temperature Sensor 29        Temperature Sensor 29 detects for Storage bays                            58.33
        Temperature Sensor 30        Temperature Sensor 30 detects for System board                            60.91
       Description
       -----------
       Gathers all HP health information about TestServer using an alternate credential. Displays the temperature
       sensor information.

       For obvious reasons, you will need to have the HP WBEM software installed on the server.
       
       WBEM Provider Download:
       http://h18004.www1.hp.com/products/servers/management/wbem/providerdownloads.html
       
       If you are troubleshooting this function your best bet is to use the hidden verbose option 
       
       1.0.1 - 8/28/2013
        - Added differentiation between array system and controller health
       1.0.0 - 8/22/2013
        - Initial Release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,
                   HelpMessage="Computer or array of computer names to process")]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Include power supply health results")]
        [switch]
        $IncludePSUHealth,
  
        [Parameter(HelpMessage="Include temperature sensor results")]
        [switch]
        $IncludeTempSensors,
 
        [Parameter(HelpMessage="Include ethernet team health results")]
        [switch]
        $IncludeEthernetTeamHealth,

        [Parameter(HelpMessage="Include fan health results")]
        [switch]
        $IncludeFanHealth,

        [Parameter(HelpMessage="Include ethernet adapter health results")]
        [switch]
        $IncludeEthernetHealth,
        
        [Parameter(HelpMessage="Include HBA health results")]
        [switch]
        $IncludeHBAHealth,
        
        [Parameter(HelpMessage="Include array controller health results")]
        [switch]
        $IncludeArrayControllerHealth,
       
        [Parameter(HelpMessage="Maximum amount of runspaces")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout in seconds for each runspace before it gives up")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display visual progress bar")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'HP Server Health: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'HP Server Health: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'HP Server Health: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "HP Server Health: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'HP Server Health: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'HP Server Health: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [switch]
                $IncludePSUHealth,
          
                [Parameter()]
                [switch]
                $IncludeTempSensors,
         
                [Parameter()]
                [switch]
                $IncludeEthernetTeamHealth,

                [Parameter()]
                [switch]
                $IncludeFanHealth,
 
                [Parameter()]
                [switch]
                $IncludeEthernetHealth,
                
                [Parameter()]
                [switch]
                $IncludeHBAHealth,
                
                [Parameter()]
                [switch]
                $IncludeArrayControllerHealth
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('HP Server Health: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                #region Lookup arrays
                $BatteryStatus=@{
                    '1'="OK"
                    '2'="Degraded"
                    '3'="Not Fully Charged"
                    '4'="Not Present"
                    }
                $OperationalStatus=@{
                    '0'="Unknown"
                    '2'="OK"
                    '3'="Degraded"
                    '6'="Error"
                    } 
                $HealthStatus=@{
                    '0'="Unknown"
                    '5'="OK"
                    '10'="Degraded"
                    '15'="Minor"
                    '20'="Major"
                    '25'="Critical"
                    '30'="Non-Recoverable"
                    }
                $TeamStatus=@{
                    '0'="Unknown"
                    '2'="OK"
                    '3'="Degraded"
                    '4'="Redundancy Lost"
                    '5'="Overall Failure"
                    }
                $FanRemovalConditions=@{
                    '3'="Removable when off"
                    '4'="Removable when on or off"
                    }
                $EthernetPortType = @{
                    "0" =   "Unknown"
                    "1" =   "Other"
                    "50" =  "10BaseT"
                    "51" =  "10-100BaseT"
                    "52" =  "100BaseT"
                    "53" =  "1000BaseT"
                    "54" =  "2500BaseT"
                    "55" =  "10GBaseT"
                    "56" =  "10GBase-CX4"
                    "100" = "100Base-FX"
                    "101" = "100Base-SX"
                    "102" = "1000Base-SX"
                    "103" = "1000Base-LX"
                    "104" = "1000Base-CX"
                    "105" = "10GBase-SR"
                    "106" = "10GBase-SW"
                    "107" = "10GBase-LX4"
                    "108" = "10GBase-LR"
                    "109" = "10GBase-LW"
                    "110" = "10GBase-ER"
                    "111" = "10GBase-EW"
                }
                # Get this definition from hp_sensor.mof
                $PSUType = @("Unknown","Other","System board","Host System board","I/O board","CPU board", `
                             "Memory board","Storage bays","Removable Media Bays","Power Supply Bays", `
                             "Ambient / External / Room","Chassis","Bridge Card","Management board",`
                             "Remote Management Card","Generic Backplane","Infrastructure Network", `
                             "Blade Slot in Chassis/Infrastructure","Compute Cabinet Bulk Power Supply",`
                             "Compute Cabinet System Backplane Power Supply",`
                             "Compute Cabinet I/O chassis enclosure Power Supply",`
                             "Compute Cabinet AC Input Line","I/O Expansion Cabinet Bulk Power Supply",`
                             "I/O Expansion Cabinet System Backplane Power Supply",`
                             "I/O Expansion Cabinet I/O chassis enclosure Power Supply",
                             "I/O Expansion Cabinet AC Input Line","Peripheral Bay","Device Bay","Switch")
                $SensorType = @("Unknown","Other","System board","Host System board","I/O board","CPU board",`
                                "Memory board","Storage bays","Removable Media Bays","Power Supply Bays",`
                                "Ambient / External / Room","Chassis","Bridge Card","Management board",`
                                "Remote Management Card","Generic Backplane","Infrastructure Network",`
                                "Blade Slot in Chassis/Infrastructure","Front Panel","Back Panel","IO Bus",`
                                "Peripheral Bay","Device Bay","Switch","Software-defined")
                #endregion Lookup arrays
                
                # Change the default output properties here
                $defaultProperties = @('ComputerName','Manufacturer','HealthState')
          
                Write-Verbose -Message ('HP Server Health: Runspace {0}: Server general information' -f $ComputerName)                
                # Modify this variable to change your default set of display properties
                $WMI_CompProps = @('DNSHostName','Manufacturer')
                $wmi_compsystem = Get-WmiObject @WMIHast -Class Win32_ComputerSystem | select $WMI_CompProps
                if (($wmi_compsystem.Manufacturer -eq "HP") -or ($wmi_compsystem.Manufacturer -like "Hewlett*"))
                {
                    if (Get-WmiObject @WMIHast -Namespace 'root' -Class __NAMESPACE -filter "name='hpq'") 
                    {
                        #region HP General
                        Write-Verbose -Message ('HP Server Health: Runspace {0}: HP general health information' -f $ComputerName)
                        $WMI_HPHealthProps = @('HealthState')
                        $wmi_hphealth = Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class  HP_WinComputerSystem | 
                                        Select $WMI_HPHealthProps
                        
                        $ResultProperty = @{
                            ### Defaults
                            'PSComputerName' = $ComputerName
                            'ComputerName' = $wmi_compsystem.DNSHostName
                            'Manufacturer' = $wmi_compsystem.Manufacturer
                            'HealthState' = $Healthstatus[[string]$wmi_hphealth.HealthState]
                        }
                        #endregion HP General
                        
                        #region HP PSU
                        if ($IncludePSUHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP PSU health information' -f $ComputerName)
                            $WMI_HPPowerProps = @('ElementName','PowerSupplyType','HealthState')                
                            $wmi_hppower = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_WinPowerSupply | 
                                             Select $WMI_HPPowerProps)
                            $_PSUHealth = @()
                            foreach ($psu in $wmi_hppower)
                            {
                                $psuprop = @{
                                    'Name' = $psu.ElementName
                                    'Type' = $PSUType[[int]$psu.PowerSupplyType]
                                    'HealthState' = $HealthStatus[[string]$psu.HealthState]
                                }
                                $_PSUHealth += New-Object PSObject -Property $psuprop
                            }
                            $ResultProperty._PSUHealth = @($_PSUHealth)
                        }
                        #endregion HP PSU
                        
                        #region HP Temperature Sensors
                        if ($IncludeTempSensors)
                        {                
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP sensor information' -f $ComputerName)
                            $WMI_HPTempSensorProps = @('ElementName','SensorType','Description','CurrentReading',`
                                                   'UpperThresholdCritical')
                            $wmi_hptempsensor = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_WinNumericSensor |
                                                Select $WMI_HPTempSensorProps)
                            $_TempSensors = @()
                            foreach ($sensor in $wmi_hptempsensor)
                            {
                                $PercentCrit = 0
                                if (($sensor.CurrentReading) -and ($sensor.UpperThresholdCritical))
                                {
                                    $PercentCrit = [math]::round((($sensor.CurrentReading/$sensor.UpperThresholdCritical)*100), 2)
                                }
                                $sensorprop = @{
                                    'Name' = $sensor.ElementName
                                    'Type' = $SensorType[[int]$sensor.SensorType]
                                    'Description' = [regex]::Match($sensor.Description,"(.+)(?=\..+$)").Value
                                    'CurrentReading' = $sensor.CurrentReading
                                    'UpperThresholdCritical' = $sensor.UpperThresholdCritical
                                    'PercentToCritical' = $PercentCrit
                                }
                                $_TempSensors += New-Object PSObject -Property $sensorprop
                            }
                            $ResultProperty._TempSensors = @($_TempSensors)
                        }
                        #endregion HP Temperature Sensors              
                        
                        #region HP Ethernet Team
                        if ($IncludeEthernetTeamHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP ethernet team information' -f $ComputerName)
                            $WMI_HPEthTeamsProps = @('ElementName','Description','RedundancyStatus')
                            $wmi_ethernetteam = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_EthernetTeam |
                                                Select $WMI_HPEthTeamsProps)
                            $_EthernetTeamHealth = @()
                            foreach ($ethteam in $wmi_ethernetteam)
                            {
                                $ethteamprop = @{
                                    'Name' = $ethteam.ElementName
                                    'Description' = $ethteam.Description
                                    'RedundancyStatus' = $TeamStatus[[string]$ethteam.RedundancyStatus]
                                }
                                $_EthernetTeamHealth += New-Object PSObject -Property $ethteamprop
                            }
                            $ResultProperty._EthernetTeamHealth = @($_EthernetTeamHealth)
                        }
                        #endregion HP Ethernet Team
                        
                        #region HP Fans
                        if ($IncludeFanHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP fan information' -f $ComputerName)
                            $WMI_HPFanProps = @('ElementName','HealthState','RemovalConditions')
                            $wmi_fans = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_FanModule |
                                          Select $WMI_HPFanProps)
                            $_FanHealth = @()
                            foreach ($fan in $wmi_fans)
                            {
                                $fanprop = @{
                                    'Name' = $fan.ElementName
                                    'HealthState' = $HealthStatus[[string]$fan.HealthState]
                                    'RemovalConditions' = $FanRemovalConditions[[string]$fan.RemovalConditions]
                                }
                                $_FanHealth += New-Object PSObject -Property $fanprop
                            }
                            $ResultProperty._FanHealth = @($_FanHealth)
                        }
                        #endregion HP Fans
                        
                        #region HP Ethernet
                        if ($IncludeEthernetHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP ethernet information' -f $ComputerName)
                            $WMI_HPEthernetPortProps = @('ElementName','PortNumber','PortType','HealthState')
                            $wmi_ethernet = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_EthernetPort |
                                            Select $WMI_HPEthernetPortProps)
                            $_EthernetHealth = @()
                            foreach ($eth in $wmi_ethernet)
                            {
                                $ethprop = @{
                                    'Name' = $eth.ElementName
                                    'HealthState' = $HealthStatus[[string]$eth.HealthState]
                                    'PortType' = $EthernetPortType[[string]$eth.PortType]
                                    'PortNumber' = $eth.PortNumber
                                }
                                $_EthernetHealth += New-Object PSObject -Property $ethprop
                            }
                            $ResultProperty._EthernetHealth = @($_EthernetHealth)
                        }
                        #endregion HP Ethernet
                                        
                        #region HBA
                        if ($IncludeHBAHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP HBA information' -f $ComputerName)
                            $WMI_HPFCPortProps = @('ElementName','Manufacturer','Model','OtherIdentifyingInfo','OperationalStatus')
                            $wmi_hba = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HPFCHBA_PhysicalPackage |
                                       Select $WMI_HPFCPortProps)
                            $_HBAHealth = @()
                            foreach ($hba in $wmi_hba)
                            {
                                $hbaprop = @{
                                    'Name' = $hba.ElementName
                                    'Manufacturer' = $hba.Manufacturer
                                    'Model' = $hba.Model
                                    'OtherIdentifyingInfo' = $hba.OtherIdentifyingInfo
                                    'OperationalStatus' = $OperationalStatus[[string]$hba.OperationalStatus]
                                }
                                $_HBAHealth += New-Object PSObject -Property $hbaprop
                            }
                            $ResultProperty._HBAHealth = @($_HBAHealth)
                        }
                        #endregion HBA
                        
                        #region ArrayControllers
                        if ($IncludeArrayControllerHealth)
                        {
                            Write-Verbose -Message ('HP Server Health: Runspace {0}: HP array controller information' -f $ComputerName)
                            #$WMI_ArraySystemProps = @()
                            $WMI_ArrayCtrlProps = @('ElementName','BatteryStatus','ControllerStatus')
                            
                            $wmi_arraysystem = @(Get-WMIObject @WMIHast -Namespace 'root\hpq' -class HPSA_ArraySystem | 
                                                 Select Name,@{n='ArrayStatus';e={$_.StatusDescriptions}})
                            $_ArrayControllers = @()
                            Foreach ($array in $wmi_arraysystem)
                            {
                                $wmi_arrayctrl = @(Get-WMIObject @WMIHast `
                                                                       -Namespace 'root\hpq' `
                                                                       -class HPSA_ArrayController `
                                                                       -filter "name='$($array.Name)'")
                                $BatteryStat = ''
                                if ($wmi_arrayctrl.batterystatus)
                                {
                                    $BatteryStat = $BatteryStatus[[string]$wmi_arrayctrl.batterystatus]
                                }
                                $arrayprop = @{
                                    'ArrayName' = $wmi_arrayctrl.ElementName
                                    'BatteryStatus' = $BatteryStat
                                    'ArrayStatus' = $array.ArrayStatus
                                    'ControllerStatus' = $OperationalStatus[[string]$wmi_arrayctrl.ControllerStatus]
                                }
                                $_ArrayControllers += New-Object PSObject -Property $arrayprop
                            }
                            $ResultProperty._ArrayControllers = $_ArrayControllers
                        }
                        #endregion ArrayControllers
                    }
                    else
                    {
                        Write-Warning -Message ('HP Server Health: {0}: {1}' -f $ComputerName, 'WBEM Provider software needs to be installed')
                    }
                }
                else
                {
                    Write-Warning -Message ('HP Server Health: {0}: {1}' -f $ComputerName, 'Not determined to be HP hardware')
                }

                    # Final output
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty

                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.HPServerHealth.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject

            }
            catch
            {
                Write-Warning -Message ('HP Server Health: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('HP Server Health: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('HP Server Health: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('HP Server Health: Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('HP Server Health: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('IncludePSUHealth',$IncludePSUHealth)       
            $null = $psCMD.AddParameter('IncludeTempSensors',$IncludeTempSensors)
            $null = $psCMD.AddParameter('IncludeEthernetTeamHealth',$IncludeEthernetTeamHealth)
            $null = $psCMD.AddParameter('IncludeFanHealth',$IncludeFanHealth)
            $null = $psCMD.AddParameter('IncludeEthernetHealth',$IncludeEthernetHealth)
            $null = $psCMD.AddParameter('IncludeHBAHealth',$IncludeHBAHealth)
            $null = $psCMD.AddParameter('IncludeArrayControllerHealth',$IncludeArrayControllerHealth)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference) # Passthrough the hidden verbose option so write-verbose works within the runspaces
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('HP Server Health: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
                })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'HP Server Health: Getting HP health info' -Status 'Done' -Completed
        }
        Write-Verbose -Message "HP Server Health: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-DellServerHealth
{
    <#
    .SYNOPSIS
       Gather hardware health information specific to Dell servers.
    .DESCRIPTION
       Gather hardware health information specific to Dell servers.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ESMLogStatus
    .PARAMETER FanHealthStatus
    .PARAMETER SensorStatus
    .PARAMETER TempSensorStatus
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       #$cred = Get-Credential
       $server = '227.255.182.9'
       $a = Get-DellServerHealth -ComputerName $server `
                                 -Credential $cred `
                                 -ESMLogStatus `
                                 -FanHealthStatus `
                                 -SensorStatus `
                                 -TempSensorStatus `
                                 -verbose
       $a
       
        ComputerName : SERVER-01
        Status       : OK
        EsmLogStatus : OK
        FanStatus    : OK
        MemStatus    : OK
        Model        : PowerEdge R210 II
        ProcStatus   : OK
        TempStatus   : OK
        VoltStatus   : OK
        
       Description
       -----------
       Sonnects to SERVER-01 with alternate credentials, queries the dell WMI provider for hardware
       health information, then displays the overall hardware health. $a also includes detailed information
       in the _ESMLogs, _Fans, _Sensors, and _TempSensors properties.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/25/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Include individual fan status information.")]
        [switch]
        $FanHealthStatus,
        
        [Parameter(HelpMessage="Include individual temperature sensor status information.")]
        [switch]
        $TempSensorStatus,
        
        [Parameter(HelpMessage="Include individual sensor status information.")]
        [switch]
        $SensorStatus,
        
        [Parameter(HelpMessage="Include esm log information.")]
        [switch]
        $ESMLogStatus,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Dell Server Health: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Dell Server Health: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Dell Server Health: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Dell Server Health: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Dell Server Health: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Dell Server Health: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [switch]
                $FanHealthStatus,
                
                [Parameter()]
                [switch]
                $TempSensorStatus,
                
                [Parameter()]
                [switch]
                $SensorStatus,
                
                [Parameter()]
                [switch]
                $ESMLogStatus
            )
            $runspacetimers.$bgRunspaceID = Get-Date

            try
            {
                Write-Verbose -Message ('Dell Server Health: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $PSDateTime = Get-Date
                
                #region Data Collection
                Write-Verbose -Message ('Dell Server Health: Runspace {0}: information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Status','EsmLogStatus','FanStatus','MemStatus','Model','ProcStatus','TempStatus','VoltStatus')
                $WMI_CompProps = @('DNSHostName','Manufacturer')
                $wmi_compsystem = Get-WmiObject @WMIHast -Class Win32_ComputerSystem | select $WMI_CompProps
                if ($wmi_compsystem.Manufacturer -match "Dell")
                {
                    if (Get-WmiObject @WMIHast -Namespace 'root\CIMv2' -Class __NAMESPACE -filter "name='Dell'")
                    {
                        #region GeneralHardwareHealth
                        $HardwareStatus = Get-WmiObject @WMIHast -Namespace 'root\CIMV2\Dell' -class Dell_Chassis | 
                            Select Status,EsmLogStatus,FanStatus,MemStatus,Model,ProcStatus,TempStatus,VoltStatus
                            $ResultProperty = @{
                                'PSComputerName' = $ComputerName
                                'PSDateTime' = $PSDateTime
                                'ComputerName' = $ComputerName
                                'CustomData' = $CustomData
                                'Status' = $HardwareStatus.Status
                                'EsmLogStatus' = $HardwareStatus.EsmLogStatus
                                'FanStatus' = $HardwareStatus.FanStatus
                                'MemStatus' = $HardwareStatus.MemStatus
                                'Model' = $HardwareStatus.Model
                                'ProcStatus' = $HardwareStatus.ProcStatus
                                'TempStatus' = $HardwareStatus.TempStatus
                                'VoltStatus' = $HardwareStatus.VoltStatus
                            }
                        #endregion

                        #region FanHealth
                        if ($FanHealthStatus)
                        {
                            Write-Verbose -Message ('Dell Server Health: Runspace {0}: Del fan info' -f $ComputerName)
                            $Fans = Get-WmiObject @WMIHast -Namespace 'root\CIMV2\Dell' -class CIM_Fan | 
                                Select Name,Status
                            $_Fans = @()
                            foreach ($fan in $Fans)
                            {
                                $fanprop = @{
                                    'Name' = $fan.Name
                                    'Status' = $fan.Status
                                }
                                $_Fans += New-Object PSObject -Property $fanprop
                            }
                            $ResultProperty._Fans = @($_Fans)
                        }
                        #endregion
                        #region TempSensors
                        
                        if ($TempSensorStatus)
                        {
                            Write-Verbose -Message ('Dell Server Health: Runspace {0}: Del Temp Sensor info' -f $ComputerName)
                            $TempSensors = Get-WmiObject @WMIHast -Namespace 'root\CIMV2\Dell' -class CIM_TemperatureSensor | 
                                Select Name,Status,UpperThresholdCritical,CurrentReading
                            $_TempSensors = @()
                            foreach ($sensor in $TempSensors)
                            {
                                $PercentCrit = 0
                                if (($sensor.CurrentReading) -and ($sensor.UpperThresholdCritical))
                                {
                                    $PercentCrit = [math]::round((($sensor.CurrentReading/$sensor.UpperThresholdCritical)*100), 2)
                                }
                                $sensorprop = @{
                                    'Name' = $sensor.Name
                                    'Status' = $sensor.Status
                                    'Description' = $sensor.Description
                                    'CurrentReading' = $sensor.CurrentReading
                                    'UpperThresholdCritical' = $sensor.UpperThresholdCritical
                                    'PercentToCritical' = $PercentCrit
                                }
                                $_TempSensors += New-Object PSObject -Property $sensorprop
                            }
                            $ResultProperty._TempSensors = @($_TempSensors)
                        }
                        #endregion
                        #region Sensors
                        if ($SensorStatus)
                        {
                            Write-Verbose -Message ('Dell Server Health: Runspace {0}: Del Sensor info' -f $ComputerName)
                            $Sensors = Get-WmiObject @WMIHast -Namespace 'root\CIMV2\Dell' -class CIM_Sensor | 
                                Select Name,SensorType,OtherSensorTypeDescription,Status,CurrentReading
                            $_Sensors = @()
                            foreach ($sensor in $Sensors)
                            {
                                $sensorprop = @{
                                    'Name' = $sensor.Name
                                    'Type' = $sensor.SensorType
                                    'Description' = $sensor.OtherSensorTypeDescription
                                    'CurrentReading' = $sensor.CurrentReading
                                    'Status' = $sensor.Status
                                }
                                $_Sensors += New-Object PSObject -Property $sensorprop
                            }
                            $ResultProperty._Sensors = @($_Sensors)                                
                        }
                        #endregion
                        #region ESMLogs
                        if ($ESMLogStatus)
                        {
                            Write-Verbose -Message ('Dell Server Health: Runspace {0}: Del ESM Log info' -f $ComputerName)
                            $ESMLogs = Get-WmiObject @WMIHast -Namespace 'root\CIMV2\Dell' -class Dell_EsmLog | 
                                Select EventTime,LogRecord,RecordNumber,Status
                            $_ESMLogs = @()
                            foreach ($log in $ESMLogs)
                            {
                                $esmlogprop = @{
                                    'EventTime' = $log.EventTime
                                    'RecordNumber' = $log.RecordNumber
                                    'LogRecord' = $log.LogRecord
                                    'Status' = $log.Status
                                }
                                $_ESMLogs += New-Object PSObject -Property $esmlogprop
                            }
                            $ResultProperty._ESMLogs = @($_ESMLogs)   
                        }
                        #endregion
                    }
                    else
                    {
                        Write-Warning -Message ('Dell Server Health: {0}: WMI class not found!' -f $ComputerName)
                    }
                }
                                
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.DellHealth.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
                #endregion Data Collection
            }
            catch
            {
                Write-Warning -Message ('Dell Server Health: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Dell Server Health: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers.($runspace.ID)
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Dell Server Health: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Dell Server Health: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Dell Server Health: Getting info'
                        Status = 'Dell Server Health: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
        
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('FanHealthStatus',$FanHealthStatus)
            $null = $psCMD.AddParameter('TempSensorStatus',$TempSensorStatus)
            $null = $psCMD.AddParameter('SensorStatus',$SensorStatus)
            $null = $psCMD.AddParameter('ESMLogStatus',$ESMLogStatus)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Dell Server Health: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
     END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Dell Server Health: Getting share session information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Dell Server Health: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-MultiRunspaceWMIObject
{
    <#
    .SYNOPSIS
       Get generic wmi object data from a remote or local system.
    .DESCRIPTION
       Get wmi object data from a remote or local system. Multiple runspaces are utilized and 
       alternate credentials can be provided.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER Namespace
       Namespace to query
    .PARAMETER Class
       Class to query
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > (Get-MultiRunspaceWMIObject -Class win32_printer).WMIObjects

       <output is all your local printers>
       
       Description
       -----------
       Queries the local machine for all installed printer information and spits out what is found.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/31/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="WMI class to query",
                   Position=1)]
        [string]
        $Class,
        
        [Parameter(HelpMessage="WMI namespace to query")]
        [string]
        $NameSpace = 'root\cimv2',
        
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message ('WMI Query {0}: Creating local hostname list' -f $Class)
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message ('WMI Query {0}: Creating initial variables' -f $Class)
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message ('WMI Query {0}: Creating Initial Session State' -f $Class)
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message ("WMI Query {0}: Adding variable $ExternalVariable to initial session state" -f $Class)
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message ('WMI Query {0}: Creating runspace pool' -f $Class)
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message ('WMI Query {0}: Defining background runspaces scriptblock' -f $Class)
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter()]
                [string]
                $ComputerName,
                
                [Parameter()]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [string]
                $Class,
                
                [Parameter()]
                [string]
                $NameSpace = 'root\cimv2'
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('WMI Query {0}: Runspace {1}: Start' -f $Class,$ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                $PSDateTime = Get-Date
                
                #region WMI Data
                Write-Verbose -Message ('WMI Query {0}: Runspace {1}: WMI information' -f $Class,$ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','WMIObjects')
                                         
                # WMI data
                $wmi_data = Get-WmiObject @WMIHast -Namespace $Namespace -Class $Class

                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'WMIObjects' = $wmi_data
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.WMIObject.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                Write-Output -InputObject $ResultObject
                #endregion WMI Data
            }
            catch
            {
                Write-Warning -Message ('WMI Query {0}: {1}: {2}' -f $Class, $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('WMI Query {0}: Runspace {1}: End' -f $Class,$ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('WMI Query {0}: Thread done for {1}' -f $Class,$runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('WMI Query {0}: Timeout {1}' -f $Class,$runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('WMI Query {0}: Removing {1} from runspaces' -f $Class,$threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = ('WMI Query {0}: Getting info' -f $Class)
                        Status = 'WMI Query {0}: {1} of {2} total threads done' -f $Class,($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Class',$Class)
            $null = $psCMD.AddParameter('Namespace',$Namespace)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('WMI Query {0}: Starting {1}' -f $Class,$Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
 
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity ('WMI Query {0}: Getting wmi information' -f $Class) -Status 'Done' -Completed
        }
        Write-Verbose -Message ("WMI Query {0}: Closing runspace pool" -f $Class)
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteInstalledPrograms
{
    <#
    .SYNOPSIS
       Retrieves installed programs from remote systems via the registry.
    .DESCRIPTION
       Retrieves installed programs from remote systems via the registry.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > Get-RemoteInstalledPrograms
       
       Description
       -----------
       Lists all of the programs found in the registry of the localhost.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/28/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Maximum number of concurrent runspaces.")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a runspaces stops trying to gather the information.")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function.")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials.")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials.")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Installed Programs: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Installed Programs: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Installed Programs: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Installed Programs: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Installed Programs: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Installed Programs: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,

                [Parameter()]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Installed Programs: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }
                
                #region Installed Programs
                Write-Verbose -Message ('Remote Installed Programs: Runspace {0}: Gathering registry information' -f $ComputerName)
                $hklm = '2147483650'
                $basekey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
                $basekey64 = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
                $regkeys = @($basekey,$basekey64)                
                $Programs = @()
                
                $wmi_data = Get-WmiObject @WMIHast -Class StdRegProv -Namespace 'root\default' -List:$true
                Foreach ($basekey in $regkeys)
                {
                
                    $allsubkeys = $wmi_data.EnumKey($hklm,$basekey)
                    foreach ($subkey in $allsubkeys.sNames) 
                    {
                       # $keydata = $wmi_data.EnumValues($hklm,"$basekey\$subkey")
                        $displayname = $wmi_data.GetStringValue($hklm,"$basekey\$subkey",'DisplayName').sValue
                        if ($DisplayName)
                        {
                            $publisher = $wmi_data.GetStringValue($hklm,"$basekey\$subkey",'Publisher').sValue
                            $uninstallstring = $wmi_data.GetExpandedStringValue($hklm,"$basekey\$subkey",'UninstallString').sValue
                            $displayversion = $wmi_data.GetStringValue($hklm,"$basekey\$subkey",'DisplayVersion').sValue
                            $ProgramProperty = @{
                                'DisplayName' = $displayname
                                'Version' = $displayversion
                                'Publisher' = $publisher
                                'UninstallString' = $uninstallstring
                            }
                            $Programs += New-Object PSObject -Property $ProgramProperty
                        }
                    }
                }
                    
                If ($Programs.Count -gt 0)
                {
                    $ResultProperty = @{
                        'PSComputerName' = $ComputerName
                        'ComputerName' = $ComputerName
                        'Programs' = $Programs
                    }
                    $ResultObject = New-Object PSObject -Property $ResultProperty
                    Write-Output -InputObject $ResultObject
                }
                
            }
            catch
            {
                Write-Warning -Message ('Remote Installed Programs: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Installed Programs: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Installed Programs: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Remote Installed Programs: Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Installed Programs: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting installed programs'
                        Status = 'Remote Installed Programs: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Installed Programs: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Installed Programs: Getting program listing' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Installed Programs: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteScheduledTasks
{
    <#
    .SYNOPSIS
        Gather scheduled task information from a remote system or systems.
    .DESCRIPTION
        Gather scheduled task information from a remote system or systems. If remote credentials
        are provided PSremoting will be utilized.
    .PARAMETER ComputerName
        Specifies the target computer or computers for data query.
    .PARAMETER UseRemoting
        Override defaults and use PSRemoting. If an alternate credential is specified PSRemoting is assumed.
    .PARAMETER ThrottleLimit
        Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
        Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
        PS > (Get-RemoteScheduledTasks).Tasks | 
             Where {(!$_.Hidden) -and ($_.Enabled) -and ($_.NextRunTime -ne 'None')} | 
             Select Name,Enabled,NextRunTime,Author

        Name                     Enabled   NextRunTime               Author                       
        ----                     -------   -----------               ------                   
        Adobe Flash Player Upd...True      10/4/2013 10:24:00 PM     Adobe
       
        Description
        -----------
        Gathers all scheduled tasks then filters out all which are enabled, has a next
        run time, and is not hidden and displays the result in a table.
    .EXAMPLE
        PS > $cred = Get-Credential
        PS > $Servers = @('SERVER1','SERVER2')
        PS > $a = Get-RemoteScheduledTasks -Credential $cred -ComputerName $Servers

        Description
        -----------
        Using an alternate credential (and thus PSremoting), $a gets assigned all of the 
        scheduled tasks from SERVER1 and SERVER2.
        
        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        1.0.0 - 10/04/2013
        - Initial release
        
        Note: 
        
        I used code from a few sources to create this script;
            - http://p0w3rsh3ll.wordpress.com/2012/10/22/working-with-scheduled-tasks/
            - http://gallery.technet.microsoft.com/Get-Scheduled-tasks-from-3a377294
        
        I was unable to find several of the Task last exit codes. A good number of them
        from the following source have been included tough;
            - http://msdn.microsoft.com/en-us/library/windows/desktop/aa383604(v=vs.85).aspx
    #>
    [cmdletbinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,

        [Parameter(HelpMessage="Override defaults and use PSRemoting. If an alternate credential is specified PSRemoting is assumed.")]
        [switch]
        $UseRemoting,
        
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,

        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,

        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        $ProcessWithPSRemoting = $UseRemoting
        $ComputerNames = @()
        
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Scheduled Tasks: Creating local hostname list'
        
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Scheduled Tasks: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
            $ProcessWithPSRemoting = $true
        }
        
        Write-Verbose -Message 'Scheduled Tasks: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Scheduled Tasks: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Scheduled Tasks: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Scheduled Tasks: Defining background runspaces scriptblock'
        $ScriptBlock = 
        {
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [switch]
                $UseRemoting
            )

            $runspacetimers.$bgRunspaceID = Get-Date
            $GetScheduledTask = {
                param(
                	$computername = "localhost"
                )

                Function Get-TaskSubFolders
                {
                    param(                    	
                        [string]$folder = '\',
                        [switch]$recurse
                    )
                    $folder
                    if ($recurse)
                    {
                        $TaskService.GetFolder($folder).GetFolders(0) | 
                        ForEach-Object {
                            Get-TaskSubFolders $_.Path -Recurse
                        }
                    } 
                    else 
                    {
                        $TaskService.GetFolder($folder).GetFolders(0)
                    }
                }

                try 
                {
                	$TaskService = new-object -com("Schedule.Service") 
                    $TaskService.connect($ComputerName) 
                    $AllFolders = Get-TaskSubFolders -Recurse
                    $TaskResults = @()

                    foreach ($Folder in $AllFolders) 
                    {
                        $TaskService.GetFolder($Folder).GetTasks(1) | 
                        Foreach-Object {
                            switch ([int]$_.State)
                            {
                                0 { $State = 'Unknown'}
                                1 { $State = 'Disabled'}
                                2 { $State = 'Queued'}
                                3 { $State = 'Ready'}
                                4 { $State = 'Running'}
                                default {$State = $_ }
                            }
                            
                            switch ($_.NextRunTime) 
                            {
                                (Get-Date -Year 1899 -Month 12 -Day 30 -Minute 00 -Hour 00 -Second 00) {$NextRunTime = "None"}
                                default {$NextRunTime = $_}
                            }
                             
                            switch ($_.LastRunTime) 
                            {
                                (Get-Date -Year 1899 -Month 12 -Day 30 -Minute 00 -Hour 00 -Second 00) {$LastRunTime = "Never"}
                                default {$LastRunTime = $_}
                            } 

                            switch (([xml]$_.XML).Task.RegistrationInfo.Author)
                            {
                                '$(@%ProgramFiles%\Windows Media Player\wmpnscfg.exe,-1001)'   { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\acproxy.dll,-101)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\aepdu.dll,-701)'                     { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\aitagent.exe,-701)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\appidsvc.dll,-201)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\appidsvc.dll,-301)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\System32\AuxiliaryDisplayServices.dll,-1001)' { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\bfe.dll,-2001)'                      { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\BthUdTask.exe,-1002)'                { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\cscui.dll,-5001)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\System32\DFDTS.dll,-101)'                     { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\dimsjob.dll,-101)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\dps.dll,-600)'                       { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\drivers\tcpip.sys,-10000)'           { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\defragsvc.dll,-801)'                 { $Author = 'Microsoft Corporation'}
                                '$(@%systemRoot%\system32\energy.dll,-103)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\HotStartUserAgent.dll,-502)'         { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\kernelceip.dll,-600)'                { $Author = 'Microsoft Corporation'}
                                '$(@%systemRoot%\System32\lpremove.exe,-100)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\memdiag.dll,-230)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\mscms.dll,-201)'                     { $Author = 'Microsoft Corporation'}
                                '$(@%systemRoot%\System32\msdrm.dll,-6001)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\msra.exe,-686)'                      { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\nettrace.dll,-6911)'                 { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\osppc.dll,-200)'                     { $Author = 'Microsoft Corporation'}
                                '$(@%systemRoot%\System32\perftrack.dll,-2003)'                { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\PortableDeviceApi.dll,-102)'         { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\profsvc,-500)'                       { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\RacEngn.dll,-501)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\rasmbmgr.dll,-201)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\regidle.dll,-600)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\sdclt.exe,-2193)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\sdiagschd.dll,-101)'                 { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\sppc.dll,-200)'                      { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\srrstr.dll,-321)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\upnphost.dll,-215)'                  { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\usbceip.dll,-600)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\w32time.dll,-202)'                   { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\wdc.dll,-10041)'                     { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\wer.dll,-293)'                       { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\System32\wpcmig.dll,-301)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\System32\wpcumi.dll,-301)'                    { $Author = 'Microsoft Corporation'}
                                '$(@%systemroot%\system32\winsatapi.dll,-112)'                 { $Author = 'Microsoft Corporation'}
                                '$(@%SystemRoot%\system32\wat\WatUX.exe,-702)'                 { $Author = 'Microsoft Corporation'}
                                default {$Author = $_ }                                   
                            }
                            switch (([xml]$_.XML).Task.RegistrationInfo.Date)
                            {
                                ''      {$Created = 'Unknown'}
                                default {$Created =  Get-Date -Date $_ }                                
                            }
                            Switch (([xml]$_.XML).Task.Settings.Hidden)
                            {
                                false { $Hidden = $false}
                                true  { $Hidden = $true }
                                default { $Hidden = $false}
                            }
                            Switch (([xml]$_.xml).Task.Principals.Principal.UserID)
                            {
                                'S-1-5-18' {$userid = 'Local System'}
                                'S-1-5-19' {$userid = 'Local Service'}
                                'S-1-5-20' {$userid = 'Network Service'}
                                default    {$userid = $_ }
                            }
                            Switch ($_.lasttaskresult)
                            {
                                '0' { $LastTaskDetails = 'The operation completed successfully.' }
                                '1' { $LastTaskDetails = 'Incorrect function called or unknown function called.' }
                                '2' { $LastTaskDetails = 'File not found.' }
                                '10' { $LastTaskDetails = 'The environment is incorrect.' }
                                '267008' { $LastTaskDetails = 'Task is ready to run at its next scheduled time.' }
                                '267009' { $LastTaskDetails = 'Task is currently running.' }
                                '267010' { $LastTaskDetails = 'The task will not run at the scheduled times because it has been disabled.' }
                                '267011' { $LastTaskDetails = 'Task has not yet run.' }
                                '267012' { $LastTaskDetails = 'There are no more runs scheduled for this task.' }
                                '267013' { $LastTaskDetails = 'One or more of the properties that are needed to run this task on a schedule have not been set.' }
                                '267014' { $LastTaskDetails = 'The last run of the task was terminated by the user.' }
                                '267015' { $LastTaskDetails = 'Either the task has no triggers or the existing triggers are disabled or not set.' }
                                '2147750671' { $LastTaskDetails = 'Credentials became corrupted.' }
                                '2147750687' { $LastTaskDetails = 'An instance of this task is already running.' }
                                '2147943645' { $LastTaskDetails = 'The service is not available (is "Run only when an user is logged on" checked?).' }
                                '3221225786' { $LastTaskDetails = 'The application terminated as a result of a CTRL+C.' }
                                '3228369022' { $LastTaskDetails = 'Unknown software exception.' }
                                default    {$LastTaskDetails = $_ }
                            }
                            $TaskProps = @{
                                'Name' = $_.name
                                'Path' = $_.path
                                'State' = $State
                                'Created' = $Created
                                'Enabled' = $_.enabled
                                'Hidden' = $Hidden
                                'LastRunTime' = $LastRunTime
                                'LastTaskResult' = $_.lasttaskresult
                                'LastTaskDetails' = $LastTaskDetails
                                'NumberOfMissedRuns' = $_.numberofmissedruns
                                'NextRunTime' = $NextRunTime
                                'Author' =  $Author
                                'UserId' = $UserID
                                'Description' = ([xml]$_.xml).Task.RegistrationInfo.Description
                            }
                	        $TaskResults += New-Object PSCustomObject -Property $TaskProps
                        }
                    }
                    Write-Output -InputObject $TaskResults
                }
                catch
                {
                    Write-Warning -Message ('Scheduled Tasks: {0}: {1}' -f $ComputerName, $_.Exception.Message)
                }
            }

            try 
            {
                Write-Verbose -Message ('Scheduled Tasks: Runspace {0}: Start' -f $ComputerName)
                $RemoteSplat = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                $ProcessWithPSRemoting = $UseRemoting
                if (($LocalHost -notcontains $ComputerName) -and 
                    ($Credential -ne [System.Management.Automation.PSCredential]::Empty))
                {
                    $RemoteSplat.Credential = $Credential
                    $ProcessWithPSRemoting = $true
                }

                Write-Verbose -Message ('Scheduled Tasks: Runspace {0}: information' -f $ComputerName)
                $PSDateTime = Get-Date
                $defaultProperties    = @('ComputerName','Tasks')

            	if ($ProcessWithPSRemoting)
                {
                    Write-Verbose -Message ('Scheduled Tasks: Using PSremoting on {0}' -f $ComputerName)
                    $Results = @(Invoke-Command  @RemoteSplat `
                                                 -ScriptBlock  $GetScheduledTask `
                                                 -ArgumentList 'localhost')
                    $PSConnection = 'PSRemoting'
                }
                else
                {
                    Write-Verbose -Message ('Scheduled Tasks: Directly connecting to {0}' -f $ComputerName)
                    $Results = @(&$GetScheduledTask -ComputerName $ComputerName)
                    $PSConnection = 'Direct'
                }
                
                $ResultProperty = @{
                    'PSComputerName'= $ComputerName
                    'PSDateTime'    = $PSDateTime
                    'PSConnection'  = $PSConnection
                    'ComputerName'  = $ComputerName
                    'Tasks'         = $Results                    
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.ScheduledTask.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject
            }            
            catch
            {
                Write-Warning -Message ('Scheduled Tasks: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Scheduled Tasks: Runspace {0}: End' -f $ComputerName)
        }
        
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers.($runspace.ID)
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Scheduled Tasks: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Scheduled Tasks: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Scheduled Tasks: Getting info'
                        Status = 'Scheduled Tasks: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        $ComputerNames += $ComputerName
    }
    END
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('UseRemoting',$UseRemoting)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Scheduled Tasks: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
            })
           Get-Result
        }
        
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Scheduled Tasks: Getting share session information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Scheduled Tasks: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteInstalledPrinters
{
    <#
    .SYNOPSIS
       Gather remote printer information with multiple runspaces and wmi.
    .DESCRIPTION
       Gather remote printer information with multiple runspaces and wmi. Can provide alternate credentials if
       required.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > (Get-RemoteInstalledPrinters).Printers | Select Name,Status,CurrentJobs

        Name                                      Status                   CurrentJobs
        ----                                      ------                   -----------
        Send To OneNote 2010                      Idle                               0
        PDFCreator                                Idle                               0
        Microsoft XPS Document Writer             Idle                               0
        Foxit Reader PDF Printer                  Idle                               0
        Fax                                       Idle                               0

       
       Description
       -----------
       Get a list of locally installed printers (both network and locally attached) and show the status
       and current number of jobs in its queue.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/01/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Printers: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Printers: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Printers: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Printers: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Printers: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Printers: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $PrinterObjects = @()
                $PSDateTime = Get-Date
                
                #region Printers
                $lookup_printerstatus = @('PlaceHolder','Other','Unknown','Idle','Printing', `
                          'Warming Up','Stopped printing','Offline')
                          
                Write-Verbose -Message ('Remote Printers: Runspace {0}: Printer information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Printers')

                # WMI data
                $wmi_printers = Get-WmiObject @WMIHast -Class Win32_Printer
                foreach ($printer in $wmi_printers)
                {
                    if (($printer.Name -ne '_Total') -and ($printer.Name -notlike '\\*'))
                    {
                        $Filter = "Name='$($printer.Name)'"
                        $wmi_printerqueues = Get-WMIObject @WMIHast `
                                                           -Class Win32_PerfFormattedData_Spooler_PrintQueue `
                                                           -Filter $Filter
                        $CurrJobs = $wmi_printerqueues.Jobs
                        $TotalJobs = $wmi_printerqueues.TotalJobsPrinted
                        $TotalPages = $wmi_printerqueues.TotalPagesPrinted
                        $JobErrors = $wmi_printerqueues.JobErrors 
                    }
                    else
                    {
                        $CurrJobs = 'NA'
                        $TotalJobs = 'NA'
                        $TotalPages = 'NA'
                        $JobErrors = 'NA'
                    }
                    $PrinterProperty = @{
                        'Name' = $printer.Name
                        'Status' = $lookup_printerstatus[[int]$printer.PrinterStatus]
                        'Location' = $printer.Location
                        'Shared' = $printer.Shared
                        'ShareName' = $printer.ShareName
                        'Published' = $printer.Published
                        'Local' = $33.31.79.204
                        'Network' = $printer.Network
                        'KeepPrintedJobs' = $printer.KeepPrintedJobs
                        'Driver Name' = $printer.DriverName
                        'PortName' = $printer.PortName
                        'Default' = $printer.Default
                        'CurrentJobs' = $CurrJobs
                        'TotalJobsPrinted' = $TotalJobs
                        'TotalPagesPrinted' = $TotalPages
                        'JobErrors' = $JobErrors
                    }
                    $PrinterObjects += New-Object PSObject -Property $PrinterProperty
                }

                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'Printers' = $PrinterObjects
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.Printer.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                #endregion Printers

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Remote Printers: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Printers: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Printers: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Printers: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Printers: Getting info'
                        Status = 'Remote Printers: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Printers: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
 
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Printers: Getting printer information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Printers: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteEventLogs
{
    <#
    .SYNOPSIS
       Retrieves event logs via WMI in multiple runspaces.
    .DESCRIPTION
       Retrieves event logs via WMI and, if needed, alternate credentials. This function utilizes multiple runspaces.
    .PARAMETER ComputerName
       Specifies the target computer or comptuers for data query.
    .PARAMETER Hours
       Gather event logs from the last number of hourse specified here.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > (Get-RemoteEventLogs).EventLogs
       
       Description
       -----------
       Lists all of the event logs found on the localhost in the last 24 hours.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.1 - 01/18/2014
        - Small powershell 2.0 syntax fix which caused zero event logs to be resturned
       1.0.0 - 08/28/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage="Gather logs for this many previous hours.")]
        [ValidateRange(1,65535)]
        [int32]
        $Hours = 24,
        
        [Parameter(HelpMessage="Maximum number of concurrent runspaces.")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a runspaces stops trying to gather the information.")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function.")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials.")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials.")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Event Logs: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Event Logs: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Event Logs: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Event Logs: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Event Logs: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Event Logs: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
                
                [Parameter()]
                [int32]
                $Hours,

                [Parameter()]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Event Logs: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                Write-Verbose -Message ('Remote Event Logs: Runspace {0}: Gathering logs in last {1} hours' -f $ComputerName,$Hours)

                #Statics
                $time = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddHours(-$Hours))
                
                # WMI data
                $_EventLogSettings = Get-WmiObject @WMIHast -Class win32_NTEventlogFile | 
                    Where {$_.NumberOfRecords -gt 0}
                $EventLogFiles = @($_EventLogSettings | %{$_.LogfileName})
                $EventLogResults = @()
                Foreach ($LogFile in $EventLogFiles)
                {
                    Write-Verbose -Message ('Remote Event Logs: Runspace {0}: Processing {1} log file' -f $ComputerName,$Logfile)
                    $filter = "(Type <> 'information' AND Type <> 'audit success') and TimeGenerated>='$time' and LogFile='$LogFile'"
                    if ($LogFile -ne 'Security')
                    {
                        $EventLogResults += Get-WmiObject @WMIHast -Class Win32_NTLogEvent -filter  $filter |
                                                  Sort-Object -Property TimeGenerated -Descending
                    }
                }
                
                If ($EventLogResults.Count -gt 0)
                {
                    $ResultProperty = @{
                        'PSComputerName' = $ComputerName
                        'ComputerName' = $ComputerName
                        'EventLogs' = $EventLogResults
                    }
                    $ResultObject = New-Object PSObject -Property $ResultProperty
                    Write-Output -InputObject $ResultObject
                }
            }
            catch
            {
                Write-Warning -Message ('Remote Event Logs: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Event Logs: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Event Logs: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Remote Event Logs: Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Event Logs: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting installed programs'
                        Status = 'Remote Event Logs: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Hours',$Hours)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Event Logs: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Event Logs: Getting event logs' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Event Logs: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteAppliedGPOs
{
    <#
    .SYNOPSIS
       Gather applied GPO information from local or remote systems.
    .DESCRIPTION
       Gather applied GPO information from local or remote systems. Can utilize multiple runspaces and 
       alternate credentials.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       $a = Get-RemoteAppliedGPOs
       $a.AppliedGPOs | 
            Select Name,AppliedOrder |
            Sort-Object AppliedOrder
       
       Name                            appliedOrder
       ----                            ------------
       Local Group Policy                         1
       
       Description
       -----------
       Get all the locally applied GPO information then display them in their applied order.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/01/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Applied GPOs: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Applied GPOs: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Applied GPOs: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Applied GPOs: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Applied GPOs: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Applied GPOs: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $GPOPolicies = @()
                $PSDateTime = Get-Date
                
                #region GPO Data

                $GPOQuery = Get-WmiObject @WMIHast `
                                          -Namespace "ROOT\RSOP\Computer" `
                                          -Class RSOP_GPLink `
                                          -Filter "AppliedOrder <> 0" |
                            Select @{n='linkOrder';e={$_.linkOrder}},
                                   @{n='appliedOrder';e={$_.appliedOrder}},
                                   @{n='GPO';e={$_.GPO.ToString().Replace("RSOP_GPO.","")}},
                                   @{n='Enabled';e={$_.Enabled}},
                                   @{n='noOverride';e={$_.noOverride}},
                                   @{n='SOM';e={[regex]::match( $_.SOM , '(?<=")(.+)(?=")' ).value}},
                                   @{n='somOrder';e={$_.somOrder}}
                foreach($GP in $GPOQuery)
                {
                    $AppliedPolicy = Get-WmiObject @WMIHast `
                                                   -Namespace 'ROOT\RSOP\Computer' `
                                                   -Class 'RSOP_GPO' -Filter $GP.GPO
                        $ObjectProp = @{
                            'Name' = $AppliedPolicy.Name
                            'GuidName' = $AppliedPolicy.GuidName
                            'ID' = $AppliedPolicy.ID
                            'linkOrder' = $GP.linkOrder
                            'appliedOrder' = $GP.appliedOrder
                            'Enabled' = $GP.Enabled
                            'noOverride' = $GP.noOverride
                            'SourceOU' = $GP.SOM
                            'somOrder' = $GP.somOrder
                        }
                        
                        $GPOPolicies += New-Object PSObject -Property $ObjectProp
                }
                          
                Write-Verbose -Message ('Remote Applied GPOs: Runspace {0}: Applied GPO information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','AppliedGPOs')
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'AppliedGPOs' = $GPOPolicies
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.AppliedGPOs.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                #endregion GPO Data

                Write-Output -InputObject $ResultObject
            }
            catch
            {
                Write-Warning -Message ('Remote Applied GPOs: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Applied GPOs: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Applied GPOs: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Applied GPOs: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Applied GPOs: Getting info'
                        Status = 'Remote Applied GPOs: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Applied GPOs: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Applied GPOs: Getting applied GPO information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Applied GPOs: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteServiceInformation
{
    <#
    .SYNOPSIS
       Gather remote service information.
    .DESCRIPTION
       Gather remote service information. Uses multiple runspaces and, if required, alternate credentials.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ServiceName
       Specific service name to query.
    .PARAMETER IncludeDriverServices
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously.
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > Get-RemoteServiceInformation

       <output>
       
       Description
       -----------
       <Placeholder>

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/31/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter( ValueFromPipelineByPropertyName=$true,                    
                    ValueFromPipeline=$true,
                    HelpMessage="The service name to return." )]
        [Alias('Name')]
        [string[]]$ServiceName,
        
        [parameter( HelpMessage="Include the normally hidden driver services. Only applicable when not supplying a specific service name." )]
        [switch]
        $IncludeDriverServices,
        
        [parameter( HelpMessage="Optional WMI filter")]
        [string]
        $Filter,
        
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Service Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Service Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Service Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Service Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Service Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Service Information: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter()]
                [string]
                $ComputerName,
                
                [Parameter()]                
                [string[]]
                $ServiceName,
                
                [parameter()]
                [switch]
                $IncludeDriverServices,
                
                [parameter()]
                [string]
                $Filter,
 
                [Parameter()]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Service Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if ($ServiceName -ne $null)
                {
                    $WMIHast.Filter = "Name LIKE '$ServiceName'"
                }
                elseif ($Filter -ne $null)
                {
                    $WMIHast.Filter = $Filter
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $ResultSet = @()
                $PSDateTime = Get-Date
                
                #region Services
                Write-Verbose -Message ('Remote Service Information: Runspace {0}: Service information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Services')                                          
                                         
                $Services = @()
                $wmi_data = Get-WmiObject @WMIHast -Class Win32_Service
                foreach ($service in $wmi_data)
                {
                    $ServiceProperty = @{
                        'Name' = $service.Name
                        'DisplayName' = $service.DisplayName
                        'PathName' = $service.PathName
                        'Started' = $service.Started
                        'StartMode' = $service.StartMode
                        'State' = $service.State
                        'ServiceType' = $service.ServiceType
                        'StartName' = $service.StartName
                    }
                    $Services += New-Object PSObject -Property $ServiceProperty
                }
                if ($IncludeDriverServices)
                {
                    $wmi_data = Get-WmiObject @WMIHast -Class 'Win32_SystemDriver'
                    foreach ($service in $wmi_data)
                    {
                        $ServiceProperty = @{
                            'Name' = $service.Name
                            'DisplayName' = $service.DisplayName
                            'PathName' = $service.PathName
                            'Started' = $service.Started
                            'StartMode' = $service.StartMode
                            'State' = $service.State
                            'ServiceType' = $service.ServiceType
                            'StartName' = $service.StartName
                        }
                        $Services += New-Object PSObject -Property $ServiceProperty
                    }
                }
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'Services' = $Services
                }
                
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                    
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.Services.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                
                $ResultSet += $ResultObject
            
                #endregion Services

                Write-Output -InputObject $ResultSet
            }
            catch
            {
                Write-Warning -Message ('Remote Service Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Service Information: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Service Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Service Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Service Information: Getting info'
                        Status = 'Remote Service Information: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('ServiceName',$ServiceName)
            $null = $psCMD.AddParameter('IncludeDriverServices',$IncludeDriverServices)
            $null = $psCMD.AddParameter('Filter',$Filter)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Service Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
 
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Service Information: Getting service information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Service Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteShareSessionInformation
{
    <#
    .SYNOPSIS
       Get share session information from remote or local host.
    .DESCRIPTION
       Get share session information from remote or local host. Uses multiple runspaces if 
       multiple hosts are processed.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > Get-RemoteShareSessionInformation

       <output>
       
       Description
       -----------
       <Placeholder>

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 08/05/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
       
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter()]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter()]
        [switch]
        $ShowProgress,
        
        [Parameter()]
        [switch]
        $PromptForCredential,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Share Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Share Session Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Share Session Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Share Session Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Share Session Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Share Session Information: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Share Session Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $ResultSet = @()
                $PSDateTime = Get-Date
                
                #region ShareSessions
                Write-Verbose -Message ('Share Session Information: Runspace {0}: Share session information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Sessions')                                          
                $WMI_ConnectionProps  = @('ShareName','UserName','RemoteComputerName')
                $SessionData = @()
                $wmi_connections = Get-WmiObject @WMIHast -Class Win32_ServerConnection | select $WMI_ConnectionProps
                foreach ($userSession in $wmi_connections)
                {
                    $SessionProperty = @{
                        'ShareName' = $userSession.ShareName
                        'UserName' = $userSession.UserName
                        'RemoteComputerName' = $userSession.ComputerName
                    }
                    $SessionData += New-Object -TypeName PSObject -Property $SessionProperty
                }
             
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'Sessions' = $SessionData
                }

                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.ShareSession.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                
                $ResultSet += $ResultObject

                #endregion ShareSessions

                Write-Output -InputObject $ResultSet
            }
            catch
            {
                Write-Warning -Message ('Share Session Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Share Session Information: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Share Session Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Share Session Information: Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Share Session Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting share session information'
                        Status = 'Share Session Information: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            #$psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock).AddParameter('bgRunspaceID',$bgRunspaceCounter).AddParameter('ComputerName',$Computer).AddParameter('IncludeMemoryInfo',$IncludeMemoryInfo).AddParameter('IncludeDiskInfo',$IncludeDiskInfo).AddParameter('IncludeNetworkInfo',$IncludeNetworkInfo).AddParameter('Verbose',$Verbose)
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Share Session Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
 
    End
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Share Session Information: Getting share session information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Share Session Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteRegistryInformation
{
    <#
    .SYNOPSIS
       Retrieves registry subkey information.
    .DESCRIPTION
       Retrieves registry subkey information. All subkeys and their values are returned as a custom psobject. Optionally
       an array of psobjects can be returned which contain extra information like the registry key type,computer, and datetime.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER Hive
       Registry hive to retrieve from. By default this is 2147483650 (HKLM). Valid hives include:
          HKEY_CLASSES_ROOT = 2147483648
          HKEY_CURRENT_USER = 2147483649
          HKEY_LOCAL_MACHINE = 2147483650
          HKEY_USERS = 2147483651
          HKEY_CURRENT_CONFIG = 2147483653
          HKEY_DYN_DATA = 2147483654
    .PARAMETER Key
       Registry key to inspect (ie. SYSTEM\CurrentControlSet\Services\W32Time\Parameters)
    .PARAMETER AsHash
       Return a hash where the keys are the registry entries. This is only suitable for getting the regisrt
       values of one computer at a time.
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
    .EXAMPLE
       PS > $(Get-RemoteRegistryInformation -AsHash -Key "SYSTEM\CurrentControlSet\Services\W32Time\Parameters")['Type']

       NT5DS
       
       Description
       -----------
       Return the value of the 'Type' subkey within SYSTEM\CurrentControlSet\Services\W32Time\Parameters of
       HKLM.
       
    .EXAMPLE
       PS > $(Get-RemoteRegistryInformation -AsObject -Key "SYSTEM\CurrentControlSet\Services\W32Time\Parameters").Type

       NT5DS
       
       Description
       -----------
       Return the value of the 'Type' subkey within SYSTEM\CurrentControlSet\Services\W32Time\Parameters of
       HKLM from an object containing all registry keys in HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters
       as individual object properties.
       
    .EXAMPLE
       PS > $b = Get-RemoteRegistryInformation -Key "SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
       PS > $b.Registry | Select SubKey,SubKeyValue,SubKeyType
       
        SubKey                                         SubKeyValue                                    SubKeyType
        ------                                         -----------                                    ----------                                   
        ServiceDll                                     C:\Windows\system32\w32time.dll                REG_EXPAND_SZ
        ServiceMain                                    SvchostEntry_W32Time                           REG_SZ
        ServiceDllUnloadOnStop                         1                                              REG_DWORD
        Type                                           NT5DS                                          REG_SZ
        NtpServer                                                                                     REG_SZ
       
       Description
       -----------
       Return subkeys and their values as well as key types within SYSTEM\CurrentControlSet\Services\W32Time\Parameters of
       HKLM.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.2 - 08/30/2013 
        - Changed AsArray option to be AsHash and restructured code to reflect this
        - Changed examples
        - Prefixed all warnings and verbose messages with function specific verbage
        - Forced STA apartement state before opening a runspace
       1.0.1 - 08/07/2013
        - Removed the explicit return of subkey values from output options
        - Fixed issue where only string values were returned
       1.0.0 - 08/06/2013
        - Initial release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter( HelpMessage="Registry Hive (Default is HKLM)." )]
        [UInt32]
        $Hive = 2147483650,
        
        [Parameter( Mandatory=$true,
                    HelpMessage="Registry Key to inspect." )]
        [String]
        $Key,
        
        [Parameter(HelpMessage="Return a hash with key value pairs representing the registry being queried.")]
        [switch]
        $AsHash,
        
        [Parameter(HelpMessage="Return an object wherein the object properties are the registry keys and the property values are their value.")]
        [switch]
        $AsObject,
        
        [Parameter(HelpMessage="Maximum number of concurrent threads.")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information.")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function.")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials.")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials.")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Registry: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Registry: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Registry: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Registry: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Registry: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Registry: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,

                [Parameter()]
                [UInt32]
                $Hive = 2147483650,
                
                [Parameter()]
                [String]
                $Key,
                
                [Parameter()]
                [switch]
                $AsHash,
                
                [Parameter()]
                [switch]
                $AsObject,
                
                [Parameter()]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            $regtype = @("Placeholder","REG_SZ","REG_EXPAND_SZ","REG_BINARY","REG_DWORD","Placeholder","Placeholder","REG_MULTI_SZ",`
                          "Placeholder","Placeholder","Placeholder","REG_QWORD")

            try
            {
                Write-Verbose -Message ('Remote Registry: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                # General variables
                $PSDateTime = Get-Date
                
                #region Registry
                Write-Verbose -Message ('Remote Registry: Runspace {0}: Gathering registry information' -f $ComputerName)

                # WMI data
                $wmi_data = Get-WmiObject @WMIHast -Class StdRegProv -Namespace 'root\default' -List:$true
                $allregkeys = $wmi_data.EnumValues($Hive,$Key)
                $allsubkeys = $wmi_data.EnumKey($Hive,$Key)

                $ResultHash = @{}
                $RegObjects = @() 
                $ResultObject = @{}
                       
                for ($i = 0; $i -lt $allregkeys.Types.Count; $i++) 
                {
                    switch ($allregkeys.Types[$i]) {
                            1 {
                                $keyvalue = ($wmi_data.GetStringValue($Hive,$Key,$allregkeys.sNames[$i])).sValue
                            }
                            2 {
                                $keyvalue = ($wmi_data.GetExpandedStringValue($Hive,$Key,$allregkeys.sNames[$i])).sValue
                            }
                            3 {
                                $keyvalue = ($wmi_data.GetBinaryValue($Hive,$Key,$allregkeys.sNames[$i])).uValue
                            }
                            4 {
                                $keyvalue = ($wmi_data.GetDWORDValue($Hive,$Key,$allregkeys.sNames[$i])).uValue
                            }
                               7 {
                                $keyvalue = ($wmi_data.GetMultiStringValue($Hive,$Key,$allregkeys.sNames[$i])).uValue
                            }
                            11 {
                                $keyvalue = ($wmi_data.GetQWORDValue($Hive,$Key,$allregkeys.sNames[$i])).sValue
                            }
                            default {
                                break
                            }
                    }
                    if ($AsHash -or $AsObject)
                    {
                        $ResultHash[$allregkeys.sNames[$i]] = $keyvalue
                    }
                    else
                    {
                        $RegProperties = @{
                            'Key' = $allregkeys.sNames[$i]
                            'KeyType' = $regtype[($allregkeys.Types[$i])]
                            'KeyValue' = $keyvalue
                        }
                        $RegObjects += New-Object PSObject -Property $RegProperties
                    }
                }
                foreach ($subkey in $allsubkeys.sNames) 
                {
                    if ($AsHash)
                    {
                        $ResultHash[$subkey] = ''
                    }
                    else
                    {
                        $RegProperties = @{
                            'Key' = $subkey
                            'KeyType' = 'SubKey'
                            'KeyValue' = ''
                        }
                        $RegObjects += New-Object PSObject -Property $RegProperties
                    }
                }
                if ($AsHash)
                {
                    $ResultHash
                }
                elseif ($AsObject)
                {
                    $ResultHash['PSComputerName'] = $ComputerName
                    $ResultObject = New-Object PSObject -Property $ResultHash
                    Write-Output -InputObject $ResultObject
                }
                else
                {
                    $ResultProperty = @{
                        'PSComputerName' = $ComputerName
                        'PSDateTime' = $PSDateTime
                        'ComputerName' = $ComputerName
                        'Registry' = $RegObjects
                    }
                    $Result = New-Object PSObject -Property $ResultProperty
                    Write-Output -InputObject $Result
                }
            }
            catch
            {
                Write-Warning -Message ('Remote Registry: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Registry: Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Registry: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Registry: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Hive',$Hive)
            $null = $psCMD.AddParameter('Key',$Key)
            $null = $psCMD.AddParameter('AsHash',$AsHash)
            $null = $psCMD.AddParameter('AsObject',$AsObject)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Registry: Getting registry information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Registry: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}

Function Get-RemoteProcessInformation
{
    <#
    .SYNOPSIS
       Get process information from remote machines.
    .DESCRIPTION
       Get process information from remote machines. use alternate credentials if desired. Filter by
       process name if desired.
    .PARAMETER ComputerName
       Specifies the target computer for data query.
    .PARAMETER Process
       Optional process name to filter by
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress

    .EXAMPLE
       PS > (Get-RemoteProcessInformation -Process GoogleUpdate%).Processes | select Name

       name                                                                                                                     
       ----                                                                                                                     
       GoogleUpdate.exe 
       
       Description
       -----------
       Select all processes from the local machine with GoogleUpdate in the name then display the whole name.

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/01/2013
        - Initial release
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage="Computer or computers to gather information from",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,

        [Parameter(HelpMessage="Process name")]
        [string]
        $Process='',
        
        [Parameter(HelpMessage="Maximum number of concurrent threads")]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage="Timeout before a thread stops trying to gather the information")]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage="Display progress of function")]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage="Set this if you want the function to prompt for alternate credentials")]
        [switch]
        $PromptForCredential,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Remote Process Information: Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Remote Process Information: Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Remote Process Information: Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Remote Process Information: Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Remote Process Information: Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.ApartmentState = 'STA'
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Remote Process Information: Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
                
                [Parameter(Position=1)]
                [string]
                $Process='',
 
                [Parameter(Position=2)]
                [int]
                $bgRunspaceID
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Remote Process Information: Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }
                if ($Process -ne '')
                {
                    $WMIHast.Filter = "Name LIKE '$Process'"
                }

                # General variables
                $PSDateTime = Get-Date
                $ResultSet = @()
                
                #region Remote Process Information
                Write-Verbose -Message ('Remote Process Information: Runspace {0}: Process information' -f $ComputerName)

                # Modify this variable to change your default set of display properties
                $defaultProperties    = @('ComputerName','Processes')

                # WMI data
                $wmi_processes = @(Get-WmiObject @WMIHast -Class Win32_Process)
                $ResultProperty = @{
                    'PSComputerName' = $ComputerName
                    'PSDateTime' = $PSDateTime
                    'ComputerName' = $ComputerName
                    'Processes' = $wmi_processes
                }
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty
                    
                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.RemoteProcesses.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                
                $ResultSet += $ResultObject

                #endregion Remote Process Information

                Write-Output -InputObject $ResultSet
            }
            catch
            {
                Write-Warning -Message ('Remote Process Information: {0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Remote Process Information: Runspace {0}: End' -f $ComputerName)
        }
 
        Function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers[$runspace.ID]
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Remote Process Information: Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Remote Process Information: Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Remote Process Information: Getting info'
                        Status = 'Remote Process Information: {0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('Process',$Process)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference)
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Remote Process Information: Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
           })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Remote Process Information: Getting process information' -Status 'Done' -Completed
        }
        Write-Verbose -Message "Remote Process Information: Closing runspace pool"
        $rp.Close()
        $rp.Dispose()
    }
}
#endregion Functions - Multiple Runspace

#region Functions - Serial or Utility
function Get-ScriptDirectory
{ 
    if($hostinvocation -ne $null)
    {
        Split-Path $hostinvocation.MyCommand.path
    }
    else
    {
        Split-Path $script:MyInvocation.MyCommand.Path
    }
}

Function New-HTMLBarGraph
{
    <#
    .SYNOPSIS
       Creates an HTML fragment that looks like a horizontal bar graph when rendered.
    .DESCRIPTION
       Creates an HTML fragment that looks like a horizontal bar graph when rendered. Can be customized to use different
       characters for the left and right sides of the graph. Can also be customized to be a certain number of characters
       in size (Highly recommend sticking with even numbers)
    .PARAMETER LeftGraphChar
        HTML encoded character to use for the left part of the graph (the percentage used).
    .PARAMETER RightGraphChar
        HTML encoded character to use for the right part of the graph (the percentage unused).
    .PARAMETER GraphSize
        Overall character size of the graph
    .PARAMETER PercentageUsed
        The percentage of the graph which is "used" (the left side of the graph).
    .PARAMETER LeftColor
        The HTML color code for the left/used part of the graph.
    .PARAMETER RightColor
        The HTML color code for the right/unused part of the graph.
    .EXAMPLE
        PS> New-HTMLBarGraph -GraphSize 20 -PercentageUsed 10
        
        <Font Color=Red>&#9608;&#9608;</Font>
        <Font Color=Green>&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;
        &#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;&#9608;
        &#9608;&#9608;</Font>
        
        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0
           1.0.0 - 08/10/2013
            - Initial release
            
        Some good characters to use for your graphs include:
        ▬  &#9644;
        ░  &#9617; {dither light}    
        ▒  &#9618; {dither medium}    
        ▓  &#9619; {dither heavy}    
        █  &#9608; {full box}
        
        Find more html character codes here: http://brucejohnson.ca/SpecialCharacters.html
        
        The default colors are not all that impressive. Used (left side of graph) is red and unused 
        (right side of the graph) is green. You use any colors which the font attribute will accept in html, 
        this includes transparent!
        
        If you are including this output in a larger table with other results remember that the 
        special characters will get converted and look all crappy after piping through convertto-html.
        To fix this issue, simply html decode the results like in this long winded example for memory
        utilization:
        
        $a = gwmi win32_operatingSystem | `
        select PSComputerName, @{n='Memory Usage';
                                 e={New-HTMLBarGraph -GraphSize 20 -PercentageUsed `
                                   (100 - [math]::Round((100 * ($_.FreePhysicalMemory)/`
                                                               ($_.TotalVisibleMemorySize))))}
                                }
        $Output = [System.Web.HttpUtility]::HtmlDecode(($a | ConvertTo-Html))
        $Output
        
        Props for original script from http://windowsmatters.com/index.php/category/powershell/page/2/
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(HelpMessage="Character to use for left side of graph")]
        [string]$LeftGraphChar='&#9608;',
        
        [Parameter(HelpMessage="Character to use for right side of graph")]
        [string]$RightGraphChar='&#9608;',
        
        [Parameter(HelpMessage="Total size of the graph in character length. You really should stick with even numbers here.")]
        [int]$GraphSize=50,
        
        [Parameter(HelpMessage="Percentage for first part of graph")]
        [int]$PercentageUsed=50,
 
        [Parameter(HelpMessage="Color of left (used) graph segment.")]
        [string]$LeftColor='Red',

        [Parameter(HelpMessage="Color of left (unused) graph segment.")]
        [string]$RightColor='Green'
    )

    [int]$LeftSideCount = [Math]::Round((($PercentageUsed/100)*$GraphSize))
    [int]$RightSideCount = [Math]::Round((((100 - $PercentageUsed)/100)*$GraphSize))
    for ($index = 0; $index -lt $LeftSideCount; $index++) {
        $LeftSide = $LeftSide + $LeftGraphChar
    }
    for ($index = 0; $index -lt $RightSideCount; $index++) {
        $RightSide = $RightSide + $RightGraphChar
    }
    
    $Result = "<Font Color={0}>{1}</Font><Font Color={2}>{3}</Font>" `
               -f $LeftColor,$LeftSide,$RightColor,$RightSide

    Return $Result
}

Filter ConvertTo-KMG 
{
     <#
     .Synopsis
      Converts byte counts to Byte\KB\MB\GB\TB\PB format
     .DESCRIPTION
      Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
      with decimal precision of 2
     .EXAMPLE
     3000 | convertto-kmg
     #>

     $bytecount = $_
        switch ([math]::truncate([math]::log($bytecount,1024))) 
        {
                  0 {"$bytecount Bytes"}
                  1 {"{0:n2} KB" -f ($bytecount / 1kb)}
                  2 {"{0:n2} MB" -f ($bytecount / 1mb)}
                  3 {"{0:n2} GB" -f ($bytecount / 1gb)}
                  4 {"{0:n2} TB" -f ($bytecount / 1tb)}
            Default {"{0:n2} PB" -f ($bytecount / 1pb)}
          }
}

Filter ConvertTo-MB 
{
    <#
    .SYNOPSIS
    Converts KB\MB\GB\TB\PB format to MB float
    .DESCRIPTION
    Accepts an [int64] byte count, and converts to Byte\KB\MB\GB\TB\PB format
    with decimal precision of 2
    .EXAMPLE
    '3000 MB' | ConvertTo-MB
    .EXAMPLE
    '123 Tb' | ConvertTo-MB
    #>
    $val = $_
    switch ([Regex]::Match($val, "(?s)(?<=(.+\ ))(.+)").Value) {
        'B'  {([float](0))}
        'KB' {([float]([Regex]::Match($val, "(?s)(.+)(?=(\ (.+)))").Value) / 11024)}
        'MB' {([float]([Regex]::Match($val, "(?s)(.+)(?=(\ (.+)))").Value))}
        'GB' {([float]([Regex]::Match($val, "(?s)(.+)(?=(\ (.+)))").Value) * 1024)}
        'TB' {([float]([Regex]::Match($val, "(?s)(.+)(?=(\ (.+)))").Value) * 1048576)}
     default {([float]([Regex]::Match($val, "(?s)(.+)(?=(\ (.+)))").Value))}
    }
}

Function ConvertTo-PropertyValue 
{
    <#
    .SYNOPSIS
    Convert an object with various properties into an array of property, value pairs 
    
    .DESCRIPTION
    Convert an object with various properties into an array of property, value pairs

    If you output reports or other formats where a table with one long row is poorly formatted, this is a quick way to create a table of property value pairs.

    There are other ways you could do this.  For example, I could list all noteproperties from Get-Member results and return them.
    This function will keep properties in the same order they are provided, which can often be helpful for readability of results.

    .PARAMETER inputObject
    A single object to convert to an array of property value pairs.

    .PARAMETER leftheader
    Header for the left column.  Default:  Property

    .PARAMETER rightHeader
    Header for the right column.  Default:  Value

    .PARAMETER memberType
    Return only object members of this membertype.  Default:  Property, NoteProperty, ScriptProperty

    .EXAMPLE
    get-process powershell_ise | convertto-propertyvalue

    I want details on the powershell_ise process.
        With this command, if I output this to a table, a csv, etc. I will get a nice vertical listing of properties and their values
        Without this command, I get a long row with the same info

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    .FUNCTIONALITY
    General Command
    #> 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromRemainingArguments=$false)]
        [PSObject]$InputObject,
        
        [validateset("AliasProperty", "CodeProperty", "Property", "NoteProperty", "ScriptProperty",
            "Properties", "PropertySet", "Method", "CodeMethod", "ScriptMethod", "Methods",
            "ParameterizedProperty", "MemberSet", "Event", "Dynamic", "All")]
        [string[]]$memberType = @( "NoteProperty", "Property", "ScriptProperty" ),
            
        [string]$leftHeader = "Property",
            
        [string]$rightHeader = "Value"
    )

    begin{
        #init array to dump all objects into
        $allObjects = @()

    }
    process{
        #if we're taking from pipeline and get more than one object, this will build up an array
        $allObjects += $inputObject
    }

    end{
        #use only the first object provided
        $allObjects = $allObjects[0]

        #Get properties.  Filter by memberType.
        $properties = $allObjects.psobject.properties | ?{$memberType -contains $_.memberType} | select -ExpandProperty Name

        #loop through properties and display property value pairs
        foreach($property in $properties){

            #Create object with property and value
            $temp = "" | select $leftHeader, $rightHeader
            $temp.$leftHeader = $property.replace('"',"")
            $temp.$rightHeader = try { $allObjects | select -ExpandProperty $temp.$leftHeader -erroraction SilentlyContinue } catch { $null }
            $temp
        }
    }
}

Function ConvertTo-HashArray
{
    <#
    .SYNOPSIS
    Convert an array of objects to a hash table based on a single property of the array. 
    
    .DESCRIPTION
    Convert an array of objects to a hash table based on a single property of the array.
    
    .PARAMETER InputObject
    An array of objects to convert to a hash table array.

    .PARAMETER PivotProperty
    The property to use as the key value in the resulting hash.
    
    .PARAMETER LookupValue
    Property in the psobject to be the value that the hash key points to in the returned result. If not specified, all properties in the psobject are used.

    .EXAMPLE
    $DellServerHealth = @(Get-DellServerhealth @_dellhardwaresplat)
    $DellServerHealth = ConvertTo-HashArray $DellServerHealth 'PSComputerName'

    Description
    -----------
    Calls a function which returns a psobject then converts that result to a hash array based on the PSComputerName
    
    Zachary Loeber
    
    1.1 - 11/17/2013
        - Added LookupValue Parameter to allow for creation of one to one hashs
        - Added more error validation
        - Dolled up the paramerters
        
    .LINK 
    http://www.the-little-things.net 
    #> 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   HelpMessage='A single or array of PSObjects',
                   Position=0)]
        [AllowEmptyCollection()]
        [PSObject[]]
        $InputObject,
        
        [Parameter(Mandatory=$true,
                   HelpMessage='Property in the psobject to be the future key in a returned hash.',
                   Position=1)]
        [string]$PivotProperty,
        
        [Parameter(HelpMessage='Property in the psobject to be the value that the hash key points to. If not specified, all properties in the psobject are used.',
                   Position=2)]
        [string]$LookupValue = ''
    )

    BEGIN
    {
        #init array to dump all objects into
        $allObjects = @()
        $Results = @{}
    }
    PROCESS
    {
        #if we're taking from pipeline and get more than one object, this will build up an array
        $allObjects += $inputObject
    }

    END
    {
        ForEach ($object in $allObjects)
        {
            if ($object -ne $null)
            {
                try
                {
                    if ($object.PSObject.Properties.Match($PivotProperty).Count) 
                    {
                        if ($LookupValue -eq '')
                        {
                            $Results[$object.$PivotProperty] = $object
                        }
                        else
                        {
                            if ($object.PSObject.Properties.Match($LookupValue).Count)
                            {
                                $Results[$object.$PivotProperty] = $object.$LookupValue
                            }
                            else
                            {
                                Write-Warning -Message ('ConvertTo-HashArray: LookupValue Not Found - {0}' -f $_.Exception.Message)
                            }
                        }
                    }
                    else
                    {
                        Write-Warning -Message ('ConvertTo-HashArray: LookupValue Not Found - {0}' -f $_.Exception.Message)
                    }
                }
                catch
                {
                    Write-Warning -Message ('ConvertTo-HashArray: Something weird happened! - {0}' -f $_.Exception.Message)
                }
            }
        }
        $Results
    }
}

Function ConvertTo-ProductKey
{
    <#   
    .SYNOPSIS   
        Converts registry key value to windows product key.
         
    .DESCRIPTION   
        Converts registry key value to windows product key. Specifically the following keys:
            SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId
            SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId4
        
    .PARAMETER Registry
        Either DigitalProductId or DigitalProductId4 (as described in the description)
         
        Original Author: Boe Prox
        Version: 1.0
         - Took the registry setting retrieval portion from Boe's original script and converted it
           to this basic conversion function. This is to be used in conjunction with my other
           function, get-remoteregistryinformation
     
    .EXAMPLE 
     PS > $reg_ProductKey = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
     PS > $a = Get-RemoteRegistryInformation -Key $reg_ProductKey -AsObject
     PS > ConvertTo-ProductKey $a.DigitalProductId
     
            XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
            
     PS > ConvertTo-ProductKey $a.DigitalProductId4 -x64
     
            XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
         
        Description 
        ----------- 
        Retrieves the product key information from the local machine and converts it to a readible format.
    #>      
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$True,Position=0)]
        $Registry,
        [parameter()]
        [Switch]$x64
    )
    Begin 
    {
        $map="BCDFGHJKMPQRTVWXY2346789" 
    }
    Process 
    {
        $ProductKey = ""

        $prodkey = $Registry[0x34..0x42]

        for ($i = 24; $i -ge 0; $i--) 
        { 
            $r = 0 
            for ($j = 14; $j -ge 0; $j--) 
            {
                $r = ($r * 256) -bxor $prodkey[$j] 
                $prodkey[$j] = [math]::Floor([double]($r/24)) 
                $r = $r % 24 
            } 
            $ProductKey = $map[$r] + $ProductKey 
            if (($i % 5) -eq 0 -and $i -ne 0)
            { 
                $ProductKey = "-" + $ProductKey
            }
        }
        $ProductKey
    }
}

Function ConvertTo-PSObject
{
    <# 
     Take an array of like psobject and convert it to a singular psobject based on two shared
     properties across all psobjects in the array.
     Example Input object: 
    $obj = @()
    $a = @{ 
        'PropName' = 'Property 1'
        'Val1' = 'Value 1'
        }
    $b = @{ 
        'PropName' = 'Property 2'
        'Val1' = 'Value 2'
        }
    $obj += new-object psobject -property $a
    $obj += new-object psobject -property $b

    $c = $obj | ConvertTo-PSObject -propname 'PropName' -valname 'Val1'
    $c.'Property 1'
    Value 1
    #>
    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,
        [string]$propname,
        [string]$valname
    )

    BEGIN
    {
        #init array to dump all objects into
        $allObjects = @()
    }
    PROCESS
    {
        #if we're taking from pipeline and get more than one object, this will build up an array
        $allObjects += $inputObject
    }
    END
    {
        $returnobject = New-Object psobject
        foreach ($obj in $allObjects)
        {
            if ($obj.$propname -ne $null)
            {
                $returnobject | Add-Member -MemberType NoteProperty -Name $obj.$propname -Value $obj.$valname
            }
        }
        $returnobject
    }
}

Function ConvertTo-MultiArray 
{
 <#
 NAME: ConvertTo-MultiArray
 Website: http://powertoe.wordpress.com
 Twitter: http://twitter.com/toenuff
 Version: 1.0
 11/5/2010 1.0
 Initial Release
 11/5/2010 1.1
 Removed array parameter and passes a reference to the multi-dimensional array as output to the cmdlet
 11/5/2010 1.2
 Modified all rows to ensure they are entered as string values including $null values as a blank ("") string.

 .Synopsis
 Converts a collection of PowerShell objects into a multi-dimensional array

 .Description
 Converts a collection of PowerShell objects into a multi-dimensional array.  The first row of the array contains the property names.  Each additional row contains the values for each object.

 This cmdlet was created to act as an intermediary to importing PowerShell objects into a range of cells in 92.115.29.141.  By using a multi-dimensional array you can greatly speed up the process of adding data to Excel through the Excel COM objects.

 .Parameter InputObject
 Specifies the objects to export into the multi dimensional array.  Enter a variable that contains the objects or type a command or expression that gets the objects. You can also pipe objects to ConvertTo-MultiArray.

 .Inputs
 System.Management.Automation.PSObject
        You can pipe any .NET Framework object to ConvertTo-MultiArray

 .Outputs
 [ref]
        The cmdlet will return a reference to the multi-dimensional array.  To access the array itself you will need to use the Value property of the reference

 .Example
 $arrayref = get-process |Convertto-MultiArray

 .Example
 $dir = Get-ChildItem c:\
 $arrayref = Convertto-MultiArray -InputObject $dir

 .Example
 $range.value2 = (ConvertTo-MultiArray (get-process)).value

 .LINK

http://powertoe.wordpress.com

#>
    param(
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [PSObject[]]$InputObject
    )
    BEGIN {
        $objects = @()
        [ref]$array = [ref]$null
    }
    Process {
        $objects += $InputObject
    }
    END {
        $properties = $objects[0].psobject.properties |%{$_.name}
        $array.Value = New-Object 'object[,]' ($objects.Count+1),$properties.count
        # i = row and j = column
        $j = 0
        $properties |%{
            $array.Value[0,$j] = $_.tostring()
            $j++
        }
        $i = 1
        $objects |% {
            $item = $_
            $j = 0
            $properties | % {
                if ($item.($_) -eq $null) {
                    $array.value[$i,$j] = ""
                }
                else {
                    $array.value[$i,$j] = $item.($_).tostring()
                }
                $j++
            }
            $i++
        }
        $array
    }
}

Function Get-DellWarranty
{
    <# 
    .Synopsis 
       Get Warranty Info for Dell Computer 
    .DESCRIPTION 
       This takes a Computer Name, returns the ST of the computer, 
       connects to Dell's SOAP Service and returns warranty info and 
       related information. If computer is offline, no action performed. 
       ST is pulled via WMI. 
    .EXAMPLE 
       get-dellwarranty -Name bob, client1, client2 | ft -AutoSize 
        WARNING: bob is offline 
     
        ComputerName ServiceLevel  EndDate   StartDate DaysLeft ServiceTag Type                       Model ShipDate  
        ------------ ------------  -------   --------- -------- ---------- ----                       ----- --------  
        client1      C, NBD ONSITE 2/22/2017 2/23/2014     1095 7GH6SX1    Dell Precision WorkStation T1650 2/22/2013 
        client2      C, NBD ONSITE 7/16/2014 7/16/2011      334 74N5LV1    Dell Precision WorkStation T3500 7/15/2010 
    .EXAMPLE 
        Get-ADComputer -Filter * -SearchBase "OU=222.205.193.149 2010,OU=Member Servers,DC=Contoso,DC=com" | get-dellwarranty | ft -AutoSize 
     
        ComputerName ServiceLevel            EndDate   StartDate DaysLeft ServiceTag Type      Model ShipDate  
        ------------ ------------            -------   --------- -------- ---------- ----      ----- --------  
        MAIL02       P, Gold or ProMCritical 4/26/2016 4/25/2011      984 CGWRNQ1    PowerEdge M905  4/25/2011 
        MAIL01       P, Gold or ProMCritical 4/26/2016 4/25/2011      984 DGWRNQ1    PowerEdge M905  4/25/2011 
        DAG          P, Gold or ProMCritical 4/26/2016 4/25/2011      984 CGWRNQ1    PowerEdge M905  4/25/2011 
        MAIL         P, Gold or ProMCritical 4/26/2016 4/25/2011      984 CGWRNQ1    PowerEdge M905  4/25/2011 
    .EXAMPLE 
        get-dellwarranty -ServiceTag CGABCQ1,DGEFGQ1 | ft  -AutoSize 
     
        ServiceLevel            EndDate   StartDate DaysLeft ServiceTag Type      Model ShipDate  
        ------------            -------   --------- -------- ---------- ----      ----- --------  
        P, Gold or ProMCritical 4/26/2016 4/25/2011      984 CGABCQ1    PowerEdge M905  4/25/2011 
        P, Gold or ProMCritical 4/26/2016 4/25/2011      984 DGEFGQ1    PowerEdge M905  4/25/201 
    .INPUTS 
       Name(ComputerName), ServiceTag 
    .OUTPUTS 
       System.Object 
       General notes 
    #> 
    [CmdletBinding()] 
    [OutputType([System.Object])] 
    Param( 
        # Name should be a valid computer name or IP address. 
        [Parameter(Mandatory=$False,  
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
         
        [Alias('HostName', 'Identity', 'DNSHostName', 'Name')] 
        [string[]]$ComputerName=$env:COMPUTERNAME, 
         
        [Parameter()] 
        [string[]]$ServiceTag = $null,
     
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    ) 
 
    BEGIN
    {
        $wmisplat = @{}
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try 
            {
                [net.dns]::GetHostByAddress($_)
            } catch 
            {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
        if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
        {
            $wmisplat.Credential = $Credential
        }
    } 
    PROCESS
    {
        if($ServiceTag -eq $null)
        { 
            foreach($C in $ComputerName)
            { 
                $test = Test-Connection -ComputerName $c -Count 1 -Quiet 
                if($test -eq $true)
                {
                    try
                    {
                        $system = Get-WmiObject @wmisplat -ComputerName $C win32_bios -ErrorAction SilentlyContinue                

                        if ($system.Manufacturer -like "Dell*")
                        {
                            try
                            {
                                $service = New-WebServiceProxy -Uri http://140.218.243.153/services/assetservice.asmx?WSDL -ErrorAction Stop
                                $serial =  $system.serialnumber 
                                $guid = [guid]::NewGuid() 
                                $info = $service.GetAssetInformation($guid,'check_warranty.ps1',$serial) 
                                if ($info -ne $null)
                                {
                                    $Result=@{ 
                                        'ComputerName'=$c 
                                        'ServiceLevel'=$info[0].Entitlements[0].ServiceLevelDescription.ToString() 
                                        'EndDate'=$info[0].Entitlements[0].EndDate.ToShortDateString() 
                                        'StartDate'=$info[0].Entitlements[0].StartDate.ToShortDateString() 
                                        'DaysLeft'=$info[0].Entitlements[0].DaysLeft 
                                        'ServiceTag'=$info[0].AssetHeaderData.ServiceTag 
                                        'Type'=$info[0].AssetHeaderData.SystemType 
                                        'Model'=$info[0].AssetHeaderData.SystemModel 
                                        'ShipDate'=$info[0].AssetHeaderData.SystemShipDate.ToShortDateString() 
                                    } 
                                 
                                    $obj = New-Object -TypeName psobject -Property $result 
                                    Write-Output $obj 
                                }
                                else
                                {
                                    Write-Warning -Message ('{0}: No warranty information returned' -f $C)
                                }
                            }
                            catch
                            {
                                Write-Warning -Message ('{0}: Unable to connect to web service' -f $C)
                            }
                        }
                        else
                        {
                            Write-Warning -Message ('{0}: Not a Dell computer' -f $C)
                        }
                    }
                    catch
                    {
                        Write-Warning -Message ('{0}: Not able to gather service tag' -f $C)
                    }
                }  
                else
                { 
                    Write-Warning -Message ('{0}: System is offline' -f $C)
                }         
 
            } 
        } 
        else
        { 
            foreach($s in $ServiceTag)
            {
                try
                {
                    $service = New-WebServiceProxy -Uri http://140.218.243.153/services/assetservice.asmx?WSDL -ErrorAction Stop
                    $guid = [guid]::NewGuid() 
                    $info = $service.GetAssetInformation($guid,'check_warranty.ps1',$S) 
                     
                    if($info)
                    { 
                        $Result=@{ 
                            'ServiceLevel'=$info[0].Entitlements[0].ServiceLevelDescription.ToString() 
                            'EndDate'=$info[0].Entitlements[0].EndDate.ToShortDateString() 
                            'StartDate'=$info[0].Entitlements[0].StartDate.ToShortDateString() 
                            'DaysLeft'=$info[0].Entitlements[0].DaysLeft 
                            'ServiceTag'=$info[0].AssetHeaderData.ServiceTag 
                            'Type'=$info[0].AssetHeaderData.SystemType 
                            'Model'=$info[0].AssetHeaderData.SystemModel 
                            'ShipDate'=$info[0].AssetHeaderData.SystemShipDate.ToShortDateString() 
                        } 
                    } 
                    else
                    { 
                        Write-Warning "$S is not a valid Dell Service Tag." 
                    } 

                    $obj = New-Object -TypeName psobject -Property $result 
                    Write-Output $obj 
                }
               catch
               {
                    Write-Warning -Message ('{0}: Unable to connect to web service' -f $C)
               }
            }
        } 
    } 
    END
    { 
    } 
}

Function Get-RemoteCommandResults
{
    <#
    .SYNOPSIS
        Uses WMI to send a command to a remote system and store the results in a local file. 
    .DESCRIPTION
        Uses WMI and file copying trickery to get the results of a remotely executed command.
    .PARAMETER InputObject
        Object or array of objects returned from New-RemoteCommand
    .PARAMETER LeaveRemoteFile
        By default the remote file containing the commadn output is removed. Use this switch to leave it alone.
    .PARAMETER Credential
        Set this if you want to provide your own alternate credentials.
    .EXAMPLE
       PS > $a = Get-RemoteCommandResults $cmdresults
       
       Description
       -----------
       Gather and store the results of the remotely run command output generated from New-RemoteCommand

       Site: http://www.the-little-things.net/
       Requires: Powershell 2.0

       1.0.0 - 09/19/2013
        - Initial release
    
    ** This is a supplement function to New-RemoteCommand **
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage='Object or array of objects returned from New-RemoteCommand')]
        $InputObject,
        
        [Parameter(HelpMessage='By default the remote file containing the commadn output is removed. Use this switch to leave it alone.')]
        [switch]
        $LeaveRemoteFile,
        
        [Parameter(HelpMessage="Set this if you want to provide your own alternate credentials")]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        if ($Credential -ne [System.Management.Automation.PSCredential]::Empty)
        {
            $wshcred_user = $Credential.GetNetworkCredential().UserName
            $wshcred_pwd  = $Credential.GetNetworkCredential().Password
        }
        $netobj = New-Object -com WScript.Network
        $results = @()
    }
    PROCESS
    {
        $results += $InputObject
    }
    END
    {
        Foreach ($result in $results)
        {
            if ($Credential -ne [System.Management.Automation.PSCredential]::Empty)
            {
                $SecChannel = "\\$($result.ComputerName)\IPC`$"
                Write-Verbose -Message ('Remote Command Results {0}: Starting secure channel - {1}' -f $ComputerName,$SecChannel)
                $netobj.mapnetworkdrive("", $SecChannel, "false", $wshcred_user, $wshcred_pwd)
                $cmdResultArray = Get-Content $result.RemoteOutputFullSharePath
                if (!$LeaveRemoteFile)
                {
                    Remove-Item $result.RemoteOutputFullSharePath
                }
                $netobj.RemoveNetworkDrive($SecChannel)
            }
            else
            {
                #$netobj.mapnetworkdrive("", $SecChannel, "false")
                $cmdResultArray = Get-Content $result.RemoteOutputFullSharePath
                if (!$LeaveRemoteFile)
                {
                    Remove-Item $result.RemoteOutputFullSharePath
                }
            }
            $result | Add-Member -MemberType NoteProperty -Name 'CommandResults' -Value $cmdResultArray            
        }
        $InputObject
    }
}

Function Get-VSSInfoFromRemoteCommandResults
{
    <#
    .SYNOPSIS
        Converts the results of vssadmin list writer into powershell friendly objects.
    .DESCRIPTION
        Converts the results of vssadmin list writer into powershell friendly objects.
    .PARAMETER InputObject
        Object or array of objects returned from Get-RemoteCommandResults
    .EXAMPLE
        PS > $a = Get-VSSInfoFromRemoteCommandResults $cmdresults

        Description
        -----------
        Gather and store the results of the remotely run command output generated from New-RemoteCommand

        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        1.0.0 - 09/19/2013
        - Initial release
    
        ** This is a supplement function to New-RemoteCommand and Get-RemoteCommandResults **
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage='Object or array of objects returned from Get-RemoteCommandResults')]
        $InputObject
    )
    BEGIN
    {
        $VSSResults = @()
        $Results = @()
    }
    PROCESS
    {
        $Results += $InputObject
    }
    END
    {
        Foreach ($result in $Results)
        {
            $VSSWriters = @()
            $output = $result.CommandResults
            for ($i=0; $i -lt $output.Count; $i++)
            {        if ($output[$i] -match 'Writer name')
                {
                    $vssprops = @{
                        'WriterName' = [regex]::match($output[$i],'(?<=:)(.+)').value
                        'WriterID' = [regex]::match($output[$i+1],'(?<=:)(.+)').value
                        'WriterInstanceID' = [regex]::match($output[$i+2],'(?<=:)(.+)').value
                        'State' = [regex]::match($output[$i+3],'(?<=:)(.+)').value
                        'LastError' = [regex]::match($output[$i+4],'(?<=:)(.+)').value
                    }
                    $VSSWriters += New-Object PSObject -Property $vssprops
                    $i = ($i + 4)
                }
            }
            $VSSResultProps = @{
                'PSComputerName' = $result.PSComputerName
                'PSDateTime' = $result.PSDateTime
                'ComputerName' = $result.ComputerName
                'VSSWriters' = $VSSWriters
            }
            $VSSResults += New-Object PSObject -Property $VSSResultProps
        }
        $VSSResults
    }
}

Function Get-HostFileInfoFromRemoteCommandResults
{
    <#
    .SYNOPSIS
        Converts the contents of a hosts file into powershell friendly objects.
    .DESCRIPTION
        Converts the contents of a hosts file into powershell friendly objects.
    .PARAMETER InputObject
        Object or array of objects returned from Get-RemoteCommandResults
    .EXAMPLE
        PS > $Command = 'cmd.exe /C type %SystemRoot%\system32\drivers\etc\hosts'
        PS > $runcmd = @(New-RemoteCommand -RemoteCMD $command -Verbose)
        PS > $results = Get-RemoteCommandResults -InputObject $runcmd -Verbose
        PS > $HostResults = Get-HostFileInfoFromRemoteCommandResults -InputObject $results
        PS > $HostResults.HostEntries | 
               Select @{n='Computer';e={$HostResults.ComputerName}},IP,HostEntry

        Description
        -----------
        Displays all active hosts entries for the local machine.

        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        1.0.0 - 09/19/2013
        - Initial release
    
        ** This is a supplement function to New-RemoteCommand and Get-RemoteCommandResults **
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage='Object or array of objects returned from Get-RemoteCommandResults')]
        $InputObject
    )
    BEGIN
    {
        $HostEntryResults = @()
        $Results = @()
    }
    PROCESS
    {
        $Results += $InputObject
    }
    END
    {
        Foreach ($result in $Results)
        {
            $HostsEntries = @()
            $output = $result.CommandResults
            for ($i=0; $i -lt $output.Count; $i++)
            {
                
                [regex]$r="\S"
                
                #strip out any lines beginning with # and blank lines
                if  ((($r.Match($output[$i])).value -ne "#") -and 
                      ($output[$i] -notmatch "^\s+$") -and 
                      ($output[$i].Length -gt 0))

                {
                    $output[$i] -match "(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<HOSTNAME>.+$)" | Out-Null
                    $hostsentryprops = @{
                        'IP' = $matches.ip
                        'HostEntry' = $matches.hostname
                    }
                    $HostsEntries += New-Object PSObject -Property $hostsentryprops
                }
            }
            $HostsProps = @{
                'PSComputerName' = $result.PSComputerName
                'PSDateTime' = $result.PSDateTime
                'ComputerName' = $result.ComputerName
                'HostEntries' = $HostsEntries
            }
            $HostEntryResults += New-Object PSObject -Property $HostsProps
        }
        $HostEntryResults
    }
}

Function Get-DNSCacheInfoFromRemoteCommandResults
{
    <#
    .SYNOPSIS
        
    .DESCRIPTION
        
    .PARAMETER InputObject
        Object or array of objects returned from Get-RemoteCommandResults
    .EXAMPLE
        <Placeholder>
        
        Description
        -----------
        <Placeholder>

        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        1.0.0 - 09/20/2013
        - Initial release
    
        ** This is a supplement function to New-RemoteCommand and Get-RemoteCommandResults **
    #>
    [CmdletBinding()]
    PARAM
    (
        [Parameter(HelpMessage='Object or array of objects returned from Get-RemoteCommandResults')]
        $InputObject
    )
    BEGIN
    {
        $DNSCacheResults = @()
        $Results = @()
        $DNSTypes = @{
            '1' = 'A'
            '2' = 'NS'
            '5' = 'CNAME'
            '6' = 'SOA'
            '12' = 'PTR'
            '15' = 'MX'
            '16' = 'TXT'
            '17' = 'RP'
            '18' = 'AFSDB'
            '24' = 'SIG'
            '25' = 'KEY'
            '28' = 'AAAA'
            '29' = 'LOC'
            '33' = 'SRV'
            '35' = 'NAPTR'
            '36' = 'KX'
            '37' = 'CERT'
            '39' = 'DNAME'
            '42' = 'APL'
            '43' = 'DS'
            '44' = 'SSHFP'
            '45' = 'IPSECKEY'
            '46' = 'RRSIG'
            '47' = 'NSEC'
            '48' = 'DNSKEY'
            '49' = 'DHCID'
            '50' = 'NSEC3'
            '51' = 'NSEC3PARAM'
            '52' = 'TLSA'
            '55' = 'HIP'
            '99' = 'SPF'
            '249' = 'TKEY'
            '250' = 'TSIG'
            '257' = 'CAA'
            '32768' = 'TA'
            '32769' = 'DLV'
        }
    }
    PROCESS
    {
        $Results += $InputObject
    }
    END
    {
        Foreach ($result in $Results)
        {
            $CacheEntries = @()
            $entry = $result.CommandResults -match 'Record '
            $entry.count
            for ($i=0; $i -lt $entry.Count; $i+=3)
            {
                $cacheentryprops = @{
                  Name=$entry[$i].toString().Split(":")[1].Trim()
                  Type=$DNSTypes[($entry[$i+1].toString().Split(":")[1].Trim())]
                  Value=$entry[$i+2].toString().Split(":")[1].Trim()
                }
                $CacheEntries += New-Object PSObject -Property $cacheentryprops
            }
            $DNSCacheResultProp = @{
                'PSComputerName' = $result.PSComputerName
                'PSDateTime' = $result.PSDateTime
                'ComputerName' = $result.ComputerName
                'CacheEntries' = $CacheEntries
            }
            $DNSCacheResults += New-Object PSObject -Property $DNSCacheResultProp
        }
        $DNSCacheResults
    }
}

Function Format-HTMLTable 
{
    <# 
    .SYNOPSIS 
        Format-HTMLTable - Selectively color elements of of an html table based on column value or even/odd rows.
     
    .DESCRIPTION 
        Create an html table and colorize individual cells or rows of an array of objects 
        based on row header and value. Optionally, you can also modify an existing html 
        document or change only the styles of even or odd rows.
     
    .PARAMETER InputObject 
        An array of objects (ie. (Get-process | select Name,Company) 
     
    .PARAMETER  Column 
        The column you want to modify. (Note: If the parameter ColorizeMethod is not set to ByValue the 
        Column parameter is ignored)

    .PARAMETER ScriptBlock
        Used to perform custom cell evaluations such as -gt -lt or anything else you need to check for in a
        table cell element. The scriptblock must return either $true or $false and is, by default, just
        a basic -eq comparisson. You must use the variables as they are used in the following example.
        (Note: If the parameter ColorizeMethod is not set to ByValue the ScriptBlock parameter is ignored)

        [scriptblock]$scriptblock = {[int]$args[0] -gt [int]$args[1]}

        $args[0] will be the cell value in the table
        $args[1] will be the value to compare it to

        Strong typesetting is encouraged for accuracy.

    .PARAMETER  ColumnValue 
        The column value you will modify if ScriptBlock returns a true result. (Note: If the parameter 
        ColorizeMethod is not set to ByValue the ColumnValue parameter is ignored).
     
    .PARAMETER  Attr 
        The attribute to change should ColumnValue be found in the Column specified. 
        - A good example is using "style" 

    .PARAMETER  AttrValue 
        The attribute value to set when the ColumnValue is found in the Column specified 
        - A good example is using "background: red;" 
    
    .PARAMETER DontUseLinq
        Use inline C# Linq calls for html table manipulation by default. This is extremely fast but requires .NET 3.5 or above.
        Use this switch to force using non-Linq method (xml) first.
        
    .PARAMETER Fragment
        Return only the HTML table instead of a full document.
    
    .EXAMPLE 
        This will highlight the process name of Dropbox with a red background. 

        $TableStyle = @'
        <title>Process Report</title> 
            <style>             
            BODY{font-family: Arial; font-size: 8pt;} 
            H1{font-size: 16px;} 
            H2{font-size: 14px;} 
            H3{font-size: 12px;} 
            TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;} 
            TH{border: 1px solid black; background: #dddddd; padding: 5px; color: #000000;} 
            TD{border: 1px solid black; padding: 5px;} 
            </style>
        '@

        $tabletocolorize = Get-Process | Select Name,CPU,Handles | ConvertTo-Html -Head $TableStyle
        $colorizedtable = Format-HTMLTable $tabletocolorize -Column "Name" -ColumnValue "Dropbox" -Attr "style" -AttrValue "background: red;" -HTMLHead $TableStyle
        $colorizedtable = Format-HTMLTable $colorizedtable -Attr "style" -AttrValue "background: grey;" -ColorizeMethod 'ByOddRows' -WholeRow:$true
        $colorizedtable = Format-HTMLTable $colorizedtable -Attr "style" -AttrValue "background: yellow;" -ColorizeMethod 'ByEvenRows' -WholeRow:$true
        $colorizedtable | Out-File "$pwd/testreport.html" 
        ii "$pwd/testreport.html"

    .EXAMPLE 
        Using the same $TableStyle variable above this will create a table of top 5 processes by memory usage,
        color the background of a whole row yellow for any process using over 150Mb and red if over 400Mb.

        $tabletocolorize = $(get-process | select -Property ProcessName,Company,@{Name="Memory";Expression={[math]::truncate($_.WS/ 1Mb)}} | Sort-Object Memory -Descending | Select -First 5 ) 

        [scriptblock]$scriptblock = {[int]$args[0] -gt [int]$args[1]}
        $testreport = Format-HTMLTable $tabletocolorize -Column "Memory" -ColumnValue 150 -Attr "style" -AttrValue "background:yellow;" -ScriptBlock $ScriptBlock -HTMLHead $TableStyle -WholeRow $true
        $testreport = Format-HTMLTable $testreport -Column "Memory" -ColumnValue 400 -Attr "style" -AttrValue "background:red;" -ScriptBlock $ScriptBlock -WholeRow $true
        $testreport | Out-File "$pwd/testreport.html" 
        ii "$pwd/testreport.html"

        If you are going to convert something to html with convertto-html in powershell v2 there is 
        a bug where the header will show up as an asterick if you only are converting one object property. 

        This script is a modification of something I found by some rockstar named Jaykul at this site
        http://stackoverflow.com/questions/4559233/technique-for-selectively-formatting-data-in-a-powershell-pipeline-and-output-as

        .Net 3.5 or above is a requirement for using the Linq libraries.

    1.2 - 01/12/2014
        - Changed bool parameters to switch
        - Added DontUseLinq parameter
        - Changed function name to be less goofy sounding
        - Updated the add-type custom namespace from Huddled to CustomLinq
        - Added help messages to fuction parameters.
        - Added xml method for function to use if the linq assemblies couldn't be loaded (slower but still works)
    1.1 - 11/13/2013
        - Removed the explicit definition of Csharp3 in the add-type definition to allow windows 2012 compatibility.
        - Fixed up parameters to remove assumed values
        - Added try/catch around add-type to detect and prevent errors when processing on systems which do not support
          the linq assemblies.
    .LINK 
        http://www.the-little-things.net 
    #> 
    [CmdletBinding( DefaultParameterSetName = "StringSet")] 
    param ( 
        [Parameter( Position=0,
                    Mandatory=$true, 
                    ValueFromPipeline=$true, 
                    ParameterSetName="ObjectSet",
                    HelpMessage="Array of psobjects to convert to an html table and modify.")]
        [Object[]]
        $InputObject,
        
        [Parameter( Position=0, 
                    Mandatory=$true, 
                    ValueFromPipeline=$true, 
                    ParameterSetName="StringSet",
                    HelpMessage="HTML table to modify.")] 
        [string]
        $InputString='',
        
        [Parameter( HelpMessage="Column name to compare values against when updating the table by value.")]
        [string]
        $Column="Name",
        
        [Parameter( HelpMessage="Value to compare when updating the table by value.")]
        $ColumnValue=0,
        
        [Parameter( HelpMessage="Custom script block for table conditions to search for when updating the table by value.")]
        [scriptblock]
        $ScriptBlock = {[string]$args[0] -eq [string]$args[1]}, 
        
        [Parameter( Mandatory=$true,
                    HelpMessage="Attribute to append to table element.")] 
        [string]
        $Attr,
        
        [Parameter( Mandatory=$true,
                    HelpMessage="Value to assign to attribute.")] 
        [string]
        $AttrValue,
        
        [Parameter( HelpMessage="By default the td element (individual table cell) is modified. This switch causes the attributes for the entire row (tr) to update instead.")] 
        [switch]
        $WholeRow,
        
        [Parameter( HelpMessage="If an array of object is converted to html prior to modification this is the head data which will get prepended to it.")]
        [string]
        $HTMLHead='<title>HTML Table</title>',
        
        [Parameter( HelpMessage="Method for table modification. ByValue uses column name lookups. ByEvenRows/ByOddRows are exactly as they sound.")]
        [ValidateSet('ByValue','ByEvenRows','ByOddRows')]
        [string]
        $ColorizeMethod='ByValue',
        
        [Parameter( HelpMessage="Use inline C# Linq calls for html table manipulation by default. Extremely fast but requires .NET 3.5 or above to work. Use this switch to force using non-Linq method (xml) first.")] 
        [switch]
        $DontUseLinq,
        
        [Parameter( HelpMessage="Return only the html table element.")] 
        [switch]
        $Fragment
        )
    
    BEGIN 
    {
        $LinqAssemblyLoaded = $false
        if (-not $DontUseLinq)
        {
            # A little note on Add-Type, this adds in the assemblies for linq with some custom code. The first time this 
            # is run in your powershell session it is compiled and loaded into your session. If you run it again in the same
            # session and the code was not changed at all, powershell skips the command (otherwise recompiling code each time
            # the function is called in a session would be pretty ineffective so this is by design). If you make any changes
            # to the code, even changing one space or tab, it is detected as new code and will try to reload the same namespace
            # which is not allowed and will cause an error. So if you are debugging this or changing it up, either change the
            # namespace as well or exit and restart your powershell session.
            #
            # And some notes on the actual code. It is my first jump into linq (or C# for that matter) so if it looks not so 
            # elegant or there is a better way to do this I'm all ears. I define four methods which names are self-explanitory:
            # - GetElementByIndex
            # - GetElementByValue
            # - GetOddElements
            # - GetEvenElements
            $LinqCode = @"
            public static System.Collections.Generic.IEnumerable<System.Xml.Linq.XElement> GetElementByIndex(System.Xml.Linq.XContainer doc, System.Xml.Linq.XName element, int index)
            {
                return doc.Descendants(element)
                        .Where  (e => e.NodesBeforeSelf().Count() == index)
                        .Select (e => e);
            }
            public static System.Collections.Generic.IEnumerable<System.Xml.Linq.XElement> GetElementByValue(System.Xml.Linq.XContainer doc, System.Xml.Linq.XName element, string value)
            {
                return  doc.Descendants(element) 
                        .Where  (e => e.Value == value)
                        .Select (e => e);
            }
            public static System.Collections.Generic.IEnumerable<System.Xml.Linq.XElement> GetOddElements(System.Xml.Linq.XContainer doc, System.Xml.Linq.XName element)
            {
                return doc.Descendants(element)
                        .Where  ((e,i) => i % 2 != 0)
                        .Select (e => e);
            }
            public static System.Collections.Generic.IEnumerable<System.Xml.Linq.XElement> GetEvenElements(System.Xml.Linq.XContainer doc, System.Xml.Linq.XName element)
            {
                return doc.Descendants(element)
                        .Where  ((e,i) => i % 2 == 0)
                        .Select (e => e);
            }
"@
            try
            {
                Add-Type -ErrorAction SilentlyContinue `
                -ReferencedAssemblies System.Xml, System.Xml.Linq `
                -UsingNamespace System.Linq `
                -Name XUtilities `
                -Namespace CustomLinq `
                -MemberDefinition $LinqCode
                
                $LinqAssemblyLoaded = $true
            }
            catch
            {
                $LinqAssemblyLoaded = $false
            }
        }
        $tablepattern = [regex]'(?s)(<table.*?>.*?</table>)'
        $headerpattern = [regex]'(?s)(^.*?)(?=<table)'
        $footerpattern = [regex]'(?s)(?<=</table>)(.*?$)'
        $header = ''
        $footer = ''
    }
    PROCESS 
    { }
    END 
    { 
        if ($psCmdlet.ParameterSetName -eq 'ObjectSet')
        {
            # If we sent an array of objects convert it to html first
            $InputString = ($InputObject | ConvertTo-Html -Head $HTMLHead)
        }

        # Convert our data to x(ht)ml 
        if ($LinqAssemblyLoaded)
        {
            $xml = [System.Xml.Linq.XDocument]::Parse("$InputString")
        }
        else
        {
            # old school xml is kinda dumb so we strip out only the table to work with then 
            # add the header and footer back on later.
            $firsttable = [Regex]::Match([string]$InputString, $tablepattern).Value
            $header = [Regex]::Match([string]$InputString, $headerpattern).Value
            $footer = [Regex]::Match([string]$InputString, $footerpattern).Value
            [xml]$xml = [string]$firsttable
        }
        switch ($ColorizeMethod) {
            "ByEvenRows" {
                if ($LinqAssemblyLoaded)
                {
                    $evenrows = [CustomLinq.XUtilities]::GetEvenElements($xml, "{http://www.w3.org/1999/xhtml}tr")    
                    foreach ($row in $evenrows)
                    {
                        $row.SetAttributeValue($Attr, $AttrValue)
                    }
                }
                else
                {
                    $rows = $xml.GetElementsByTagName('tr')
                    for($i=0;$i -lt $rows.count; $i++)
                    {
                        if (($i % 2) -eq 0 ) {
                           $newattrib=$xml.CreateAttribute($Attr)
                           $newattrib.Value=$AttrValue
                           [void]$rows.Item($i).Attributes.Append($newattrib)
                        }
                    }
                }
            }
            "ByOddRows" {
                if ($LinqAssemblyLoaded)
                {
                    $oddrows = [CustomLinq.XUtilities]::GetOddElements($xml, "{http://www.w3.org/1999/xhtml}tr")    
                    foreach ($row in $oddrows)
                    {
                        $row.SetAttributeValue($Attr, $AttrValue)
                    }
                }
                else
                {
                    $rows = $xml.GetElementsByTagName('tr')
                    for($i=0;$i -lt $rows.count; $i++)
                    {
                        if (($i % 2) -ne 0 ) {
                           $newattrib=$xml.CreateAttribute($Attr)
                           $newattrib.Value=$AttrValue
                           [void]$rows.Item($i).Attributes.Append($newattrib)
                        }
                    }
                }
            }
            "ByValue" {
                if ($LinqAssemblyLoaded)
                {
                    # Find the index of the column you want to format 
                    $ColumnLoc = [CustomLinq.XUtilities]::GetElementByValue($xml, "{http://www.w3.org/1999/xhtml}th",$Column) 
                    $ColumnIndex = $ColumnLoc | Foreach-Object{($_.NodesBeforeSelf() | Measure-Object).Count} 
            
                    # Process each xml element based on the index for the column we are highlighting 
                    switch([CustomLinq.XUtilities]::GetElementByIndex($xml, "{http://www.w3.org/1999/xhtml}td", $ColumnIndex)) 
                    { 
                        {$(Invoke-Command $ScriptBlock -ArgumentList @($_.Value, $ColumnValue))} {
                            if ($WholeRow)
                            {
                                $_.Parent.SetAttributeValue($Attr, $AttrValue)
                            }
                            else
                            {
                                $_.SetAttributeValue($Attr, $AttrValue)
                            }
                        }
                    }
                }
                else
                {
                    $colvalindex = 0
                    $headerindex = 0
                    $xml.GetElementsByTagName('th') | Foreach {
                        if ($_.'#text' -eq $Column) 
                        {
                            $colvalindex=$headerindex
                        }
                        $headerindex++
                    }
                    $rows = $xml.GetElementsByTagName('tr')
                    $cols = $xml.GetElementsByTagName('td')
                    $colvalindexstep = ($cols.count /($rows.count - 1))
                    for($i=0;$i -lt $rows.count; $i++)
                    {
                        $index = ($i * $colvalindexstep) + $colvalindex
                        $colval = $cols.Item($index).'#text'
                        if ($(Invoke-Command $ScriptBlock -ArgumentList @($colval, $ColumnValue))) {
                            $newattrib=$xml.CreateAttribute($Attr)
                            $newattrib.Value=$AttrValue
                            if ($WholeRow)
                            {
                                [void]$rows.Item($i).Attributes.Append($newattrib)
                            }
                            else
                            {
                                [void]$cols.Item($index).Attributes.Append($newattrib)
                            }
                        }
                    }
                }
            }
        }
        if ($LinqAssemblyLoaded)
        {
            if ($Fragment)
            {
                [string]$htmlresult = $xml.Document.ToString()
                if ([string]$htmlresult -match $tablepattern)
                {
                    [string]$matches[0]
                }
            }
            else
            {
                [string]$xml.Document.ToString()
            }
        }
        else
        {
            if ($Fragment)
            {
                [string]($xml.OuterXml | Out-String)
            }
            else
            {
                [string]$htmlresult = $header + ($xml.OuterXml | Out-String) + $footer
                return $htmlresult
            }
        }
    }
}

Function Get-OUResults
{
    #----------------------------------------------
    #region Import Assemblies
    #----------------------------------------------
    [void][Reflection.Assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][Reflection.Assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    [void][Reflection.Assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][Reflection.Assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][Reflection.Assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [void][Reflection.Assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    #endregion Import Assemblies

    #Define a Param block to use custom parameters in the project
    #Param ($CustomParameter)

    function Main {
        Param ([String]$Commandline)
        if((Call-MainForm_pff) -eq "OK")
        {
            
        }
        
        $global:ExitCode = 0 #Set the exit code for the Packager
    }
    #endregion Source: Startup.pfs

    #region Source: MainForm.pff
    function Call-MainForm_pff
    {
        #----------------------------------------------
        #region Import the Assemblies
        #----------------------------------------------
        [void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        [void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        [void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
        [void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        [void][reflection.assembly]::Load("System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        [void][reflection.assembly]::Load("System.Xml, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        [void][reflection.assembly]::Load("System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
        [void][reflection.assembly]::Load("System.Windows.Forms.DataVisualization, Version=3.5.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
        #endregion Import Assemblies

        #----------------------------------------------
        #region Generated Form Objects
        #----------------------------------------------
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $MainForm = New-Object 'System.Windows.Forms.Form'
        $buttonOK = New-Object 'System.Windows.Forms.Button'
        $buttonLoadOU = New-Object 'System.Windows.Forms.Button'
        $groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
        $radiobuttonDomainControllers = New-Object 'System.Windows.Forms.RadioButton'
        $radiobuttonWorkstations = New-Object 'System.Windows.Forms.RadioButton'
        $radiobuttonServers = New-Object 'System.Windows.Forms.RadioButton'
        $radiobuttonAll = New-Object 'System.Windows.Forms.RadioButton'
        $listboxComputers = New-Object 'System.Windows.Forms.ListBox'
        $labelOrganizationalUnit = New-Object 'System.Windows.Forms.Label'
        $txtOU = New-Object 'System.Windows.Forms.TextBox'
        $btnSelectOU = New-Object 'System.Windows.Forms.Button'
        $timerFadeIn = New-Object 'System.Windows.Forms.Timer'
        $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
        #endregion Generated Form Objects

        #----------------------------------------------
        # User Generated Script
        #----------------------------------------------
        
        $OnLoadFormEvent={
            $Results = @()
        }
        
        $form1_FadeInLoad={
            #Start the Timer to Fade In
            $timerFadeIn.Start()
            $MainForm.Opacity = 0
        }
        
        $timerFadeIn_Tick={
            #Can you see me now?
            if($MainForm.Opacity -lt 1)
            {
                $MainForm.Opacity += 0.1
                
                if($MainForm.Opacity -ge 1)
                {
                    #Stop the timer once we are 100% visible
                    $timerFadeIn.Stop()
                }
            }
        }
        
        #region Control Helper Functions
        function Load-ListBox 
        {
        <#
            .SYNOPSIS
                This functions helps you load items into a ListBox or CheckedListBox.
        
            .DESCRIPTION
                Use this function to dynamically load items into the ListBox control.
        
            .PARAMETER  ListBox
                The ListBox control you want to add items to.
        
            .PARAMETER  Items
                The object or objects you wish to load into the ListBox's Items collection.
        
            .PARAMETER  DisplayMember
                Indicates the property to display for the items in this control.
            
            .PARAMETER  Append
                Adds the item(s) to the ListBox without clearing the Items collection.
            
            .EXAMPLE
                Load-ListBox $ListBox1 "Red", "White", "Blue"
            
            .EXAMPLE
                Load-ListBox $listBox1 "Red" -Append
                Load-ListBox $listBox1 "White" -Append
                Load-ListBox $listBox1 "Blue" -Append
            
            .EXAMPLE
                Load-ListBox $listBox1 (Get-Process) "ProcessName"
        #>
            Param (
                [ValidateNotNull()]
                [Parameter(Mandatory=$true)]
                [System.Windows.Forms.ListBox]$ListBox,
                [ValidateNotNull()]
                [Parameter(Mandatory=$true)]
                $Items,
                [Parameter(Mandatory=$false)]
                [string]$DisplayMember,
                [switch]$Append
            )
            
            if(-not $Append)
            {
                $listBox.Items.Clear()    
            }
            
            if($Items -is [System.Windows.Forms.ListBox+ObjectCollection])
            {
                $listBox.Items.AddRange($Items)
            }
            elseif ($Items -is [Array])
            {
                $listBox.BeginUpdate()
                foreach($obj in $Items)
                {
                    $listBox.Items.Add($obj)
                }
                $listBox.EndUpdate()
            }
            else
            {
                $listBox.Items.Add($Items)    
            }
        
            $listBox.DisplayMember = $DisplayMember    
        }
        
        #endregion
        
        $btnSelectOU_Click={
            $SelectedOU = Select-OU
            $txtOU.Text = $SelectedOU.OUDN
        }
        
        $buttonLoadOU_Click={
            if ($txtOU.Text -ne '')
            {
                $root = [ADSI]"LDAP://$($txtOU.Text)"
                $search = [adsisearcher]$root
                if ($radiobuttonAll.Checked)
                {
                    $Search.Filter = '(&(objectClass=computer))'
                }
                if ($radiobuttonServers.Checked)
                {
                    $Search.Filter = '(&(objectClass=computer)(OperatingSystem=Windows*Server*))'
                }
                if ($radiobuttonWorkstations.Checked)
                {
                    $Search.Filter = '(&(objectClass=computer)(!OperatingSystem=Windows*Server*))'
                }
                if ($radiobuttonDomainControllers.Checked)
                {
                    $search.Filter = '(&(&(objectCategory=computer)(objectClass=computer))(UserAccountControl:1.2.840.113556.1.4.803:=8192))'
                }
                
                $colResults = $Search.FindAll()
                $OUResults = @()
                foreach ($i in $colResults)
                {
                    $OUResults += [string]$i.Properties.Item('Name')
                }
        
               # $OUResults | Measure-Object
                Load-ListBox $listBoxComputers $OUResults
            }
        }
        
        $buttonOK_Click={
            if ($listboxComputers.Items.Count -eq 0)
            {
                #[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
                [void][System.Windows.Forms.MessageBox]::Show('No computers listed. If you selected an OU already then please click the Load button.',"Nothing to do")
            }
            else
            {
                $MainForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
            }
        
        }
            # --End User Generated Script--
        #----------------------------------------------
        #region Generated Events
        #----------------------------------------------
        
        $Form_StateCorrection_Load=
        {
            #Correct the initial state of the form to prevent the .Net maximized form issue
            $MainForm.WindowState = $InitialFormWindowState
        }
        
        $Form_StoreValues_Closing=
        {
            #Store the control values
            $script:MainForm_radiobuttonDomainControllers = $radiobuttonDomainControllers.Checked
            $script:MainForm_radiobuttonWorkstations = $radiobuttonWorkstations.Checked
            $script:MainForm_radiobuttonServers = $radiobuttonServers.Checked
            $script:MainForm_radiobuttonAll = $radiobuttonAll.Checked
            $script:MainForm_listboxComputersSelected = $listboxComputers.SelectedItems
            $script:MainForm_listboxComputersAll = $listboxComputers.Items
            $script:MainForm_txtOU = $txtOU.Text
        }

        $Form_Cleanup_FormClosed=
        {
            #Remove all event handlers from the controls
            try
            {
                $buttonOK.remove_Click($buttonOK_Click)
                $buttonLoadOU.remove_Click($buttonLoadOU_Click)
                $btnSelectOU.remove_Click($btnSelectOU_Click)
                $MainForm.remove_Load($form1_FadeInLoad)
                $timerFadeIn.remove_Tick($timerFadeIn_Tick)
                $MainForm.remove_Load($Form_StateCorrection_Load)
                $MainForm.remove_Closing($Form_StoreValues_Closing)
                $MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
            }
            catch [Exception]
            { }
        }
        #endregion Generated Events

        #----------------------------------------------
        #region Generated Form Code
        #----------------------------------------------
        #
        # MainForm
        #
        $MainForm.Controls.Add($buttonOK)
        $MainForm.Controls.Add($buttonLoadOU)
        $MainForm.Controls.Add($groupbox1)
        $MainForm.Controls.Add($listboxComputers)
        $MainForm.Controls.Add($labelOrganizationalUnit)
        $MainForm.Controls.Add($txtOU)
        $MainForm.Controls.Add($btnSelectOU)
        $MainForm.ClientSize = '627, 255'
        $MainForm.FormBorderStyle = 'FixedDialog'
        $MainForm.MaximizeBox = $False
        $MainForm.MinimizeBox = $False
        $MainForm.Name = "MainForm"
        $MainForm.StartPosition = 'CenterScreen'
        $MainForm.Tag = ""
        $MainForm.Text = "System Selection"
        $MainForm.add_Load($form1_FadeInLoad)
        #
        # buttonOK
        #
        $buttonOK.Location = '547, 230'
        $buttonOK.Name = "buttonOK"
        $buttonOK.Size = '75, 23'
        $buttonOK.TabIndex = 8
        $buttonOK.Text = "OK"
        $buttonOK.UseVisualStyleBackColor = $True
        $buttonOK.add_Click($buttonOK_Click)
        #
        # buttonLoadOU
        #
        $buttonLoadOU.Location = '288, 52'
        $buttonLoadOU.Name = "buttonLoadOU"
        $buttonLoadOU.Size = '58, 20'
        $buttonLoadOU.TabIndex = 7
        $buttonLoadOU.Text = "Load -->"
        $buttonLoadOU.UseVisualStyleBackColor = $True
        $buttonLoadOU.add_Click($buttonLoadOU_Click)
        #
        # groupbox1
        #
        $groupbox1.Controls.Add($radiobuttonDomainControllers)
        $groupbox1.Controls.Add($radiobuttonWorkstations)
        $groupbox1.Controls.Add($radiobuttonServers)
        $groupbox1.Controls.Add($radiobuttonAll)
        $groupbox1.Location = '13, 52'
        $groupbox1.Name = "groupbox1"
        $groupbox1.Size = '136, 111'
        $groupbox1.TabIndex = 6
        $groupbox1.TabStop = $False
        $groupbox1.Text = "Computer Type"
        #
        # radiobuttonDomainControllers
        #
        $radiobuttonDomainControllers.Location = '7, 79'
        $radiobuttonDomainControllers.Name = "radiobuttonDomainControllers"
        $radiobuttonDomainControllers.Size = '117, 25'
        $radiobuttonDomainControllers.TabIndex = 3
        $radiobuttonDomainControllers.Text = "Domain Controllers"
        $radiobuttonDomainControllers.UseVisualStyleBackColor = $True
        #
        # radiobuttonWorkstations
        #
        $radiobuttonWorkstations.Location = '7, 59'
        $radiobuttonWorkstations.Name = "radiobuttonWorkstations"
        $radiobuttonWorkstations.Size = '104, 25'
        $radiobuttonWorkstations.TabIndex = 2
        $radiobuttonWorkstations.Text = "Workstations"
        $radiobuttonWorkstations.UseVisualStyleBackColor = $True
        #
        # radiobuttonServers
        #
        $radiobuttonServers.Location = '7, 40'
        $radiobuttonServers.Name = "radiobuttonServers"
        $radiobuttonServers.Size = '104, 24'
        $radiobuttonServers.TabIndex = 1
        $radiobuttonServers.Text = "Servers"
        $radiobuttonServers.UseVisualStyleBackColor = $True
        #
        # radiobuttonAll
        #
        $radiobuttonAll.Checked = $True
        $radiobuttonAll.Location = '7, 20'
        $radiobuttonAll.Name = "radiobuttonAll"
        $radiobuttonAll.Size = '104, 24'
        $radiobuttonAll.TabIndex = 0
        $radiobuttonAll.TabStop = $True
        $radiobuttonAll.Text = "All"
        $radiobuttonAll.UseVisualStyleBackColor = $True
        #
        # listboxComputers
        #
        $listboxComputers.FormattingEnabled = $True
        $listboxComputers.Location = '352, 25'
        $listboxComputers.Name = "listboxComputers"
        $listboxComputers.SelectionMode = 'MultiSimple'
        $listboxComputers.Size = '270, 199'
        $listboxComputers.Sorted = $True
        $listboxComputers.TabIndex = 5
        #
        # labelOrganizationalUnit
        #
        $labelOrganizationalUnit.Location = '76, 5'
        $labelOrganizationalUnit.Name = "labelOrganizationalUnit"
        $labelOrganizationalUnit.Size = '125, 17'
        $labelOrganizationalUnit.TabIndex = 4
        $labelOrganizationalUnit.Text = "Organizational Unit"
        #
        # txtOU
        #
        $txtOU.Location = '76, 25'
        $txtOU.Name = "txtOU"
        $txtOU.ReadOnly = $True
        $txtOU.Size = '270, 20'
        $txtOU.TabIndex = 3
        #
        # btnSelectOU
        #
        $btnSelectOU.Location = '13, 25'
        $btnSelectOU.Name = "btnSelectOU"
        $btnSelectOU.Size = '58, 20'
        $btnSelectOU.TabIndex = 2
        $btnSelectOU.Text = "Select"
        $btnSelectOU.UseVisualStyleBackColor = $True
        $btnSelectOU.add_Click($btnSelectOU_Click)
        #
        # timerFadeIn
        #
        $timerFadeIn.add_Tick($timerFadeIn_Tick)
        #endregion Generated Form Code

        #----------------------------------------------

        #Save the initial state of the form
        $InitialFormWindowState = $MainForm.WindowState
        #Init the OnLoad event to correct the initial state of the form
        $MainForm.add_Load($Form_StateCorrection_Load)
        #Clean up the control events
        $MainForm.add_FormClosed($Form_Cleanup_FormClosed)
        #Store the control values when form is closing
        $MainForm.add_Closing($Form_StoreValues_Closing)
        #Show the Form
        return $MainForm.ShowDialog()

    }
    #endregion Source: MainForm.pff

    #region Source: Globals.ps1
        #--------------------------------------------
        # Declare Global Variables and Functions here
        #--------------------------------------------
        
        #Sample function that provides the location of the script
        function Get-ScriptDirectory
        { 
            if($hostinvocation -ne $null)
            {
                Split-Path $hostinvocation.MyCommand.path
            }
            else
            {
                Split-Path $script:MyInvocation.MyCommand.Path
            }
        }
        
        #Sample variable that provides the location of the script
        [string]$ScriptDirectory = Get-ScriptDirectory
        
        function Select-OU
        {
            <#
              .SYNOPSIS
              .DESCRIPTION
              .PARAMETER <Parameter-Name>
              .EXAMPLE
              .INPUTS
              .OUTPUTS
                My Script Name.ps1 Version 1.0 by Thanatos on 7/13/2013
              .LINK
            #>
            [CmdletBinding()]
            param(
            )
            #$ErrorActionPreference = 'Stop'
            #Set-StrictMode -Version Latest
        
            #region Show / Hide PowerShell Window
            $WindowDisplay = @"
        using System;
        using System.Runtime.InteropServices;

        namespace Window
        {
          public class Display
          {
            [DllImport("Kernel32.dll")]
            private static extern IntPtr GetConsoleWindow();

            [DllImport("user32.dll")]
            private static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

            public static bool Hide()
            {
              return ShowWindowAsync(GetConsoleWindow(), 0);
            }

            public static bool Show()
            {
              return ShowWindowAsync(GetConsoleWindow(), 5);
            }
          }
        }
"@
            Add-Type -TypeDefinition $WindowDisplay
            #endregion
            #[Void][Window.Display]::Hide()
        
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
        
            #region ******** Select OrganizationalUnit Dialog ******** 
        
            <#
              $SelectOU_Form.Tag.SearchRoot
                Current: Current Domain Ony, Default Value
                Forest: All Domains in the Forest
                Specific OU: DN of a Spedific OU
              
              $SelectOU_Form.Tag.IncludeContainers
                $False: Only Display OU's, Default Value
                $True: Display OU's and Contrainers
              
              $SelectOU_Form.Tag.SelectedOUName
                The Returned Name of the Selected OU
                
              $SelectOU_Form.Tag.SelectedOUDName
                The Returned Name of the Selected OU
        
              if ($SelectOU_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
              {
                Write-Host -Object "Selected OU Name = $($SelectOU_Form.Tag.SelectedOUName)"
                Write-Host -Object "Selected OU DName = $($SelectOU_Form.Tag.SelectedOUDName)"
              }
              else
              {
                Write-Host -Object "Selected OU Name = None"
                Write-Host -Object "Selected OU DName = None"
              }
            #>
        
            $SelectOUSpacer = 8
        
            #region $SelectOU_Form = System.Windows.Forms.Form
            $SelectOU_Form = New-Object -TypeName System.Windows.Forms.Form
            $SelectOU_Form.ControlBox = $False
            $SelectOU_Form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $SelectOU_Form.Font = New-Object -TypeName System.Drawing.Font ("Verdana",9,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point)
            $SelectOU_Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
            $SelectOU_Form.MaximizeBox = $False
            $SelectOU_Form.MinimizeBox = $False
            $SelectOU_Form.Name = "SelectOU_Form"
            $SelectOU_Form.ShowInTaskbar = $False
            $SelectOU_Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
            $SelectOU_Form.Tag = New-Object -TypeName PSObject -Property @{ 
                                                                    'SearchRoot' = "Current"
                                                                    'IncludeContainers' = $False
                                                                    'SelectedOUName' = "None"
                                                                    'SelectedOUDName' = "None"
                                                                   }
            $SelectOU_Form.Text = "Select OrganizationalUnit"
            #endregion
        
            #region function Load-SelectOU_Form
            function Load-SelectOU_Form ()
            {
                <#
                .SYNOPSIS
                  Load event for the SelectOU_Form Control
                .DESCRIPTION
                  Load event for the SelectOU_Form Control
                .PARAMETER Sender
                   The Form Control that fired the Event
                .PARAMETER EventArg
                   The Event Arguments for the Event
                .EXAMPLE
                   Load-SelectOU_Form -Sender $SelectOU_Form -EventArg $_
                .INPUTS
                .OUTPUTS
                .LINK
              #>
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $True)]
                    [object]$Sender,
                    [Parameter(Mandatory = $True)]
                    [object]$EventArg
                )
                try
                {
                    $SelectOU_Domain_ComboBox.Items.Clear()
                    $SelectOU_OrgUnit_TreeView.Nodes.Clear()
                    switch ($SelectOU_Form.Tag.SearchRoot)
                    {
                        "Current"
                        {
                            $SelectOU_Domain_GroupBox.Visible = $False
                            $SelectOU_OrgUnit_GroupBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,$SelectOUSpacer)
                            $SelectOU_Domain_ComboBox.Items.AddRange($([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | Select-Object -Property @{ "Name" = "Text"; "Expression" = { $_.Name } },@{ "Name" = "Value"; "Expression" = { $_.GetDirectoryEntry().distinguishedName } },@{ "Name" = "Domain"; "Expression" = { $Null } }))
                            $SelectOU_Domain_ComboBox.SelectedIndex = 0
                            break
                        }
                        "Forest"
                        {
                            $SelectOU_Domain_GroupBox.Visible = $True
                            $SelectOU_OrgUnit_GroupBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOU_Domain_GroupBox.Bottom + $SelectOUSpacer))
                            $SelectOU_Domain_ComboBox.Items.AddRange($($([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Domains | Select-Object -Property @{ "Name" = "Text"; "Expression" = { $_.Name } },@{ "Name" = "Value"; "Expression" = { $_.GetDirectoryEntry().distinguishedName } },@{ "Name" = "Domain"; "Expression" = { $Null } }))
                            $SelectOU_Domain_ComboBox.SelectedItem = $SelectOU_Domain_ComboBox.Items | Where-Object -FilterScript { $_.Value -eq $([adsi]"").distinguishedName }
                            break
                        }
                        Default
                        {
                            $SelectOU_Domain_GroupBox.Visible = $False
                            $SelectOU_OrgUnit_GroupBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,$SelectOUSpacer)
                            $SelectOU_Domain_ComboBox.Items.AddRange($([adsi]"LDAP://$($SelectOU_Form.Tag.SearchRoot)" | Select-Object -Property @{ "Name" = "Text"; "Expression" = { $_.Name } },@{ "Name" = "Value"; "Expression" = { $_.distinguishedName } },@{ "Name" = "Domain"; "Expression" = { $Null } }))
                            $SelectOU_Domain_ComboBox.SelectedIndex = 0
                            break
                        }
                    }
                    $SelectOU_OK_Button.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOU_OrgUnit_GroupBox.Bottom + $SelectOUSpacer))
                    $SelectOU_Cancel_Button.Location = New-Object -TypeName System.Drawing.Point (($SelectOU_OK_Button.Right + $SelectOUSpacer),($SelectOU_OrgUnit_GroupBox.Bottom + $SelectOUSpacer))
                    $SelectOU_Form.ClientSize = New-Object -TypeName System.Drawing.Size (($($SelectOU_Form.Controls[$SelectOU_Form.Controls.Count - 1]).Right + $SelectOUSpacer),($($SelectOU_Form.Controls[$SelectOU_Form.Controls.Count - 1]).Bottom + $SelectOUSpacer))
                }
                catch
                {
                    Write-Warning ('Load-SelectOU_Form Error: {0}' -f $_.Exception.Message)
                    $SelectOU_OK_Button.Enabled = $false
                }
            }
            #endregion
        
            $SelectOU_Form.add_Load({ Load-SelectOU_Form -Sender $SelectOU_Form -EventArg $_ })
        
            #region $SelectOU_Domain_GroupBox = System.Windows.Forms.GroupBox
            $SelectOU_Domain_GroupBox = New-Object -TypeName System.Windows.Forms.GroupBox
            $SelectOU_Form.Controls.Add($SelectOU_Domain_GroupBox)
            $SelectOU_Domain_GroupBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,$SelectOUSpacer)
            $SelectOU_Domain_GroupBox.Name = "SelectOU_Domain_GroupBox"
            $SelectOU_Domain_GroupBox.Text = "Select Domain"
            #endregion
        
            #region $SelectOU_Domain_ComboBox = System.Windows.Forms.ComboBox
            $SelectOU_Domain_ComboBox = New-Object -TypeName System.Windows.Forms.ComboBox
            $SelectOU_Domain_GroupBox.Controls.Add($SelectOU_Domain_ComboBox)
            $SelectOU_Domain_ComboBox.AutoSize = $True
            $SelectOU_Domain_ComboBox.DisplayMember = "Text"
            $SelectOU_Domain_ComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
            $SelectOU_Domain_ComboBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOUSpacer + (($SelectOU_Domain_GroupBox.Font.Size * ($SelectOU_Domain_GroupBox.CreateGraphics().DpiY)) / 72)))
            $SelectOU_Domain_ComboBox.Name = "SelectOU_Domain_ComboBox"
            $SelectOU_Domain_ComboBox.ValueMember = "Value"
            $SelectOU_Domain_ComboBox.Width = 400
            #endregion
        
            #region function SelectedIndexChanged-SelectOU_Domain_ComboBox
            function SelectedIndexChanged-SelectOU_Domain_ComboBox ()
            {
                <#
                .SYNOPSIS
                  SelectedIndexChanged event for the SelectOU_Domain_ComboBox Control
                .DESCRIPTION
                  SelectedIndexChanged event for the SelectOU_Domain_ComboBox Control
                .PARAMETER Sender
                   The Form Control that fired the Event
                .PARAMETER EventArg
                   The Event Arguments for the Event
                .EXAMPLE
                   SelectedIndexChanged-SelectOU_Domain_ComboBox -Sender $SelectOU_Domain_ComboBox -EventArg $_
                .INPUTS
                .OUTPUTS
                .LINK
              #>
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $True)]
                    [object]$Sender,
                    [Parameter(Mandatory = $True)]
                    [object]$EventArg
                )
                try
                {
                    if ($SelectOU_Domain_ComboBox.SelectedIndex -gt -1)
                    {
                        $SelectOU_OrgUnit_TreeView.Nodes.Clear()
                        if ([string]::IsNullOrEmpty($SelectOU_Domain_ComboBox.SelectedItem.Domain))
                        {
                            $TempNode = New-Object System.Windows.Forms.TreeNode ($SelectOU_Domain_ComboBox.SelectedItem.Text,[System.Windows.Forms.TreeNode[]](@( "$*$")))
                            $TempNode.Tag = $SelectOU_Domain_ComboBox.SelectedItem.Value
                            $TempNode.Checked = $True
                            $SelectOU_OrgUnit_TreeView.Nodes.Add($TempNode)
                            $SelectOU_OrgUnit_TreeView.Nodes.Item(0).Expand()
                            $SelectOU_Domain_ComboBox.SelectedItem.Domain = $SelectOU_OrgUnit_TreeView.Nodes.Item(0)
                        }
                        else
                        {
                            $SelectOU_OrgUnit_TreeView.Nodes.Add($SelectOU_Domain_ComboBox.SelectedItem.Domain)
                        }
                    }
                }
                catch
                {
                }
            }
            #endregion
        
            $SelectOU_Domain_ComboBox.add_SelectedIndexChanged({ SelectedIndexChanged-SelectOU_Domain_ComboBox -Sender $SelectOU_Domain_ComboBox -EventArg $_ })
        
            $SelectOU_Domain_GroupBox.ClientSize = New-Object -TypeName System.Drawing.Size (($($SelectOU_Domain_GroupBox.Controls[$SelectOU_Domain_GroupBox.Controls.Count - 1]).Right + $SelectOUSpacer),($($SelectOU_Domain_GroupBox.Controls[$SelectOU_Domain_GroupBox.Controls.Count - 1]).Bottom + $SelectOUSpacer))
        
            #region $SelectOU_OrgUnit_GroupBox = System.Windows.Forms.GroupBox
            $SelectOU_OrgUnit_GroupBox = New-Object -TypeName System.Windows.Forms.GroupBox
            $SelectOU_Form.Controls.Add($SelectOU_OrgUnit_GroupBox)
            $SelectOU_OrgUnit_GroupBox.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOU_Domain_GroupBox.Bottom + $SelectOUSpacer))
            $SelectOU_OrgUnit_GroupBox.Name = "SelectOU_OrgUnit_GroupBox"
            $SelectOU_OrgUnit_GroupBox.Text = "Select OrganizationalUnit"
            $SelectOU_OrgUnit_GroupBox.Width = $SelectOU_Domain_GroupBox.Width
            #endregion
        
            #region $SelectOU_OrgUnit_TreeView = System.Windows.Forms.TreeView
            $SelectOU_OrgUnit_TreeView = New-Object -TypeName System.Windows.Forms.TreeView
            $SelectOU_OrgUnit_GroupBox.Controls.Add($SelectOU_OrgUnit_TreeView)
            $SelectOU_OrgUnit_TreeView.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOUSpacer + (($SelectOU_OrgUnit_GroupBox.Font.Size * ($SelectOU_OrgUnit_GroupBox.CreateGraphics().DpiY)) / 72)))
            $SelectOU_OrgUnit_TreeView.Name = "SelectOU_OrgUnit_TreeView"
            $SelectOU_OrgUnit_TreeView.Size = New-Object -TypeName System.Drawing.Size (($SelectOU_OrgUnit_GroupBox.ClientSize.Width - ($SelectOUSpacer * 2)),300)
            #endregion
        
            #region function BeforeExpand-SelectOU_OrgUnit_TreeView
            function BeforeExpand-SelectOU_OrgUnit_TreeView ()
            {
                <#
                .SYNOPSIS
                  BeforeExpand event for the SelectOU_OrgUnit_TreeView Control
                .DESCRIPTION
                  BeforeExpand event for the SelectOU_OrgUnit_TreeView Control
                .PARAMETER Sender
                   The Form Control that fired the Event
                .PARAMETER EventArg
                   The Event Arguments for the Event
                .EXAMPLE
                   BeforeExpand-SelectOU_OrgUnit_TreeView -Sender $SelectOU_OrgUnit_TreeView -EventArg $_
                .INPUTS
                .OUTPUTS
                .LINK
              #>
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $True)]
                    [object]$Sender,
                    [Parameter(Mandatory = $True)]
                    [object]$EventArg
                )
                try
                {
                    if ($EventArg.Node.Checked)
                    {
                        $EventArg.Node.Checked = $False
                        $EventArg.Node.Nodes.Clear()
                        if ($SelectOU_Form.Tag.IncludeContainers)
                        {
                            $MySearcher = [adsisearcher]"(|((&(objectClass=organizationalunit)(objectCategory=organizationalUnit))(&(objectClass=container)(objectCategory=container))(&(objectClass=builtindomain)(objectCategory=builtindomain))))"
                        }
                        else
                        {
                            $MySearcher = [adsisearcher]"(&(objectClass=organizationalunit)(objectCategory=organizationalUnit))"
                        }
                        $MySearcher.SearchRoot = [adsi]"LDAP://$($EventArg.Node.Tag)"
                        $MySearcher.SearchScope = "OneLevel"
                        $MySearcher.Sort = New-Object -TypeName System.DirectoryServices.SortOption ("Name","Ascending")
                        $MySearcher.SizeLimit = 0
                        [void]$MySearcher.PropertiesToLoad.Add("name")
                        [void]$MySearcher.PropertiesToLoad.Add("distinguishedname")
                        foreach ($Item in $MySearcher.FindAll())
                        {
                            $TempNode = New-Object System.Windows.Forms.TreeNode ($Item.Properties["name"][0],[System.Windows.Forms.TreeNode[]](@( "$*$")))
                            $TempNode.Tag = $Item.Properties["distinguishedname"][0]
                            $TempNode.Checked = $True
                            $EventArg.Node.Nodes.Add($TempNode)
                        }
                    }
                }
                catch
                {
                    Write-Host $Error[0]
                }
            }
            #endregion
            $SelectOU_OrgUnit_TreeView.add_BeforeExpand({ BeforeExpand-SelectOU_OrgUnit_TreeView -Sender $SelectOU_OrgUnit_TreeView -EventArg $_ })
        
            $SelectOU_OrgUnit_GroupBox.ClientSize = New-Object -TypeName System.Drawing.Size (($($SelectOU_OrgUnit_GroupBox.Controls[$SelectOU_OrgUnit_GroupBox.Controls.Count - 1]).Right + $SelectOUSpacer),($($SelectOU_OrgUnit_GroupBox.Controls[$SelectOU_OrgUnit_GroupBox.Controls.Count - 1]).Bottom + $SelectOUSpacer))
        
            #region $SelectOU_OK_Button = System.Windows.Forms.Button
            $SelectOU_OK_Button = New-Object -TypeName System.Windows.Forms.Button
            $SelectOU_Form.Controls.Add($SelectOU_OK_Button)
            $SelectOU_OK_Button.AutoSize = $True
            $SelectOU_OK_Button.Location = New-Object -TypeName System.Drawing.Point ($SelectOUSpacer,($SelectOU_OrgUnit_GroupBox.Bottom + $SelectOUSpacer))
            $SelectOU_OK_Button.Name = "SelectOU_OK_Button"
            $SelectOU_OK_Button.Text = "OK"
            $SelectOU_OK_Button.Width = ($SelectOU_OrgUnit_GroupBox.Width - $SelectOUSpacer) / 2
            #endregion
        
            #region function Click-SelectOU_OK_Button
            function Click-SelectOU_OK_Button
            {
                <#
                .SYNOPSIS
                  Click event for the SelectOU_OK_Button Control
                .DESCRIPTION
                  Click event for the SelectOU_OK_Button Control
                .PARAMETER Sender
                   The Form Control that fired the Event
                .PARAMETER EventArg
                   The Event Arguments for the Event
                .EXAMPLE
                   Click-SelectOU_OK_Button -Sender $SelectOU_OK_Button -EventArg $_
                .INPUTS
                .OUTPUTS
                .LINK
              #>
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $True)]
                    [object]$Sender,
                    [Parameter(Mandatory = $True)]
                    [object]$EventArg
                )
                try
                {
                    if (-not [string]::IsNullOrEmpty($SelectOU_OrgUnit_TreeView.SelectedNode))
                    {
                        $SelectOU_Form.Tag.SelectedOUName = $SelectOU_OrgUnit_TreeView.SelectedNode.Text
                        $SelectOU_Form.Tag.SelectedOUDName = $SelectOU_OrgUnit_TreeView.SelectedNode.Tag
                        $SelectOU_Form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    }
                }
                catch
                {
                    Write-Host $Error[0]
                }
            }
            #endregion
            $SelectOU_OK_Button.add_Click({ Click-SelectOU_OK_Button -Sender $SelectOU_OK_Button -EventArg $_ })
        
            #region $SelectOU_Cancel_Button = System.Windows.Forms.Button
            $SelectOU_Cancel_Button = New-Object -TypeName System.Windows.Forms.Button
            $SelectOU_Form.Controls.Add($SelectOU_Cancel_Button)
            $SelectOU_Cancel_Button.AutoSize = $True
            $SelectOU_Cancel_Button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $SelectOU_Cancel_Button.Location = New-Object -TypeName System.Drawing.Point (($SelectOU_OK_Button.Right + $SelectOUSpacer),($SelectOU_OrgUnit_GroupBox.Bottom + $SelectOUSpacer))
            $SelectOU_Cancel_Button.Name = "SelectOU_Cancel_Button"
            $SelectOU_Cancel_Button.Text = "Cancel"
            $SelectOU_Cancel_Button.Width = ($SelectOU_OrgUnit_GroupBox.Width - $SelectOUSpacer) / 2
            #endregion
        
            $SelectOU_Form.ClientSize = New-Object -TypeName System.Drawing.Size (($($SelectOU_Form.Controls[$SelectOU_Form.Controls.Count - 1]).Right + $SelectOUSpacer),($($SelectOU_Form.Controls[$SelectOU_Form.Controls.Count - 1]).Bottom + $SelectOUSpacer))
            #endregion
        
            $ReturnedOU = @{
                'OUName' = $null;
                'OUDN' = $null
            }
            if ($SelectOU_Form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $ReturnedOU.OUName = $($SelectOU_Form.Tag.SelectedOUName)
                $ReturnedOU.OUDN = $($SelectOU_Form.Tag.SelectedOUDName)
            }
            New-Object PSobject -Property $ReturnedOU
        }
        
        
    #endregion Source: Globals.ps1

    #Start the application
    Main ($CommandLine)
        New-Object PSObject -Property @{
                    'AllResults' = $MainForm_listboxComputersAll
                    'SelectedResults' = $MainForm_listboxComputersSelected
                }
}
#endregion Functions - Serial or Utility

#region Functions - Asset Report Project
Function Create-ReportSection
{
    #** This function is specific to this script and does all kinds of bad practice
    #   stuff. Use this function neither to learn from or judge me please. **
    #
    #   That being said, this function pretty much does all the report output
    #   options and layout magic. It depends upon the report layout hash and
    #   $HTMLRendering global variable hash.
    #
    #   This function generally shouldn't need to get changed in any way to customize your
    #   reports.
    #
    # .EXAMPLE
    #    Create-ReportSection -Rpt $ReportSection -Asset $Asset 
    #                         -Section 'Summary' -TableTitle 'System Summary'
    
    [CmdletBinding()]
    param(
        [parameter()]
        $Rpt,
        
        [parameter()]
        [string]$Asset,

        [parameter()]
        [string]$Section,
        
        [parameter()]
        [string]$TableTitle        
    )
    BEGIN
    {
        Add-Type -AssemblyName System.Web
    }
    PROCESS
    {}
    END
    {
        # Get our section type
        $RptSection = $Rpt['Sections'][$Section]
        $SectionType = $RptSection['Type']
        
        switch ($SectionType)
        {
            'Section'     # default to a data section
            {
                Write-Verbose -Message ('Create-ReportSection: {0}: {1}' -f $Asset,$Section)
                $ReportElementSource = @($RptSection['AllData'][$Asset])
                if ((($ReportElementSource.Count -gt 0) -and 
                     ($ReportElementSource[0] -ne $null)) -or 
                     ($RptSection['ShowSectionEvenWithNoData']))
                {
                    $SourceProperties = $RptSection['ReportTypes'][$ReportType]['Properties']
                    
                    #region report section type and layout
                    $TableType = $RptSection['ReportTypes'][$ReportType]['TableType']
                    $ContainerType = $RptSection['ReportTypes'][$ReportType]['ContainerType']

                    switch ($TableType)
                    {
                        'Horizontal' 
                        {
                            $PropertyCount = $SourceProperties.Count
                            $Vertical = $false
                        }
                        'Vertical' {
                            $PropertyCount = 2
                            $Vertical = $true
                        }
                        default {
                            if ((($SourceProperties.Count) -ge $HorizontalThreshold))
                            {
                                $PropertyCount = 2
                                $Vertical = $true
                            }
                            else
                            {
                                $PropertyCount = $SourceProperties.Count
                                $Vertical = $false
                            }
                        }
                    }
                    #endregion report section type and layout
                    
                    $Table = ''
                    If ($PropertyCount -ne 0)
                    {
                        # Create our future HTML table header
                        $SectionLink = '<a href="{0}"></a>' -f $Section
                        $TableHeader = $HTMLRendering['TableTitle'][$HTMLMode] -replace '<0>',$PropertyCount
                        $TableHeader = $SectionLink + ($TableHeader -replace '<1>',$TableTitle)

                        if ($RptSection.ContainsKey('Comment'))
                        {
                            if ($RptSection['Comment'] -ne $false)
                            {
                                $TableComment = $HTMLRendering['TableComment'][$HTMLMode] -replace '<0>',$PropertyCount
                                $TableComment = $TableComment -replace '<1>',$RptSection['Comment']
                                $TableHeader = $TableHeader + $TableComment
                            }
                        }
                        
                        $AllTableElements = @()
                        Foreach ($TableElement in $ReportElementSource)
                        {
                            $AllTableElements += $TableElement | Select $SourceProperties
                        }

                        # If we are creating a vertical table it takes a bit of transformational work
                        if ($Vertical)
                        {
                            $Count = 0
                            foreach ($Element in $AllTableElements)
                            {
                                $Count++
                                $SingleElement = [string]($Element | ConvertTo-PropertyValue | ConvertTo-Html)
                                if ($Rpt['Configuration']['PostProcessingEnabled'])
                                {
                                    # Add class elements for even/odd rows
                                    $SingleElement = Format-HTMLTable $SingleElement -ColorizeMethod 'ByEvenRows' -Attr 'class' -AttrValue 'even' -WholeRow
                                    $SingleElement = Format-HTMLTable $SingleElement -ColorizeMethod 'ByOddRows' -Attr 'class' -AttrValue 'odd' -WholeRow
                                    if ($RptSection.ContainsKey('PostProcessing') -and 
                                       ($RptSection['PostProcessing'].Value -ne $false))
                                    {
                                        $Rpt['Configuration']['PostProcessingEnabled'].Value
                                        $Table = $(Invoke-Command ([scriptblock]::Create($RptSection['PostProcessing'])))
                                    }
                                }
                                $SingleElement = [Regex]::Match($SingleElement, "(?s)(?<=</tr>)(.+)(?=</table>)").Value
                                $Table += $SingleElement 
                                if ($Count -ne $AllTableElements.Count)
                                {
                                    $Table += '<tr class="divide"><td></td><td></td></tr>'
                                }
                            }
                            $Table = '<table class="list">' + $TableHeader + $Table + '</table>'
                            $Table = [System.Web.HttpUtility]::HtmlDecode($Table)
                        }
                        # Otherwise it is a horizontal table
                        else
                        {
                            [string]$Table = $AllTableElements | ConvertTo-Html
                            if ($Rpt['Configuration']['PostProcessingEnabled'] -and ($AllTableElements.Count -gt 0))
                            {
                                # Add class elements for even/odd rows
                                $Table = Format-HTMLTable $Table -ColorizeMethod 'ByEvenRows' -Attr 'class' -AttrValue 'even' -WholeRow
                                $Table = Format-HTMLTable $Table -ColorizeMethod 'ByOddRows' -Attr 'class' -AttrValue 'odd' -WholeRow
                                if ($RptSection.ContainsKey('PostProcessing'))
                                
                                {
                                    if ($RptSection.ContainsKey('PostProcessing'))
                                    {
                                        if ($RptSection['PostProcessing'] -ne $false)
                                        {
                                            $Table = $(Invoke-Command ([scriptblock]::Create($RptSection['PostProcessing'])))
                                        }
                                    }
                                }
                            }
                            # This will gank out everything after the first colgroup so we can replace it with our own spanned header
                            $Table = [Regex]::Match($Table, "(?s)(?<=</colgroup>)(.+)(?=</table>)").Value
                            $Table = '<table>' + $TableHeader + $Table + '</table>'
                            $Table = [System.Web.HttpUtility]::HtmlDecode(($Table))
                        }
                    }
                    
                    $Output = $HTMLRendering['SectionContainers'][$HTMLMode][$ContainerType]['Head'] + 
                              $Table + $HTMLRendering['SectionContainers'][$HTMLMode][$ContainerType]['Tail']
                    $Output
                }
            }
            'SectionBreak'
            {
                if ($Rpt['Configuration']['SkipSectionBreaks'] -eq $false)
                {
                    $Output = $HTMLRendering['CustomSections'][$SectionType] -replace '<0>',$TableTitle
                    $Output
                }
            }
        }
    }
}

Function ReportProcessing
{
    [CmdletBinding()]
    param
    (
        [Parameter( HelpMessage="Report body, typically in HTML format",
                    ValueFromPipeline=$true,
                    Mandatory=$true )]
        [string]
        $Report = ".",
        
        [Parameter( HelpMessage="Email server to relay report through")]
        [string]
        $EmailRelay = ".",
        
        [Parameter( HelpMessage="Email sender")]
        [string]
        $EmailSender='systemreport@localhost',
        
        [Parameter( HelpMessage="Email recipient")]
        [string]
        $EmailRecipient='default@yourdomain.com',
        
        [Parameter( HelpMessage="Email subject")]
        [string]
        $EmailSubject='System Report',
        
        [Parameter( HelpMessage="Email body as html")]
        [switch]
        $EmailBodyAsHTML=$true,
        
        [Parameter( HelpMessage="Send email of resulting report?")]
        [switch]
        $SendMail,
        
        [Parameter( HelpMessage="Force email to be sent anonymously?")]
        [switch]
        $ForceAnonymous,

        [Parameter( HelpMessage="Save the report?")]
        [switch]
        $SaveReport,
        
        [Parameter( HelpMessage="Save the report as a PDF. If the PDF library is not available the default format, HTML, will be used instead.")]
        [switch]
        $SaveAsPDF,
        
        [Parameter( HelpMessage="If saving the report, what do you want to call it?")]
        [string]
        $ReportName="Report.html"
    )
    BEGIN
    {
        if ($SaveReport)
        {
            $ReportFormat = 'HTML'
        }
        if ($SaveAsPDF)
        {
            $PdfGenerator = "$((Get-Location).Path)\NReco.PdfGenerator.dll"
            if (Test-Path $PdfGenerator)
            {
                $ReportFormat = 'PDF'
                $PdfGenerator = "$((Get-Location).Path)\NReco.PdfGenerator.dll"
                $Assembly = [Reflection.Assembly]::LoadFrom($PdfGenerator) #| Out-Null
                $PdfCreator = New-Object NReco.PdfGenerator.HtmlToPdfConverter
            }
        }
    }
    PROCESS
    {
        if ($SaveReport)
        {
            switch ($ReportFormat) {
                'PDF' {
                    $ReportOutput = $PdfCreator.GeneratePdf([string]$Report)
                    Add-Content -Value $ReportOutput `
                                -Encoding byte `
                                -Path ($ReportName -replace '.html','.pdf')
                }
                'HTML' {
                    $Report | Out-File $ReportName
                }
            }
        }
        if ($Sendmail)
        {
            if ($ForceAnonymous)
            {
                #$User = 'anonymous'
                $Pass = ConvertTo-SecureString –String 'anonymous' –AsPlainText -Force
                $Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $pass
                #$Creds = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $user, $pword
                send-mailmessage -from $EmailSender -to $EmailRecipient -subject $EmailSubject `
                    -BodyAsHTML:$EmailBodyAsHTML -Body $Report -priority Normal -smtpServer $EmailRelay -Credential $creds
            }
            else
            {
                send-mailmessage -from $EmailSender -to $EmailRecipient -subject $EmailSubject `
                -BodyAsHTML:$EmailBodyAsHTML -Body $Report -priority Normal -smtpServer $EmailRelay
            }
        }
    }
    END
    {
    }
}

Function Get-RemoteSystemInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter( HelpMessage='Computer or computers to return information about',
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter( Mandatory=$true,
                    HelpMessage='The custom report hash variable structure you plan to report upon')]
        $ReportContainer,
        
        [Parameter( HelpMessage='List of sorted report elements within ReportContainer',
                    Mandatory=$true)]
        $SortedRpts,
        
        [Parameter(HelpMessage='Maximum number of concurrent threads')]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage='Timeout before a thread stops trying to gather the information')]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
        
        [parameter( HelpMessage='Pass an alternate credential' )]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter( HelpMessage='View visual progress bar.')]
        [switch]
        $ShowProgress
    )
    BEGIN
    {
        $ComputerNames = @()
        $_credsplat = @{
            'Verbose' = ($PSBoundParameters['Verbose'] -eq $true)
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        $_summarysplat = @{
            'Verbose' = ($PSBoundParameters['Verbose'] -eq $true)
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        $_hphardwaresplat = @{
            'Verbose' = ($PSBoundParameters['Verbose'] -eq $true)
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        $_dellhardwaresplat = @{
            'Verbose' = ($PSBoundParameters['Verbose'] -eq $true)
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        $_credsplatserial = @{            
            'Verbose' = ($PSBoundParameters['Verbose'] -eq $true)
        }
        
        if ($Credential -ne $null)
        {
            $_credsplat.Credential = $Credential
            $_summarysplat.Credential = $Credential
            $_hphardwaresplat.Credential = $Credential
            $_dellhardwaresplat.Credential = $Credential
            $_credsplatserial.Credential = $Credential
        }
    }
    PROCESS
    {
        if ($ComputerName -ne $null)
        {
            $ComputerNames += $ComputerName
        }
    }
    END
    {
        if ($ComputerNames.Count -eq 0)
        {
            $ComputerNames += $env:computername
        }
        $_credsplat.ComputerName = $ComputerNames
        $_summarysplat.ComputerName = $ComputerNames
        $_hphardwaresplat.ComputerName = $ComputerNames
        $_dellhardwaresplat.ComputerName = $ComputerNames
        
        #region Multithreaded Information Gathering
        $HPHardwareHealthTesting = $false   # Only run this test if at least one of the several HP health tests are enabled
        $DellHardwareHealthTesting = $false   # Only run this test if at least one of the several HP health tests are enabled
        # Call multiple runspace supported info gathering functions where supported and create
        # splats for functions which gather multiple section data.
        $SortedRpts | %{ 
            switch ($_.Section) {
                'ExtendedSummary' {
                    $NTPInfo = @(Get-RemoteRegistryInformation @_credsplat `
                                        -Key $reg_NTPSettings)
                    $NTPInfo = ConvertTo-HashArray $NTPInfo 'PSComputerName'
                    $ExtendedInfo = @(Get-RemoteRegistryInformation @_credsplat `
                                        -Key $reg_ExtendedInfo)
                    $ExtendedInfo = ConvertTo-HashArray $ExtendedInfo 'PSComputerName'
                }
                'LocalGroupMembership' {
                    $LocalGroupMembership = @(Get-RemoteGroupMembership @_credsplat)
                    $LocalGroupMembership = ConvertTo-HashArray $LocalGroupMembership 'PSComputerName'
                }
                'Memory' {
                    $_summarysplat.IncludeMemoryInfo = $true
                }
                'Disk' {
                    $_summarysplat.IncludeDiskInfo = $true
                }
                'Network' {
                    $_summarysplat.IncludeNetworkInfo = $true
                }
                'RouteTable' {
                    $RouteTables = @(Get-RemoteRouteTable @_credsplat)
                    $RouteTables = ConvertTo-HashArray $RouteTables 'PSComputerName'
                }
                'ShareSessionInfo' {
                    $ShareSessions = @(Get-RemoteShareSessionInformation @_credsplat)
                    $ShareSessions = ConvertTo-HashArray $ShareSessions 'PSComputerName'
                }
                'ProcessesByMemory' {
                    # Processes by memory
                    $ProcsByMemory = @(Get-RemoteProcessInformation @_credsplat)
                    $ProcsByMemory = ConvertTo-HashArray $ProcsByMemory 'PSComputerName'
                }
                'StoppedServices' {
                    $Filter = "(StartMode='Auto') AND (State='Stopped')"
                    $StoppedServices = @(Get-RemoteServiceInformation @_credsplat -Filter $Filter)
                    $StoppedServices = ConvertTo-HashArray $StoppedServices 'PSComputerName'
                }
                'NonStandardServices' {
                    $Filter = "NOT startName LIKE 'NT AUTHORITY%' AND NOT startName LIKE 'localsystem'"
                    $NonStandardServices = @(Get-RemoteServiceInformation @_credsplat -Filter $Filter)
                    $NonStandardServices = ConvertTo-HashArray $NonStandardServices 'PSComputerName'
                }
                'Applications' {
                    $InstalledPrograms = @(Get-RemoteInstalledPrograms @_credsplat)
                    $InstalledPrograms = ConvertTo-HashArray $InstalledPrograms 'PSComputerName'
                }
                'InstalledUpdates' {
                    $InstalledUpdates = @(Get-MultiRunspaceWMIObject @_credsplat `
                                                -Class Win32_QuickFixEngineering)
                    $InstalledUpdates = ConvertTo-HashArray $InstalledUpdates 'PSComputerName'
                }
                'EnvironmentVariables' {
                    $EnvironmentVars = @(Get-MultiRunspaceWMIObject @_credsplat `
                                                -Class Win32_Environment)
                    $EnvironmentVars = ConvertTo-HashArray $EnvironmentVars 'PSComputerName'
                }
                'StartupCommands' {
                    $StartupCommands = @(Get-MultiRunspaceWMIObject @_credsplat `
                                                -Class win32_startupcommand)
                    $StartupCommands = ConvertTo-HashArray $StartupCommands 'PSComputerName'
                }
                'ScheduledTasks' {
                    $ScheduledTasks = @(Get-RemoteScheduledTasks @_credsplat)
                    $ScheduledTasks = ConvertTo-HashArray $ScheduledTasks 'PSComputerName'
                }
                'Printers' {
                    $Printers = @(Get-RemoteInstalledPrinters @_credsplat)
                    $Printers = ConvertTo-HashArray $Printers 'PSComputerName'
                }
                'VSSWriters' {
                    $Command = 'cmd.exe /C vssadmin list writers'
                    $vsswritercmd = @(New-RemoteCommand @_credsplat -RemoteCMD $Command)
                    $vsswriterresults = Get-RemoteCommandResults @_credsplatserial `
                                                -InputObject $vsswritercmd
                    $VSSWriters = Get-VSSInfoFromRemoteCommandResults -InputObject $vsswriterresults
                    $VSSWriters = ConvertTo-HashArray $VSSWriters 'PSComputerName'
                }
                'HostsFile' {
                    $Command = 'cmd.exe /C type %SystemRoot%\system32\drivers\etc\hosts'
                    $hostsfilecmd = @(New-RemoteCommand @_credsplat -RemoteCMD $Command)
                    $hostsfileresults = Get-RemoteCommandResults @_credsplatserial `
                                                -InputObject $hostsfilecmd
                    $HostsFiles = Get-HostFileInfoFromRemoteCommandResults -InputObject $hostsfileresults
#                    if (($HostFiles.HostEntries).Count -gt 0)
#                    {
                        $HostsFiles = ConvertTo-HashArray $HostsFiles 'PSComputerName'
#                    }
                }
                'DNSCache' {
                    $Command = 'cmd.exe /C ipconfig /displaydns'
                    $dnscachecmd = @(New-RemoteCommand @_credsplat -RemoteCMD $Command)
                    $dnscachecmdresults = Get-RemoteCommandResults @_credsplatserial `
                                                -InputObject $dnscachecmd
                    $DNSCache = @(Get-DNSCacheInfoFromRemoteCommandResults -InputObject $dnscachecmdresults)
                    if (($DNSCache.CacheEntries).Count -gt 0)
                    {
                        $DNSCache = ConvertTo-HashArray $DNSCache 'PSComputerName'
                    }
                }
                'ShadowVolumes' {
                    $ShadowVolumes = @(Get-RemoteShadowCopyInformation @_credsplat)
                    $ShadowVolumes = ConvertTo-HashArray $ShadowVolumes 'PSComputerName'
                }
                'EventLogSettings' {
                    $EventLogSettings = @(Get-MultiRunspaceWMIObject @_credsplat `
                                                -Class win32_NTEventlogFile)
                    $EventLogSettings = ConvertTo-HashArray $EventLogSettings 'PSComputerName'
                }
                'Shares' {
                    $Shares = @(Get-MultiRunspaceWMIObject @_credsplat `
                                                -Class win32_Share)
                    $Shares = ConvertTo-HashArray $Shares 'PSComputerName'
                }
                'EventLogs' {
                    # Event log errors/warnings/audit failures
                    $EventLogs = @(Get-RemoteEventLogs @_credsplat -Hours $Option_EventLogPeriod)
                    $EventLogs = ConvertTo-HashArray $EventLogs 'PSComputerName'
                }
                'AppliedGPOs' {
                    $AppliedGPOs = @(Get-RemoteAppliedGPOs @_credsplat)
                    $AppliedGPOs = ConvertTo-HashArray $AppliedGPOs 'PSComputerName'
                }
                {$_ -match 'Firewall*'} {
                    $FirewallSettings = @(Get-RemoteFirewallStatus @_credsplat)
                    $FirewallSettings = ConvertTo-HashArray $FirewallSettings 'PSComputerName'
                }
                'WSUSSettings' {
                    # 31.39.1.252 settings
                    $WSUSSettings = @(Get-RemoteRegistryInformation @_credsplat -Key $reg_WSUSSettings)
                    $WSUSSettings = ConvertTo-HashArray $WSUSSettings 'PSComputerName'
                }
                'HP_GeneralHardwareHealth' {
                    $HPHardwareHealthTesting = $true
                }
                'HP_EthernetTeamHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeEthernetTeamHealth = $true
                }
                'HP_ArrayControllerHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeArrayControllerHealth = $true
                }
                'HP_EthernetHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeEthernetHealth = $true
                }
                'HP_FanHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeFanHealth = $true
                }
                'HP_HBAHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeHBAHealth = $true
                }
                'HP_PSUHealth' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludePSUHealth = $true
                }
                'HP_TempSensors' {
                    $HPHardwareHealthTesting = $true
                    $_hphardwaresplat.IncludeTempSensors = $true
                }
                'Dell_GeneralHardwareHealth' {
                    $DellHardwareHealthTesting = $true
                }
                'Dell_FanHealth' {
                    $DellHardwareHealthTesting = $true
                    $_dellhardwaresplat.FanHealthStatus = $true
                }
                'Dell_SensorHealth' {
                    $DellHardwareHealthTesting = $true
                    $_dellhardwaresplat.SensorStatus = $true
                }
                'Dell_TempSensorHealth' {
                    $DellHardwareHealthTesting = $true
                    $_dellhardwaresplat.TempSensorStatus = $true
                }
                'Dell_ESMLogs' {
                    $DellHardwareHealthTesting = $true
                    $_dellhardwaresplat.ESMLogStatus = $true
                }
            } 
        }
        $_summarysplat.ShowProgress = $ShowProgress
        $Assets = @(Get-ComputerAssetInformation @_summarysplat)
        
        # HP Server Health
        if ($HPHardwareHealthTesting)
        {
            $HPServerHealth = @(Get-HPServerhealth @_hphardwaresplat)
            $HPServerHealth = ConvertTo-HashArray $HPServerHealth 'PSComputerName'
        }
        if ($DellHardwareHealthTesting)
        {
            $DellServerHealth = @(Get-DellServerhealth @_dellhardwaresplat)
            $DellServerHealth = ConvertTo-HashArray $DellServerHealth 'PSComputerName'
        }
        #endregion
        
        #region Serial Information Gathering
        # Seperate our data out to its appropriate report section under 'AllData' as a hash key with 
        #   an array of objects/data as the key value.
        # This is also where you can gather and store report section data with non-multithreaded
        #  functions.
        Foreach ($AssetInfo in $Assets)
        {
            $SortedRpts | %{ 
            switch ($_.Section) {
                'Summary' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($AssetInfo | select *)
                }
                'ExtendedSummary' {
                    # we have to mash up the results of a few different reg entries for this one
                    $tmpobj = ConvertTo-PSObject `
                                -InputObject $ExtendedInfo[$AssetInfo.PScomputername].Registry `
                                -propname 'Key' -valname 'KeyValue'
                    $tmpobj2 = ConvertTo-PSObject `
                                -InputObject $NTPInfo[$AssetInfo.PScomputername].Registry `
                                -propname 'Key' -valname 'KeyValue'
                    $tmpobj | Add-Member -MemberType NoteProperty -Name 'NTPType' -Value $tmpobj2.Type
                    $tmpobj | Add-Member -MemberType NoteProperty -Name 'NTPServer' -Value $tmpobj2.NtpServer
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = @($tmpobj)
                }
                'LocalGroupMembership' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($LocalGroupMembership[$AssetInfo.PScomputername].GroupMembership)
                }
                'Disk' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = @($AssetInfo._Disks)
                }                    
                'Network' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        $AssetInfo._Network | Where {$_.ConnectionStatus}
                }
                'RouteTable' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($RouteTables[$AssetInfo.PScomputername].Routes |
                            Sort-Object 'Metric1')
                }
                'HostsFile' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($HostsFiles[$AssetInfo.PScomputername].HostEntries)
                }
                'DNSCache' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($DNSCache[$AssetInfo.PScomputername].CacheEntries)
                }
                'Memory' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($AssetInfo._MemorySlots)
                }
                'StoppedServices' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($StoppedServices[$AssetInfo.PScomputername].Services)
                }
                'NonStandardServices' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($NonStandardServices[$AssetInfo.PScomputername].Services)
                }
                'ProcessesByMemory' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($ProcsByMemory[$AssetInfo.PScomputername].Processes |
                            Sort WS -Descending |
                            Select -First $Option_TotalProcessesByMemory)
                }
                'EventLogSettings' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($EventLogSettings[$AssetInfo.PScomputername].WMIObjects)
                }
                'Shares' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($Shares[$AssetInfo.PScomputername].WMIObjects)
                }
                'DellWarrantyInformation' {
                    $_DellWarrantyInformation = Get-DellWarranty @_credsplatserial -ComputerName $AssetInfo.PSComputerName
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = @($_DellWarrantyInformation)
                }
                
                'Applications' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($InstalledPrograms[$AssetInfo.PScomputername].Programs | 
                            Sort-Object DisplayName)
                }
                
                'InstalledUpdates' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($InstalledUpdates[$AssetInfo.PScomputername].WMIObjects)
                }
                'EnvironmentVariables' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($EnvironmentVars[$AssetInfo.PScomputername].WMIObjects)
                }
                'StartupCommands' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($StartupCommands[$AssetInfo.PScomputername].WMIObjects)
                }
                'ScheduledTasks' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($ScheduledTasks[$AssetInfo.PScomputername].Tasks |
                            where {($_.State -ne 'Disabled') -and `
                                   ($_.Enabled) -and `
                                   ($_.NextRunTime -ne 'None') -and `
                                   (!$_.Hidden) -and `
                                   ($_.Author -ne 'Microsoft Corporation')} | 
                            Select Name,Author,Description,LastRunTime,NextRunTime,LastTaskDetails)
                }
                'Printers' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($Printers[$AssetInfo.PScomputername].Printers)
                }
                'VSSWriters' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($VSSWriters[$AssetInfo.PScomputername].VSSWriters)
                }
                'ShadowVolumes' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] =
                        @($ShadowVolumes[$AssetInfo.PScomputername].ShadowCopyVolumes)
                }
                'EventLogs' {              
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($EventLogs[$AssetInfo.PScomputername].EventLogs | Sort-Object LogFile) # |
                         #   Select -First $Option_EventLogResults)
                }
                'AppliedGPOs' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($AppliedGPOs[$AssetInfo.PScomputername].AppliedGPOs |
                            Sort-Object AppliedOrder)
                }
                'FirewallSettings' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($FirewallSettings[$AssetInfo.PScomputername])
                }
                'FirewallRules' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($FirewallSettings[$AssetInfo.PScomputername].Rules |
                            Where {($_.Active)} | Sort-Object Profile,Action,Name,Dir)
                }
                'ShareSessionInfo' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($ShareSessions[$AssetInfo.PScomputername].Sessions | 
                            Group-Object -Property ShareName | Sort-Object Count -Descending)
                }
                'WSUSSettings' {
                    $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                        @($WSUSSettings[$AssetInfo.PScomputername].Registry)
                }
                'HP_GeneralHardwareHealth' {
                    if ($HPServerHealth -ne $null)
                    {
                        $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                            @($HPServerHealth[$AssetInfo.PScomputername])
                    }
                }
                'HP_EthernetTeamHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_EthernetTeamHealth').Count)
                        {
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._EthernetTeamHealth)
                        }
                    }
                }
                'HP_ArrayControllerHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_ArrayControllers').Count)
                        {
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._ArrayControllers)
                        }
                    }
                }
                'HP_EthernetHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_EthernetHealth').Count)
                        {  
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._EthernetHealth)
                        }
                    }
                }
                'HP_FanHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_FanHealth').Count)
                        {  
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._FanHealth)
                        }
                    }
                }
                'HP_HBAHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_HBAHealth').Count)
                        {  
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._HBAHealth)
                        }
                    }
                }
                'HP_PSUHealth' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_PSUHealth').Count)
                        {  
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._PSUHealth)
                        }
                    }
                }
                'HP_TempSensors' {
                    if ($HPServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($HPServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_TempSensors').Count)
                        {                
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($HPServerHealth[$AssetInfo.PScomputername]._TempSensors)
                        }
                    }
                }
                'Dell_GeneralHardwareHealth' {
                    if ($DellServerHealth -ne $null)
                    {
                        $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                            @($DellServerHealth[$AssetInfo.PScomputername])
                    }
                }
                'Dell_TempSensorHealth' {
                    if ($DellServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($DellServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_TempSensors').Count)
                        {                
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($DellServerHealth[$AssetInfo.PScomputername]._TempSensors)
                        }
                    }
                }
                'Dell_FanHealth' {
                    if ($DellServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($DellServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_Fans').Count)
                        {                
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($DellServerHealth[$AssetInfo.PScomputername]._Fans)
                        }
                    }
                }
                'Dell_SensorHealth' {
                    if ($DellServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($DellServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_Sensors').Count)
                        {                
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($DellServerHealth[$AssetInfo.PScomputername]._Sensors)
                        }
                    }
                }
                'Dell_ESMLogs' {
                    if ($DellServerHealth.ContainsKey($AssetInfo.PScomputername))
                    {
                        if ($DellServerHealth[$AssetInfo.PScomputername].PSObject.Properties.Match('_ESMLogs').Count)
                        {                
                            $ReportContainer['Sections'][$_]['AllData'][$AssetInfo.PScomputername] = 
                                @($DellServerHealth[$AssetInfo.PScomputername]._ESMLogs)
                        }
                    }
                }
            }}
        }
        #endregion
        $ReportContainer['Configuration']['Assets'] = $ComputerNames
        Return $ComputerNames
    }
}

Function Get-PatchFestServerReport
{
    <#
    .SYNOPSIS
        Generates a new asset report from gathered data.
    .DESCRIPTION
        Generates a new asset report from gathered data. There are multiple 
        input and output methods. Output root elements are manually entered
        as the AssetName parameter.
    .PARAMETER AssetName
        Asset or assets to return information about.
    .PARAMETER ReportContainer
        The custom report hash vaiable structure you plan to report upon.
    .PARAMETER ReportType
        The report type.
    .PARAMETER HTMLMode
        The HTML rendering type (DynamicGrid or EmailFriendly).
    .PARAMETER ExportToExcel
        Export an excel document.
    .PARAMETER PromptForCredential
        Set this if you want the function to prompt for alternate credentials.
    .PARAMETER Credential
        Pass an alternate credential.
    .PARAMETER EmailRelay
        Email server to relay report through.
    .PARAMETER EmailSender
        Email sender.
    .PARAMETER EmailRecipient
        Email recipient.
    .PARAMETER EmailSubject
        Email subject.
    .PARAMETER SendMail
        Send email of resulting report?
    .PARAMETER SaveReport
        Save the report?
    .PARAMETER SaveAsPDF
        Save the report as a PDF. If the PDF library is not available the default format, HTML, will be used instead.
    .PARAMETER OutputMethod
        If saving the report, will it be one big report or individual reports?
    .PARAMETER ReportName
        If saving the report, what do you want to call it? This is only used if one big report Fis being generated.
    .PARAMETER ReportNamePrefix
        Prepend an optional prefix to the report name?
    .PARAMETER ReportLocation
        If saving multiple reports, where will they be saved?
    .EXAMPLE
        $Computers = @('Server1','Server2')
        $cred = get-credential
        Get-PatchFestServerReport -AssetName $Computers `
                -ReportContainer $SystemReport `
                -SaveReport `
                -OutputMethod 'OneBigReport' `
                -HTMLMode 'DynamicGrid' `
                -ReportType 'FullDocumentation' `
                -ReportName 'servers.html' `
                -ExporttoExcel `
                -Credential $cred `
                -Verbose

        Description:
        ------------------
        Prompt for an alternate credential then use it to generate one big html report called servers.html and
        create an excel file with all of the gathered data. The report type is a full documentation report of
        Server1 and Server2. The output format for html is dynamic grid. Verbose output is displayed (which shows
        different aspects of processing as it is occurring).

                     - Added option to save results to PDF with the help of a nifty
                       library from https://pdfgenerator.codeplex.com/
                     - Added a few more resport sections for the system report:
                        - Startup programs
                        - Local host file entries
                        - Cached DNS entries (and type)
                        - Shadow volumes
                        - VSS Writer status
                     - Added the ability to add different section types, specifically
                       section headers
                     - Added ability to completely skip over previously mentioned section
                       headers...
                     - Added ability to add section comments which show up directly below
                       the section table titles and just above the section table data
                     - Added ability to save reports as PDF files
                     - Modified grid html layout to be slightly more condensed.
                     - Added ThrottleLimit and Timeout to main function (applied only to multi-runspace called functions)
                     1.0.0 09/12/2013
                     - First release


        Disclaimer : This script is provided AS IS without warranty of any kind. I 
                     disclaim all implied warranties including, without limitation,
                     any implied warranties of merchantability or of fitness for a 
                     particular purpose. The entire risk arising out of the use or
                     performance of the sample scripts and documentation remains
                     with you. In no event shall I be liable for any damages 
                     whatsoever (including, without limitation, damages for loss of 
                     business profits, business interruption, loss of business 
                     information, or other pecuniary loss) arising out of the use of or 
                     inability to use the script or documentation. 

        Copyright  : I believe in sharing knowledge, so this script and its use is 
                     subject to : http://creativecommons.org/licenses/by-sa/3.0/
    .LINK
        http://www.the-little-things.net/

    .LINK
        http://nl.linkedin.com/in/zloeber

    #>

    #region Parameters
    [CmdletBinding()]
    PARAM
    (
        [Parameter( HelpMessage='Asset or Assets to return information about',
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $AssetName,
        
        [Parameter( Mandatory=$true,
                    HelpMessage='The custom report hash variable structure you plan to report upon')]
        $ReportContainer,
        
        [Parameter( HelpMessage='Maximum number of concurrent threads')]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter( HelpMessage='Timeout before a thread stops trying to gather the information')]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
        
        [Parameter( HelpMessage='The report type (this must be defined in $ReportContainer)')]
        [string]
        $ReportType,
        
        [Parameter( HelpMessage='The HTML rendering type (DynamicGrid or EmailFriendly)')]
        [ValidateSet('DynamicGrid','EmailFriendly')]
        [string]
        $HTMLMode = 'DynamicGrid',
        
        [Parameter( HelpMessage='Export an excel document as part of the output')]
        [switch]
        $ExportToExcel,
        
        [parameter( HelpMessage='Set this if you want the function to prompt for alternate credentials' )]
        [switch]
        $PromptForCredential,
        
        [parameter( HelpMessage='Pass an alternate credential' )]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter( HelpMessage='Email server to relay report through')]
        [string]
        $EmailRelay = '.',
        
        [Parameter( HelpMessage='Email sender')]
        [string]
        $EmailSender='systemreport@localhost',
     
        [Parameter( HelpMessage='Email recipient')]
        [string]
        $EmailRecipient='default@yourdomain.com',
        
        [Parameter( HelpMessage='Email subject')]
        [string]
        $EmailSubject='PatchFest Server "(Get-Dat)" Report',
        
        [Parameter( HelpMessage='Send email of resulting report?')]
        [switch]
        $SendMail,
        
        [Parameter( HelpMessage="Force email to be sent anonymously?")]
        [switch]
        $ForceAnonymous,
        
        [Parameter( HelpMessage='Save the report?')]
        [switch]
        $SaveReport,
        
        [Parameter( HelpMessage='Save the report as a PDF. If the PDF library is not available the default format, HTML, will be used instead.')]
        [switch]
        $SaveAsPDF,
        
        [Parameter( HelpMessage='Save the data gathered in xml format.')]
        [switch]
        $SaveData,
        
        [Parameter( HelpMessage='Save the data gathered in xml format.')]
        [string]
        $SaveDataFile = 'SaveData.xml',
        
        [Parameter( HelpMessage='Data already exists in the ReportContainer. This skips the information gathering processing.')]
        [switch]
        $SkipInformationGathering,

        [Parameter( HelpMessage='If saving the report, will it be one big report or individual reports?')]
        [ValidateSet('OneBigReport','IndividualReport')]
        [string]
        $OutputMethod='OneBigReport',
        
        [Parameter( HelpMessage='If saving the report, what do you want to call it?')]
        [string]
        $ReportName='Report.html',
        
        [Parameter( HelpMessage='Prepend an optional prefix to the report name?')]
        [string]
        $ReportNamePrefix='',
        
        [Parameter( HelpMessage='If saving multiple reports, where will they be saved?')]
        [string]
        $ReportLocation=$env:USERPROFILE\Desktop\
    )
    #endregion Parameters
    BEGIN
    {
        # Use this to keep a splat of our CmdletBinding options
        $VerboseDebug=@{}
        If ($PSBoundParameters.ContainsKey('Verbose')) {
            If ($PSBoundParameters.Verbose -eq $true) { $VerboseDebug.Verbose = $true } else { $VerboseDebug.Verbose = $false }
        }
        If ($PSBoundParameters.ContainsKey('Debug')) {
            If ($PSBoundParameters.Debug -eq $true) { $VerboseDebug.Debug = $true } else { $VerboseDebug.Debug = $false }
        }
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        $AssetNames = @()
        $credsplat = @{
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        $summarysplat = @{
            'ThrottleLimit' = $ThrottleLimit
            'Timeout' = $Timeout
        }
        if ($Credential -ne $null)
        {
            $credsplat.Credential = $Credential
            $summarysplat.Credential = $Credential

        }
        
        $ReportProcessingSplat = @{
            'EmailSender' = $EmailSender
            'EmailRecipient' = $EmailRecipient
            'EmailSubject' = $EmailSubject
            'EmailRelay' = $EmailRelay
            'SendMail' = $SendMail
            'SaveReport' = $SaveReport
            'SaveAsPDF' = $SaveAsPDF
            'ForceAnonymous' = $ForceAnonymous
        }
        
        # Some basic initialization
        $FinalReport = ''
        $ServerReports = ''
        
        if (($ReportType -eq '') -or ($ReportContainer['Configuration']['ReportTypes'] -notcontains $ReportType))
        {
            $ReportType = $ReportContainer['Configuration']['ReportTypes'][0]
        }
        # There must be a more elegant way to do this hash sorting but this also allows
        # us to pull a list of only the sections which are defined and need to be generated.
        $SortedReports = @()
        Foreach ($Key in $ReportContainer['Sections'].Keys) 
        {
            if ($ReportContainer['Sections'][$Key]['ReportTypes'].ContainsKey($ReportType))
            {
                if ($ReportContainer['Sections'][$Key]['Enabled'] -and 
                    ($ReportContainer['Sections'][$Key]['ReportTypes'][$ReportType] -ne $false))
                {
                    $_SortedReportProp = @{
                                            'Section' = $Key
                                            'Order' = $ReportContainer['Sections'][$Key]['Order']
                                          }
                    $SortedReports += New-Object -Type PSObject -Property $_SortedReportProp
                }
            }
        }
        $SortedReports = $SortedReports | Sort-Object Order
    }
    PROCESS
    {
        if ($AssetName -ne $null)
        {
            $AssetNames += $AssetName
        }
    }
    END 
    {
        if ($SkipInformationGathering)
        {
            $AssetNames = @($ReportContainer['Configuration']['Assets'])
        }
        Else
        {
            # Information Gathering
            $AssetNames = @(Invoke-Command ([scriptblock]::Create($ReportContainer['Configuration']['PreProcessing'])))
        }

        if ($AssetNames.Count -ge 1)
        {
            if ($SaveData)
            {
                $ReportContainer | Export-CliXml -Path $SaveDataFile
            }
            
            # if we are to export all data to excel, then we do so per section then per computer
            if ($ExportToExcel)
            {
                # First make sure we have data to export, this should also weed out non-data sections meant for html
                #  (like section breaks and such)
                $ProcessExcelReport = $false
                foreach ($ReportSection in $SortedReports)
                {
                    if ($ReportContainer['Sections'][$ReportSection.Section]['AllData'].Count -gt 0)
                    {
                        $ProcessExcelReport = $true
                    }
                }

                #region Excel
                if ($ProcessExcelReport)
                {
                    # Create the excel workbook
                    try
                    {
                        #$Excel = New-Object -Com Excel.Application -ErrorAction Stop
                        $Excel = New-Object -ComObject Excel.Application -ErrorAction Stop
                        $ExcelExists = $True
                        $Excel.visible = $True
                        #Start-Sleep -s 1
                        $Workbook = $Excel.Workbooks.Add()
                        $Excel.DisplayAlerts = $false
                    }
                    catch
                    {
                        Write-Warning ('Issues opening excel: {0}' -f $_.Exception.Message)
                        $ExcelExists = $False
                    }
                    if ($ExcelExists)
                    {
                        # going through every section, but in reverse so it shows up in the correct
                        #  sheet in excel. 
                        $SortedExcelReports = $SortedReports | Sort-Object Order -Descending
                        Foreach ($ReportSection in $SortedExcelReports)
                        {
                            $SectionData = $ReportContainer['Sections'][$ReportSection.Section]['AllData']
                            $SectionProperties = $ReportContainer['Sections'][$ReportSection.Section]['ReportTypes'][$ReportType]['Properties']
                            
                            # Gather all the asset information in the section (remember that each asset may
                            #  be pointing to an array of psobjects)
                            $TransformedSectionData = @()                        
                            foreach ($asset in $SectionData.Keys)
                            {
                                # Get all of our calculated properties, then add in the asset name
                                $TempProperties = $SectionData[$asset] | Select $SectionProperties
                                $TransformedSectionData += ($TempProperties | Select @{n='PSComputerName';e={$asset}},*)
                            }
                            if (($TransformedSectionData.Count -gt 0) -and ($TransformedSectionData -ne $null))
                            {
                                $temparray1 = $TransformedSectionData | ConvertTo-MultiArray
                                if ($temparray1 -ne $null)
                                {    
                                    $temparray = $temparray1.Value
                                    $starta = [int][char]'a' - 1
                                    
                                    if ($temparray.GetLength(1) -gt 26) 
                                    {
                                        $col = [char]([int][math]::Floor($temparray.GetLength(1)/26) + $starta) + [char](($temparray.GetLength(1)%26) + $Starta)
                                    } 
                                    else 
                                    {
                                        $col = [char]($temparray.GetLength(1) + $starta)
                                    }
                                    
                                    Start-Sleep -s 1
                                    $xlCellValue = 1
                                    $xlEqual = 3
                                    $BadColor = 13551615    #Light Red
                                    $BadText = -16383844    #Dark Red
                                    $GoodColor = 13561798    #Light Green
                                    $GoodText = -16752384    #Dark Green
                                    $Worksheet = $Workbook.Sheets.Add()
                                    $Worksheet.Name = $ReportSection.Section
                                    $Range = $Worksheet.Range("a1","$col$($temparray.GetLength(0))")
                                    $Range.Value2 = $temparray

                                    #Format the end result (headers, autofit, et cetera)
                                    [void]$Range.EntireColumn.AutoFit()
                                    [void]$Range.FormatConditions.Add($xlCellValue,$xlEqual,'TRUE')
                                    $Range.FormatConditions.Item(1).Interior.Color = $GoodColor
                                    $Range.FormatConditions.Item(1).Font.Color = $GoodText
                                    [void]$Range.FormatConditions.Add($xlCellValue,$xlEqual,'OK')
                                    $Range.FormatConditions.Item(2).Interior.Color = $GoodColor
                                    $Range.FormatConditions.Item(2).Font.Color = $GoodText
                                    [void]$Range.FormatConditions.Add($xlCellValue,$xlEqual,'FALSE')
                                    $Range.FormatConditions.Item(3).Interior.Color = $BadColor
                                    $Range.FormatConditions.Item(3).Font.Color = $BadText
                                    
                                    # Header
                                    $range = $Workbook.ActiveSheet.Range("a1","$($col)1")
                                    $range.Interior.ColorIndex = 19
                                    $range.Font.ColorIndex = 11
                                    $range.Font.Bold = $True
                                    $range.HorizontalAlignment = -4108
                                }
                            }
                        }
                        # Get rid of the blank default worksheets
                        $Workbook.Worksheets.Item("Sheet1").Delete()
                        $Workbook.Worksheets.Item("Sheet2").Delete()
                        $Workbook.Worksheets.Item("Sheet3").Delete()
                    }
                }
                #endregion Excel
            }
            
            foreach ($Asset in ($AssetNames | Where {$_ -ne $null}))
            {
                # First check if there is any data to report upon for each asset
                $ContainsData = $false
                $SectionCount = 0
                Foreach ($ReportSection in $SortedReports)
                {
                    if ($ReportContainer['Sections'][$ReportSection.Section]['AllData'].ContainsKey($Asset))
                    {
                        $ContainsData = $true
                        #$SectionCount++             #Not currently used
                    }
                }
                
                # If we have any data then we have a report to create
                if ($ContainsData)
                {
                    $ServerReport = ''
                    $ServerReport += $HTMLRendering['ServerBegin'][$HTMLMode] -replace '<0>',$Asset
                    $UsedSections = 0
                    $TotalSectionsPerRow = 0
                    
                    Foreach ($ReportSection in $SortedReports)
                    {
                        if ($ReportContainer['Sections'][$ReportSection.Section]['ReportTypes'][$ReportType])
                        {
                            #region Section Calculation
                            # Use this code to track where we are at in section usage
                            #  and create new section groupss as needed
                            
                            # Current section type
                            $CurrContainer = $ReportContainer['Sections'][$ReportSection.Section]['ReportTypes'][$ReportType]['ContainerType']
                            
                            # Grab first two digits found in the section container div
                            $SectionTracking = ([Regex]'\d{1}').Matches($HTMLRendering['SectionContainers'][$HTMLMode][$CurrContainer]['Head'])
                            #Write-Verbose -Message ('Report {0}: Section calculation - {1}' -f $Asset,$ReportSection.Section)
                            #Write-Verbose -Message ('Section: {0}, HTML: {1}' -f $CurrContainer,$HTMLRendering['SectionContainers'][$HTMLMode][$CurrContainer]['Head'])
                            if (($SectionTracking[1].Value -ne $TotalSectionsPerRow) -or `
                                ($SectionTracking[0].Value -eq $SectionTracking[1].Value) -or `
                                (($UsedSections + [int]$SectionTracking[0].Value) -gt $TotalSectionsPerRow) -and `
                                (!$ReportContainer['Sections'][$ReportSection.Section]['ReportTypes'][$ReportType]['SectionOverride']))
                            {
                                $NewGroup = $true
                            }
                            else
                            {
                                $NewGroup = $false
                                $UsedSections += [int]$SectionTracking[0].Value
                                Write-Verbose -Message ('Report {0}: NOT a new group, Sections used {1}' -f $Asset,$UsedSections)
                            }
                            
                            if ($NewGroup)
                            {
                                if ($UsedSections -ne 0)
                                {
                                    $ServerReport += $HTMLRendering['SectionContainerGroup'][$HTMLMode]['Tail']
                                }
                                #$ServerReport += $HTMLRendering['SectionContainerGroup'][$HTMLMode]['Tail']
                                $ServerReport += $HTMLRendering['SectionContainerGroup'][$HTMLMode]['Head']
                                $UsedSections = [int]$SectionTracking[0].Value
                                $TotalSectionsPerRow = [int]$SectionTracking[1].Value
                                Write-Verbose -Message ('Report {0}: {1}/{2} Sections Used' -f $Asset,$UsedSections,$TotalSectionsPerRow)
                            }
                            #endregion Section Calculation
                            
                            Write-Verbose -Message ('Report {0}: HTML Table creation - {1}' -f $Asset,$ReportSection.Section)
                            $ServerReport += Create-ReportSection -Rpt $ReportContainer `
                                                                  -Asset $Asset `
                                                                  -Section $ReportSection.Section `
                                                                  -TableTitle $ReportContainer['Sections'][$ReportSection.Section]['Title']
                        }
                    }
                    
                    $ServerReport += $HTMLRendering['SectionContainerGroup'][$HTMLMode]['Tail']
                    $ServerReport += $HTMLRendering['ServerEnd'][$HTMLMode]
                    $ServerReports += $ServerReport
                    
                }
                # If we are creating per-asset reports then create one now, 
                #   otherwise keep going
                if ($OutputMethod -eq 'IndividualReport')
                {
                    $ReportProcessingSplat.Report = ($HTMLRendering['Header'][$HTMLMode] -replace '<0>','$Asset') + 
                                                        $ServerReports + 
                                                        $HTMLRendering['Footer'][$HTMLMode]
                    $ReportProcessingSplat.ReportName = $ReportLocation + 
                                                        '\' + $ReportNamePrefix + 
                                                        $Asset + '.html'
                    ReportProcessing @ReportProcessingSplat
                    $ServerReports = ''
                }
            }
            
            # If one big report is getting sent/saved do so now
            if ($OutputMethod -eq 'OneBigReport')
            {
                $FullReport = ($HTMLRendering['Header'][$HTMLMode] -replace '<0>','Multiple Systems') + 
                               $ServerReports + 
                               $HTMLRendering['Footer'][$HTMLMode]
                $ReportProcessingSplat.ReportName = $ReportLocation + '\' + $ReportName
                $ReportProcessingSplat.Report = ($HTMLRendering['Header'][$HTMLMode] -replace '<0>','Multiple Systems') + 
                                                    $ServerReports + 
                                                    $HTMLRendering['Footer'][$HTMLMode]
                ReportProcessing @ReportProcessingSplat
            }
        }
    }
}

Function Load-AssetDataFile ($FileToLoad)
{
    $ReportStructure = Import-Clixml -Path $FileToLoad
    # Export/Import XMLCLI isn't going to deal with our embedded scriptblocks (named expressions)
    # so we manually convert them back to scriptblocks like the rockstars we are...
    Foreach ($Key in $ReportStructure['Sections'].Keys) 
    {
        if ($ReportStructure['Sections'][$Key]['Type'] -eq 'Section')  # if not a section break
        {
            Foreach ($ReportTypeKey in $ReportStructure['Sections'][$Key]['ReportTypes'].Keys)
            {
                $ReportStructure['Sections'][$Key]['ReportTypes'][$ReportTypeKey]['Properties'] | 
                    ForEach {
                        $_['e'] = [Scriptblock]::Create($_['e'])
                    }
            }
        }
    }
    Return $ReportStructure
}
#endregion Functions - Asset Report Project
#endregion Functions

#region Main
$reportsplat = @{}
if ($Verbosity)
{
    $reportsplat.Verbose = $true
}

$reportsplat.AssetName = $Computers

#if ($LoadData)
#{
#    $SystemReport = Import-Clixml -Path $DataFile
#    # Export/Import XMLCLI isn't going to deal with our embedded scriptblocks (named expressions)
#    # so we manually convert them back to scriptblocks like the rockstars we are...
#    Foreach ($Key in $SystemReport['Sections'].Keys) 
#    {
#        if ($SystemReport['Sections'][$Key]['Type'] -eq 'Section')  # if not a section break
#        {
#            Foreach ($ReportTypeKey in $SystemReport['Sections'][$Key]['ReportTypes'].Keys)
#            {
#                $SystemReport['Sections'][$Key]['ReportTypes'][$ReportTypeKey]['Properties'] | 
#                    ForEach {
#                        $_['e'] = [Scriptblock]::Create($_['e'])
#                    }
#            }
#        }
#    }
#    $reportsplat.SkipInformationGathering = $true
#}

if ($LoadData)
{
    if (Test-Path $DataFile)
    {
        $SystemReport = Load-AssetDataFile $DataFile
        $reportsplat.SkipInformationGathering = $true
    }
}
elseif ($SaveData)
{
    $reportsplat.SaveData = $true
    $reportsplat.SaveDataFile = $DataFile
}

$reportsplat.ReportType = $ReportType
$reportsplat.ReportContainer = $SystemReport

# Credential input
if ($PromptForCreds)
{
    $reportsplat.Credential = Get-Credential 
}
elseif ($Credential.UserName)
{
    $reportsplat.Credential = $Credential
}

if ($ADDialog)
{
    $Computers = $((Get-OUResults).SelectedResults)
    if ($Computers)
    {
        $reportsplat.AssetName = $Computers
    }
}

switch ($ReportFormat) {
	'HTML' {
        $reportsplat.SaveReport = $true
        $reportsplat.OutputMethod = 'IndividualReport'
	}
	'Excel' {
        #$reportsplat.SaveReport = $true
        $reportsplat.ExportToExcel = $true
	}
    'Custom' {
        # Fill this out as you see fit
	}
}

Get-PatchFestServerReport @reportsplat

#endregion Main
}
