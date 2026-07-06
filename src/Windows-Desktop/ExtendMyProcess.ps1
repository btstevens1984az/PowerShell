# Purpose: ExtendMyProcess — Windows desktop configuration and management.
     $computers = "syddc01","w7client"
 $objs = foreach ($comp in  $computers)
 {
    $procs = Get-WmiObject -ComputerName $comp -Class Win32_process
    Foreach ($proc in $procs)
    {$objProps = @{
                    name= $proc.name
                    Processid= $proc.ProcessId
                    ParentProcessid = $proc.ParentProcessId
                    computername = $proc.__server
                    owner = & {if ($proc.sessionID -gt 0)
                                {
                                    $owner = $proc.getowner()
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
        $MyProcess = New-Object PSobject -Property $objProps
        $MyProcess.Psobject.Typenames.Insert(0,"Jeff.Process.Type")
        $myprocess
    }
}


Update-TypeData -TypeName "Jeff.Process.Type" -MemberType ScriptProperty `
-memberName ParentProcessName -value {
     $parentID = $this.ParentProcessId
     (Get-wmiobject -class Win32_process -computer $this.computername -filter "ProcessID = $parentID").name
                            
 }