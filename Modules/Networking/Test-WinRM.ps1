Function Test-WinRM { 
 
<#    
.SYNOPSIS    
    Test Windows Remote Management 
   
.DESCRIPTION    
    Allows the administrator to test Windows Remote Management is working or not on  
    localhost and remote server. It will enable administrator to be able to establish  
    a quick test of the Windows Remote Management in their environment and assess  
    the possibility of executing powershell script remotely. 
 
.PARAMETER ComputerName 
     
    Specify a hostname for query. 
     
.PARAMETER Test 
 
    Specify to continous testing until stopped. 
    To stop -type Control-C. 
     
.EXAMPLE      
    Test-WinRM -ComputerName 219.44.78.1 
     
    This initiate a Windows Remote Management test on Redmond server 
 
.EXAMPLE 
    Test-WinRM -ComputerName 213.247.10.65 -Test 
    True 
     
    This initiate a continuous Windows Remote Management test on Contoso server until  
    user initiate to stop the test using Control-C. If Windows Remote Management not  
    running on Contoso, it will continously return False. 
 
.EXAMPLE 
    Test-WinRM -ComputerName 213.247.10.65 -Verbose 
    VERBOSE: WinRM - Running 
     
    This initiate a Verbose output. 
     
.EXAMPLE 
    $Test = Test-WinRM -ComputerName 219.44.78.1 ; if($Test -eq $True){ write-host "Yes!!! Eureka!!! It works!" } 
    Yes!!! Eureka!!! It works! 
     
    This utilises the returned boolean value as True or False for other condition statement. 
 
.LINK 
    Windows Remote Management 
    http://msdn.microsoft.com/en-us/library/windows/desktop/aa384426(v=vs.85).aspx 
     
    Installation and Configuration for Windows Remote Management 
    http://msdn.microsoft.com/en-us/library/windows/desktop/aa384372(v=vs.85).aspx 
 
    Blog    : ryentang.wordpress.com 
 
    Windows Server 2003 R2:  WinRM is not installed by default, but is available as  
    the Hardware Management feature through the Add/Remove System Components feature  
    in Control Panel under Management and Monitoring Tools. 
#> 
 
[CmdletBinding( 
    SupportsShouldProcess=$True, 
    ConfirmImpact='High')] 
         
#define command parameters 
param 
( 
    [Parameter( 
        Mandatory=$False, 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True)] 
         
        $ComputerName = $env:computername, 
 
    [Parameter( 
        Mandatory=$False, 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True)] 
        [Alias('T')] 
        [Switch] $Test 
         
) 
 
BEGIN { 
 
    #clear variable 
    $Result = "" 
} 
 
PROCESS { 
 
    do{ 
        
       try { 
             
            #invoke a command to get WinRM service status 
            $Result = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-Service | Where-Object {($_.Name -eq "WinRM") -and ($_.Status -eq "Running")}} -ErrorAction Stop 
             
            #success output 
            if($PSBoundParameters['Verbose']) { Write-Verbose "WinRM - Running" }else{ $True} 
         
        }catch{ 
             
            #failure output 
            if($PSBoundParameters['Verbose']) { Write-Verbose "WinRM - Not Running"; Write-Error $_.ToString() }else{ $False } 
         
        } 
         
        #verify if -Test parameter is specified 
        if($Test) { Continue }else{ Break } 
     
    }while(!$Result?) 
         
} 
 
END { } 
 
} #end of #function Test-WinRM 