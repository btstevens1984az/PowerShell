Function Invoke-ScriptMultithreaded{ 
<# 
  .SYNOPSIS 
  This function is for running a PowerShell script in multiple threads simultaneously. 
  .DESCRIPTION 
  The function requires an array of at least one element to work properly.  The Foreach statement will parsed the array into elements and feed them into individual jobs. 
  The element will be the first argument in the script.  The Arguments parameter is used for any arguments (up to 21) that the script requires to run.  
  .PARAMETER Script 
  The Script parameter is the file path and PowerShell script that will be run. 
  .PARAMETER Arguments 
  The Arguments parameter will feed up to 21 variables as input for the PowerShell script.  
  The Arguments parameter should be an array with the elements in the same order as the invoked scripts parameters. 
  The Arguments parameter is not required. 
  .PARAMETER Array 
  The Array parameter is an array of elements that will be used as input for the script. An example would be an array of computer names. 
  .EXAMPLE 
  Invoke-ScriptMultithreaded -Script ".\Test-Ping.ps1" -Array $Computers 
   
  Description 
  ----------- 
  The PowerShell script that will be invoked must be the first parameter. The Array parameter must have at least one element. 
  .EXAMPLE 
  Invoke-ScriptMultithreaded -Script ".\Test-Ping.ps1" -Arguments $Arguments -Array $Computers 
   
  Description 
  ----------- 
  The Arguments parameter must be an array with the elements in the same order that the invoked script requires. 
  .EXAMPLE 
  Get-ADComputer -SearchBase "OU=Computers,DC=CONTOSO,DC=Local" -Filter '*' | Select-Object -ExpandProperty Name | Invoke-ScriptMultithreaded -Script .\Test-Ping.ps1 $Arguments 
   
  Description 
  ----------- 
  The Invoke-ScriptMultithreaded function can use objects that are piped in from other commands for the Array. 
  The Arguments parameter does not have to be used or defined when piping objects. 
  .INPUTS 
  This function requires that a PowerShell script and at least one array object be provided. 
  IMPORTANT:  The PowerShell script that will be invoked must require the array object as its first parameter. 
  .OUTPUTS 
  This function creates a job or PowerShell process for each element defined in the array parameter. 
  Invoke-ScriptMultithreaded 
  Advanced function for running a PowerShell script multiple times in parallel 
  Creation Date: 7/01/2016 
  Modified Date: 7/20/2016 
  Version: 1.0.0 
  .LINK 
  https://blogs.technet.microsoft.com/rgullick/ 
  https://blogs.technet.microsoft.com/rgullick/2017/01/10/run-a-powershell-script-multi-threaded-i-mean-in-parallel 
  https://gallery.technet.microsoft.com/scriptcenter/Run-a-PowerShell-script-991c8a42 
  .COMPONENT 
  No additional components are required for this script to run.  However, the invoked script may need modules loaded or other components to work properly. 
  .ROLE 
  No elevated permissions are required for this script to run.  However, the invoked script may require elevated permissions for work properly. 
  .FUNCTIONALITY 
  This function is designed to run a script multiple time in parallel and in separate worker processes.  Each invoked script will have its own process and memory. 
#> 
 
  [cmdletbinding()] 
  param(   
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)] 
    [String]$Script, 
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)] 
    [String[]]$Arguments, 
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)] 
    [Object[]]$Array 
    ) 
    BEGIN{ 
    If($Arguments -eq $NULL){$Arguments = @()} 
    $a = $Arguments   # This is to make the script more readable 
     } # end BEGIN 
     
    PROCESS{ 
        Foreach($Element in $Array){ 
            try{ 
            Start-Job -name $Element -FilePath $Script -ArgumentList $Element, $a[0], $a[1], $a[2], $a[3], $a[4], $a[5], $a[6], $a[7], $a[8], $a[9], $a[10], $a[11], $a[12], $a[13], $a[14], $a[15], $a[16], $a[17], $a[18], $a[19], $a[20] 
            } #end try 
            catch{ 
            $Exception = $error[0] 
            $FunctionError =    "`r`n" + "Function:"  + "`t"   + "Invoke-ScriptMultithreaded " +  
                                "`r`n" + "Script:"    + "`t`t" + $Script +  
                                "`r`n" + "Element:"   + "`t`t" + $Element +  
                                "`r`n" + "Arguments:" + "`t"   + $Arguments +  
                                "`r`n" + "Error:"     + "`t`t" + $Exception 
            Write-EventLog -LogName "Windows PowerShell" -Source "PowerShell" -EventId 100 -Message $FunctionError -EntryType Error 
            }#end catch 
        }#end Foreach 
    } #end PROCESS 
     
    END { 
    } #end END 
}# end Function

$Computers = "114.148.18.125","114.148.18.125","114.148.18.125"
Invoke-ScriptMultithreaded -Script ".\Get-RecycleBinSize.ps1" -Array $Computers