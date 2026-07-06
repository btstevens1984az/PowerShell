# Purpose: 6-3 1 ClassDemos — Certification notes and learning materials.
using module .\AssetInfo.psm1

enum ComputerState
{
    Offline #= 0
    Online  #= 1
}

class ComputerInfo : AssetInfo,System.ICloneable,IComparable
{
    #region Properties ######################################################################################
    #static Property
    static [string]$teststatic = "test" 
    [string]$ComputerName
    [string]$OSName
    [String]$BuildNumber
    #Can Use Variable Validation
    [ValidateRange(1,640)]
    [int]$NumberOfLogicalProcessors
    [ComputerState]$Status
    [System.ServiceProcess.ServiceController[]]$Services
    [System.Diagnostics.Process[]]$processes
    hidden [string]$hiddenproperty = "test"
    #endregion Properties######################################################################################
    
    #region Constructor(s)##################################################################################
    ComputerInfo([string]$ComputerName,[bool]$Services,[bool]$processes){
    $this.ComputerName = $ComputerName
    try
    {
        $OS = Get-WmiObject -Class win32_operatingsystem -ComputerName $ComputerName -ErrorAction stop
        $computerSystem = Get-WmiObject -Class win32_computersystem -ComputerName $ComputerName -ErrorAction stop
        $this.OSName = $os.Caption
        $this.BuildNumber = $os.BuildNumber
        $this.NumberOfLogicalProcessors = $computerSystem.NumberOfLogicalProcessors
        $this.Status = [ComputerState]::Online
    If($services)
    {
        $this.Services = Get-service -ComputerName $ComputerName
    }
    if($processes)
    {
        $this.processes = Get-Process -ComputerName $ComputerName
    }
    
    }
    catch
    {
        $this.Status = [computerstate]::Offline

    }
    }
     ComputerInfo(
        [string]$ComputerName,
        [string]$OSName,
        [String]$BuildNumber,
        [int]$NumberOfLogicalProcessors,
        [ComputerState]$Status,
        [System.ServiceProcess.ServiceController[]]$Services,
        [System.Diagnostics.Process[]]$processes
    )
    {
        $this.ComputerName =$computerName
        $this.OSName = $osname
        $this.BuildNumber = $BuildNumber
        $this.NumberOfLogicalProcessors = $NumberOfLogicalProcessors
        $this.Status = $status
        $this.Services = $services
        $this.processes = $processes
    }
    #endregion Constructors#################################################################################
    
    #region Methods ######################################################################################
    [ComputerState]GetStatus()
    {
       [int]$Result =  Test-Connection -ComputerName $this.computername -Count 2 -Quiet
       return $Result

    }
    #Overload
    [ComputerState]GetStatus([string]$ComputerName)
    {
       $Result =  Test-Connection -ComputerName $ComputerName -Count 2 -Source $this.computername -ErrorAction SilentlyContinue
       if ($result)
       {
        return  [ComputerState]::Online
       }
       else
       {
        return  [ComputerState]::Offline
       }
    }

    #Static Method
    static [ComputerState] GetComputerStatus([string]$ComputerName)
    {
       $Result =  Test-Connection -ComputerName $ComputerName -Count 2 -Quiet
        if ($result)
       {
        return  [ComputerState]::Online
       }
       else
       {
        return  [ComputerState]::Offline
       }

    }
    #endregion Methods####################################################################################


    #region Interface Implementations###########################################################################
    #[computerinfo] Clone() #though the type returned will be computerinfo the return type defined needs to match the interface spec.
    [system.object] Clone()
    {
      $clone =  [computerinfo]::new(
        $this.ComputerName,
        $this.OSName,
        $this.BuildNumber,
        $this.NumberOfLogicalProcessors,
        $this.Status,
        $this.Services,
        $this.processes)
        return $clone
    }
    
    [int] CompareTo($obj)
    {
        $result =0
        switch ($obj)
        {
            {$this.computername -eq $_.computername} {$result= 0}
            {$this.computername -lt $_.computername} {$result= -1}
            {$this.computername -gt $_.computername} {$result=1}
            default{$result= 0}
        }
        return $result
    }

    #endregion Interface Implementation###########################################################################
    
}

#Demos

$mycomp = [computerinfo]::new("testsrv1",$true,$true)

#validation error
$mycomp.NumberOfLogicalProcessors = 641


# Hidden Property
$mycomp | Select-Object *
$mycomp.hiddenproperty

$mycomp | Get-Member
#-force will display hidden members
$mycomp | Get-Member -Force

#ExecuteMethods
$mycomp.GetStatus()
$mycomp.GetStatus("dc2")

#Display Static members including constructors
[computerinfo] | Get-Member -Static
([computerinfo] | Get-Member -Static | where name -eq new | Select-Object -ExpandProperty definition)
[ComputerInfo]::teststatic
[computerinfo]::GetComputerStatus("localhost")

#Advantages to implementing interfaces : IComparable 
$computers = 5..1 | %{"testsrv$_" | %{ [computerinfo]::new($_,$true,$true)}}
$computers[0].CompareTo($computers[1])
$computers | Select-Object ComputerName
#Sort-object will automatically sort using the implemented Icomparable interface.
$computers  | Sort-Object | Select-Object ComputerName


