# Purpose: Get-ComputersMissingPatches — Windows Update and patch management.
Function Get-ComputersMissingPatches
{
Clear-Host
 
# Path to files
$filePath = "U:\Functions"
 
# the computers to check
$computerList = Get-Content -Path "$filePath\computers.txt"
 
# the KBs to check
$patchList = Get-Content -Path "$filePath\KBs.txt"
 
$E_Total = "" # exists total
$NE_Total = "" # not exists total
$Count = 0 # missing updates counter
$BoolCheck = 0 
 
  
foreach ($computer in $computerList)
{  
     
    # is machine online?
    $Ping = test-connection -ComputerName $computer -Count 2 -quiet 
  
    # yes, online
     if($Ping) 
        {         
        
        # get current list of hotfixes on machine
        $HotfixList = Get-HotFix -ComputerName $computer | select -Property "HotFixID"
  
        # cycle through each patch in list
        foreach($patch in $patchList)
        {         
            $BoolCheck=0
             
             
            # cycle through hotfixes on local machine
            foreach ($Hotfix in $HotfixList)                
            { 
 
                # compare local machine hotfixes with our list
                # if it matches, exists
                if ($patch -eq $Hotfix.HotFixID) 
                    {       
                        $BoolCheck=1                          
                        break
                      }             
                       
                        
                  }
                
               if ($found -eq 1) {
               $E_Total = "$E_Total,$patch"
               }
                
               if ($BoolCheck -eq 0) {
               # $patch
               $NE_Total = "$NE_Total,$patch"
               $Count=$Count+1
               }                
                    
            }
            # Write-Host "Found:   $Computer$E_Total"            
            Write-Host "$Computer,Missing $count$NE_Total"
            Write-Host " "
             
            # Clear session
            $E_Total = ""
            $NE_Total = ""
            $Count = 0
            $BoolCheck = 0
             
             
}
  
# no, not online
else 
{ 
Write-Host "$Computer,Not Online"
Write-Host " "
} 
}
}