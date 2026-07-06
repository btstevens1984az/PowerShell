# Purpose: ExtendProcess — Windows desktop configuration and management.
$Ownerhash = @{
           label= "Owner"
           expression = { if ($_.sessionID -gt 0)
                            {
                                $owner = $_.getowner()
                                if ($owner.returnvalue -eq 0)
                                {
                                    "$($owner.domain)\$($owner.user)"
                                }
                            }
                            else
                            {
                                "system"
                            }
                        }
           }
$ParentProcessName =@{
    label= "ParentProcessName"
    expression ={
                    $parentID = $_.ParentProcessId
                    (Get-wmiobject -class Win32_process -computer $_.__Server -filter "ProcessID = $parentID").name  
                }
}

$proc = Get-WmiObject win32_process
$proc | Select-Object name,$Ownerhash,sessionid,$ParentProcessName




#new  PSH v3 
Update-TypeData -TypeName "System.Management.ManagementObject#root\cimv2\Win32_Process" -MemberType ScriptProperty `
-MemberName Owner -value {
                       if ($this.sessionID -gt 0)
                            {
                                $owner = $this.getowner()
                                if ($owner.returnvalue -eq 0)
                                {
                                    "$($owner.domain)\$($owner.user)"
                                }
                            }
                            else
                            {
                                "system"
                            }
                        } 

Update-TypeData -TypeName "System.Management.ManagementObject#root\cimv2\Win32_Process" -MemberType ScriptProperty `
-memberName ParentProcessName -value {
     $parentID = $this.ParentProcessId
     (Get-wmiobject -class Win32_process -computer $this.__Server -filter "ProcessID = $parentID").name
                            
 }

 Get-WmiObject Win32_process | Select-Object name,owner,parentprocessname

