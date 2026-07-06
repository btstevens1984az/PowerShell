Function Get-SchedTasks 
{ 
<# 
.SYNOPSIS 
 
This function will display the status of Scheduled Task in the Root Folder (Not Recursive). 
 
.DESCRIPTION 
 
This function will display the status of Scheduled Task in the Root Folder (Not Recursive).  The function uses the  
Schedule.Service COM Object to query information about the scheduled task running on a local or remote computer. 
 
.PARAMETER ComputerName 
 
A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
 
.EXAMPLE 
 
Get-SchedTasks -ComputerName 26.233.162.190 
 
This example will query any scheduled task, located in Root Task Folder, of Server01. 
 
.LINK 
 
This Function is based on information from: 
http://msdn.microsoft.com/en-us/library/windows/desktop/aa446865(v=vs.85).aspx 
 
 
Email:  bwilhite1@carolina.rr.com 
Date:   02/22/2012 
#> 
 
[CmdletBinding()] 
param( 
 [parameter(Position=0,ValueFromPipeline=$true)] 
 [alias("CN","Computer")] 
 [String[]]$ComputerName="$env:COMPUTERNAME" 
 ) 
 
Begin 
 { 
  #Adjusting ErrorActionPreference to stop on all errors 
  $TempErrAct = $ErrorActionPreference 
  $ErrorActionPreference = "Stop" 
  #Defining Schedule.Service Variable 
  $SchedService = New-Object -ComObject Schedule.Service 
 }#End Begin Script Block 
 
Process 
 { 
  Foreach ($Computer in $ComputerName) 
   { 
    $Computer = $Computer.Trim().ToUpper() 
    Try 
     { 
      #Connecting to the Schedule.Service COM Object on $Computer" 
      $SchedService.Connect($Computer) 
      $TaskFolder = $SchedService.GetFolder("") 
      $RootTasks = $TaskFolder.GetTasks("") 
      Foreach ($Task in $RootTasks) 
       { 
        Switch ($Task.State) 
         { 
          0 {$Status = "Unknown"} 
          1 {$Status = "Disabled"} 
          2 {$Status = "Queued"} 
          3 {$Status = "Ready"} 
          4 {$Status = "Running"} 
         }#End Switch ($Task.State) 
        $Xml = $Task.Xml 
        #The code below parses the Xml String Data for the "RunAs User" that is returned from the Schedule.Service COM Object 
        [String]$RunUser = $Xml[(($Xml.LastIndexOf("<UserId>"))+8)..(($Xml.LastIndexOf("</UserId>"))-1)] 
        $RunUser = $RunUser.Replace(" ","").ToUpper() 
        $Result = New-Object PSObject -Property @{ 
        ServerName=$Computer 
        TaskName=$Task.Name 
        RunAs=$RunUser 
        Enabled=$Task.Enabled 
        Status=$Status 
        LastRunTime=$Task.LastRunTime 
        Result=$Task.LastTaskResult 
        NextRunTime=$Task.NextRunTime 
        }#End $Result = New-Object 
        $Result = $Result | Select-Object Servername, TaskName, RunAs, Enabled, Status, LastRunTime, Result, NextRunTime 
        $Result 
       }#End Foreach ($Task in $RootTasks) 
     }#End Try 
    Catch 
     { 
      $Error[0].Exception.Message 
     }#End Catch 
   }#End Foreach ($Computer in $ComputerName) 
 }#End Process Script Block 
End 
 { 
  #Resetting ErrorActionPref 
  $ErrorActionPreference = $TempErrAct 
 }#End End Script Block 
}#End function