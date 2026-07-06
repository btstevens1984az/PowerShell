# Purpose: Get-HPCAErrorCode — HP Radia client automation and satellite servers.
function Get-HPCAErrorCode {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]$ComputerName,
        [switch]$CheckAD,
        [switch]$econly
    )
    try {
        if (Test-Path "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log") {
            $Log = Get-content "\\$ComputerName\c$\Program Files (x86)\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log" -Tail 100
        }
        elseif (Test-Path "\\$ComputerName\c$\Program Files\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log") {
            $Log = Get-content "\\$ComputerName\c$\Program Files\Hewlett-Packard\HPCA\Agent\Log\connect_Patch.log" -Tail 100
        }
        else {
            throw [System.IO.FileNotFoundException] "Log not found."
        }
        #$Groups = Get-ADComputer $ComputerName -property memberof | select -Expand memberof
        # if ($Groups -like '*HPCA*')
        #    {$inHPCAPatchGroup = "In HPCA Patch groups"}
        #else
        #    {$inHPCAPatchGroup = "Not in HPCA Patch Groups"}
        if ($log -like "*Radskman Exit Code*") {
            $ErrorCode = $log -like "*Radskman Exit Code*"
            $ErrorCode = $ErrorCode[-1].Substring($ErrorCode[-1].LastIndexOf('[')).trim('[').trim(']') 
            Write-Debug $ErrorCode
        }
        else {
            $ErrorCode = "Unknown"
        }
        if ($log -like "*ZMGRHOST*") {
            
            $Server = $log -like "*ZMGRHOST*"
            $Server = $Server.Substring($Server.LastIndexOf(':') + 1)
            Write-Debug $Server
        }
        else {
            $Server = "104.180.88.40"
        }
        if ($log -like "*Client Automation Agent Connect Version*") {
            $Version = $log -like "*Client Automation Agent Connect Version*"
            $Version = $Version.Substring($Version.LastIndexOf("---") + 5)
            Write-Debug $Version
        }
        else {
            $Version = "Unknown"
        }

        if ($log -like "*Closing log file on*") {
            $Date = $log -like "*Closing log file on*"
            $Date = $Date[-1].Substring($Date[-1].LastIndexOf('[') + 5, 6)
            Write-Debug $Date
        }
        else {
            $Date = "Unknown"
        }
        if ($log -like "*Client host name:*") {
            $LogComputerName = $log -like "*Client host name:*" 
            $LogComputerName = $LogComputerName.Substring($LogComputerName.LastIndexOf('[')).trim('[').trim(']')
            Write-Debug $LogComputerName
        }
        else {
            $LogComputerName = "Unknown"
        }
        if ($log[-1] -like "*being saved (v143)*") {
            
            $TimeStuck = $log[-1]
        }
        else {
            write-debug ($log[-1])
            $TimeStuck = "No"
        }
        if ($log[-1] -like "*Service Entitlement list*") {
            
            $nvdtree = $log[-1]
        }
        else {
            write-debug ($log[-1])
            $nvdtree = "No"
        }
        #$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
        #$DeployedOn = $RegKey.getValue("DeployedOn")
        #$DeployedBy = $RegKey.getValue("DeployedBy")
        #$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
        #$RegKey= $Reg.OpenSubKey("SYSTEM\\Setup")
        #$CloneTag = $RegKey.getValue("CloneTag")
        if ($LogComputerName -notmatch $ComputerName) {
            $NameMismatch = $True
        }
        else {
            $NameMismatch = $False    
        }
        if ($econly) {
            New-Object psobject -Property @{
                ComputerName = $ComputerName
                ErrorCode    = $ErrorCode
            }
        }
        else {
            
            New-Object psobject -Property @{
                ComputerName    = $ComputerName
                LogComputerName = $LogComputerName
                ErrorCode       = $ErrorCode
                Server          = $Server
                Version         = $Version
                Date            = $Date
                TimeStuck       = $TimeStuck
                nvdtree         = $nvdtree
                NameMismatch    = $NameMismatch
                #DeployedOn = $DeployedOn
                #DeployedBy = $DeployedBy
                #CloneTag = $CloneTag[0]
                #InPatchGroup = $inHPCAPatchGroup
            }
        }
                
    }
    catch [System.IO.FileNotFoundException] {
        New-Object psobject -Property @{
            ComputerName    = $ComputerName
            ErrorCode       = "Could not open log"
            Server          = "Could not open log"
            Version         = "Could not open log"
            Date            = "Could not open log"
            LogComputerName = "Could not open log"
            TimeStuck       = "Could not open log"
            nvdtree         = "Could not open log"
            NameMismatch    = "Could not open log"
            #DeployedOn = "Could not open log"
            #DeployedBy = "Could not open log"
            #CloneTag = "Could not open log"
            #InPatchGroup = "Could not open log"
        }
    }
}

function Get-HPCAErrorCodeParallel {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$InputObject
    )
    Invoke-Parallel -InputObject (get-content($InputObject)) -ScriptBlock {
        ."$_";
        Get-HPCAErrorCode $_
    } -Throttle 1000 -runspacetimeout 40
}


