Function Get-CorrelatedEventLog 
{ 
<# 
.SYNOPSIS 
  Gathers events and correlates them by time generated from specified eventlogs. 
.DESCRIPTION 
  Gathers events from one or more eventlogs and sorts them based on time generated.  Executing this function  
  without parameters will query the Newest 50 events from Application, Security and System eventlogs. 
.PARAMETER ComputerName 
  A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
.PARAMETER LogName 
  A single Log or an array of logs.  The default is Application, Security and System. 
.PARAMETER Newest 
  Specifies the maximum number of events retrieved. Get-CorrelatedEventLog gets the specified number of events, 
  beginning with the newest event in the each eventlog specified. 
.EXAMPLE 
  PS C:\> Get-CorrelatedEventLog 
 
  Returns the newest 50 events from Application, Security and System on the local machine. 
.EXAMPLE 
  PS C:\> Get-CorrelatedEventLog -Newest 5 -LogName Application, System -ComputerName 133.147.81.146 
 
  Returns the newest 5 events from the Application and System eventlogs on Server1. 
.LINK 
 
 
  Email:  bwilhite1@carolina.rr.com 
  Date:    
  PSVer:  2.0/3.0 
  This was a possible solution to the Charlotte PowerShell User Group #5 Scripting Event. 
#> 
 
[CmdletBinding()] 
param( 
  [Parameter(Position=0,ValueFromPipeline=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerName="$env:COMPUTERNAME", 
  [String[]]$LogName=@('Application','Security','System'), 
  [Int]$Newest=50 
  ) 
 
Begin 
  { 
    #Adjusting ErrorActionPreference to stop on all errors 
    $TempErrAct = $ErrorActionPreference 
    $ErrorActionPreference = "Stop" 
    $FinalLog = @() 
  }#End Begin Script Block 
Process 
  { 
    Foreach ($Computer in $ComputerName) 
      { 
        $Computer = $Computer.ToUpper().Trim() 
        Try 
          { 
            Foreach ($Log in $LogName) 
              { 
                $LogData = Get-EventLog -LogName $Log -Newest $Newest 
                Foreach ($Data in $LogData) 
                  { 
                    $FinalLog += $Data | Add-Member -MemberType NoteProperty -Name EventLog -Value $Log -PassThru 
                  } 
              }#End Foreach ($Log in $LogName) 
            $FinalLog | Sort TimeGenerated | Select EventLog, TimeGenerated, Source, Message 
          }#End Try 
        Catch 
          { 
            Write-Warning $_ 
          }#End Catch 
      }#End Foreach ($Computer in $ComputerName) 
    }#End Process 
End 
    { 
        #Resetting ErrorActionPref 
        $ErrorActionPreference = $TempErrAct 
    }#End End 
}#End Function