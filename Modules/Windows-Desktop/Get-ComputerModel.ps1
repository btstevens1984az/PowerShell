function Get-ComputerModel 
{ 
<# 
.SYNOPSIS 
   Get model of remote computer. 
 
.DESCRIPTION 
    This function will get the model and Manufacturer of a remote computer by using the "get-wmiobject Win32_ComputerSystem" command. 
 
.EXAMPLE 
   Get-ComputerModel -Computername 8.148.212.15 
 
   Get's the model for computer1. 
 
.EXAMPLE 
   Get-ComputerModel -Computername 8.148.212.15 -credential (Get-Credential) 
 
   Get's the model for computer1 and prompts for the credentials to use. 
 
.EXAMPLE 
   Get-ComputerModel -Computername 8.148.212.15 | Format-Table 
 
   Get's the model for computer1 and formats output into table. 
 
.EXAMPLE 
   Get-ComputerModel -Computername 8.148.212.15,Computer2 | Export-Csv -Path C:\test.csv -NoTypeInformation 
 
   Get's the model for computer1 and computer2 and exports it to a CSV file. 
 
.EXAMPLE 
   Get-ADDomainController -Filter * | Get-ComputerModel 
 
   This examples get's the computer models of all DC's.  It requires the get-addomaincontroller Active Directory module. 
 
 
.LINK 
     
#> 
    [CmdletBinding()] 
    Param 
    ( 
        #The Computername/IP Address of the remote computer. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromPipeline=$true, 
                   Position=0)] 
        [Alias('Name', 'IPv4Address', 'CN')] 
        [string[]]$Computername, 
 
        [Parameter(Mandatory=$False)] 
        [System.Management.Automation.PSCredential]$credential 
    ) 
 
    Begin 
    { 
    } 
    Process 
    { 
 
    $Computername | ForEach-Object { 
        $parms = @{} 
        if ($credential) { $parms.Add('Credential', $credential)} 
 
        $Results = @{"Status"="" 
                        "Name"="$_" 
                        "Manufacturer"="" 
                        "Model"=""}      
 
        Write-Verbose -Message "Checking to see if $_ is online..." 
        If (Test-Connection -ComputerName $_ -Count 1 -Quiet -BufferSize 100 ) {        
            try { 
                Write-Verbose -Message "Running WMI query on $_" 
                $computerResults = Get-WMIObject -ComputerName $_ -class Win32_ComputerSystem @parms -ErrorAction Stop 
 
                $Results["Status"] = "Online" 
                $Results["Manufacturer"] = "$($computerResults.Manufacturer)" 
                $Results["Model"] = $($computerResults.Model) 
 
            } catch { 
                $Results["Status"] = "Failed: $($_.Exception.Message)" 
            } 
        } 
        Else { 
            $Results["Status"] = "Failed: $Computername is Offline." 
        } 
 
        return New-Object PSobject -Property $Results | Select-Object Name, Model, Manufacturer, Status 
    } 
 
 
    } 
    End 
    { 
    } 
}