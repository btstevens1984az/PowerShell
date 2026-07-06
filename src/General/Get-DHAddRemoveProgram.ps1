Function Get-DHAddRemovePrograms
{
<#
    .Synopsis
        Get Add Remove Programs from SCCM Query
   
    .Description
        Get Add Remove Programs from SCCM Query
        
    
    .Parameter ComputerName
        Specifies a computer. The default is the local computer.
        
    .Parameter NameSpace
        Set this to your SCCM environment
        
    .Parameter SiteServer
        Set this to your SCCM environment
        

       
   .Example
        PS C:\>Get-DHAddRemoveProgram
       
    Description
    -----------
        Gets list of software installed on computer as per SCCM audit time. 
        
        
      
        

    .Inputs
        System.String
        You can pipe a ComputerName to Get-DHAddRemoveProgram
    .Outputs
        PSObject
                   
        NAME:      Get-DHAddRemoveProgram
        PURPOSE:   Build Software Profiles for W7 upgrade 
        VERSION:   1.0
#>



    [CmdletBinding()]         
    
    param(         
        [Parameter(         
        Mandatory=$false, 
        Position=1,        
        ValueFromPipeline=$True)]         
        [string[]]$ComputerName = $env:ComputerName,
        
        [Parameter(
        Mandatory=$false,
        ValueFromPipeline=$false)]
        [string]$SiteServer = "114.148.18.125",
        
                
        [Parameter(
        Mandatory=$false,
        ValueFromPipeline=$false)]
        [string]$NameSpace = "root\sms\site_DH1"
    )
    
    

    Process
    {   
        foreach ($Computer in $ComputerName)
        {
            $Query = "select * from SMS_G_System_COMPUTER_SYSTEM where Name=`'$computer`'"
            $ResourceID = Get-WmiObject -Query $Query -Namespace $NameSpace -ComputerName $SiteServer | Select-Object -ExpandProperty ResourceID -First 1

            $Query = "select * from SMS_G_System_ADD_REMOVE_PROGRAMS where ResourceID=`'$ResourceID`'"
            Get-WmiObject -Query $Query -Namespace $NameSpace -ComputerName $SiteServer | Select-Object DisplayName, Publisher, Version, InstallDate | 
            % {        
                $Hash = @{ 
                    Computer = $Computer
                    DisplayName = $_.DisplayName
                    Publisher = $_.Publisher
                    Version = $_.Version
                    InstallDate = $_.InstallDate        
                } 
                
                New-Object -TypeName PSObject -Property $Hash | 
                Select-Object Computer, DisplayName, Publisher, Version, InstallDate
            }
        }            
    }
}