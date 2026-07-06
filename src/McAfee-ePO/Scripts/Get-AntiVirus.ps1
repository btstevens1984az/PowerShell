# Purpose: Get-AntiVirus — McAfee ePolicy Orchestrator reporting.
Function Get-Antivirus {
    Param([System.Management.Automation.PSCredential]$credential)
    
BEGIN { 
    
        #set to Continue if you want to see Warning messages
        $WarningPreference="SilentlyContinue"
        
        #Set to Continue if you want to see Debug messages
        $DebugPreference="SilentlyContinue"
        
        #Set to Continue if you want to disable the 
        #function's error handling
        $errorActionPreference="SilentlyContinue"
        
        Write-Debug "Starting Get-Antivirus function"
        
        If ($credential) {
            Write-Debug ("Using alternate credentials:"+ ($credential.username))
         }       

    }

PROCESS {
    
        Trap {
            if ($_.Exception -match "RPC server is unavailable") {
                Write-Warning "$computername is not available via RPC."
                continue
            }
            elseif ($_.Exception -match "invalid namespace") {
                Write-Warning "root\securitycenter namespace not found on $computername."
                continue
            }
            elseif ($_.Exception -match "access is denied") {
                Write-Warning "Access denied to $computername."
                continue
            }
            else {
                Write-Warning "There was an error"
                Write-Warning $_
                continue
            }
        }
     
    
        if ($av) {
            Write-Debug "Removing leftover `$av variable"
            Remove-Variable av
        }
     
        if ($_) {
            $Computername=$_
        }
        else {
            $Computername=$env:computername
        }
    
        Write-Debug "Scanning $computername"
        if ($credential) {
            #use alternate credentials if supplied
            $av=Get-WmiObject -namespace root\securitycenter `
            -class antivirusproduct -computername $Computername `
            -Credential $credential -ErrorAction Stop
        }
        else {
            $av=Get-WmiObject -namespace root\securitycenter `
            -class antivirusproduct -computername $Computername `
            -ErrorAction Stop
            }
        
        if ($av.CompanyName) {
            Write-Debug ($av | Out-String)
            # add computer name and ScanDate properties 
            Write-Debug "Adding custom properties"
            $av | Add-Member -MemberType "Noteproperty" `
              -Name "ProductFound" -value $true 
            $av | Add-Member -MemberType "NoteProperty" `
              -Name "Computername" -Value $Computername.toUpper() 
            $av | Add-Member -MemberType "NoteProperty" `
              -Name "ScanDate" -Value (Get-Date) 
        }
        else {
            Write-Debug "No Antivirus product found on $computername."
            Write-Warning "No Antivirus product found on $computername."
            
            $av | Add-Member -MemberType "Noteproperty" `
              -Name "ProductFound" -value $False
            $av | Add-Member -MemberType "NoteProperty" `
              -Name "Computername" -Value $Computername.ToUpper() 
            $av | Add-Member -MemberType "NoteProperty" `
              -Name "ScanDate" -Value (Get-Date)
        }   
        
            #write result to pipeline
            $av 
        
        } #end Process script block

END {
       Write-Debug "Ending Get-Antivirus function"
   }
 
}
$env:computername | Get-Antivirus


