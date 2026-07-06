# Purpose: getComputerLastPwdSet — Windows desktop configuration and management.
$root=[ADSI]"LDAP://OU=BaseContainer,DC=Discovery,DC=Sanderson"
  $search=[System.DirectoryServices.DirectorySearcher]$root
  $Search.Filter="(&(objectcategory=computer))"
  $result=$search.FindAll()
"Computer Name|Organisational Unit|Last Password Change|Last Logon" > .\computers.txt

foreach ($Computer in $result)
{
   $parts = $Computer.properties.distinguishedname -split "," 
#   write-host  $parts
   Foreach ($namepart in $parts) 
   {
#        write-host  ("namepart",$namepart) -Separator "="
        $TypeName = $namepart -split "="
        switch ($TypeName[0]) 
        {
          "CN" 
                {
#                $ComputerName = $TypeName[1]
#                write-host  ("    CN=",$ComputerName)
                $OU = ""}
          "OU" {$OU=$TypeName[1], $OU -join "\"
#                write-host  ("    OU=",$OU)  
               }
       }
       $ComputerName = $Computer.properties.cn | out-string -stream
       $pwdlastset = [datetime]::FromFileTime($Computer.properties.item('pwdlastset')[0])
       If ($pwdlastset -eq "31-Dec-1600 4:00:00 PM")
       {$pwdlastset ="Never"}
       $LastLogon = [datetime]::FromFileTime($Computer.properties.item('lastLogonTimestamp')[0])
       If ($LastLogon -eq "31-Dec-1600 4:00:00 PM")
       {$LastLogon ="Never"}

   } 
    -join ($ComputerName, "|", $OU, "|", $pwdlastset, "|", $LastLogon) >> .\computers.txt  
 }



