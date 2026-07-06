# Purpose: getUserLastPwdSet — General-purpose PowerShell utilities.
$root=[ADSI]"LDAP://OU=BaseContainer,DC=example,DC=local"
  $search=[System.DirectoryServices.DirectorySearcher]$root
  $Search.Filter="(&(objectcategory=user))"
  $result=$search.FindAll()
#Try {del .\Users.txt} 
#Catch {Continue} 
"Logon Name|User Name|Organisational Unit|Last Password Change|Last Logon" > .\ADC-Users.txt

foreach ($User in $result)
{
   $parts = $User.properties.distinguishedname -split "," 
#   write-host  $parts
   Foreach ($namepart in $parts) 
   {
#        write-host  ("namepart",$namepart) -Separator "="
        $TypeName = $namepart -split "="
        switch ($TypeName[0]) 
        {
          "CN" {$UserName = $TypeName[1]
#                write-host  ("    CN=",$UserName)
                $OU = ""}
          "OU" {$OU=$TypeName[1], $OU -join "\"
#                write-host  ("    OU=",$OU)  
               }
       }
       $pwdlastset = [datetime]::FromFileTime($User.properties.item('pwdlastset')[0])
       $LastLogon = [datetime]::FromFileTime($User.properties.item('lastLogonTimestamp')[0])
       $LogonName = $User.properties.samaccountname | out-string -stream
   } 
    -join ($LogonName, "|", $UserName, "|", $OU, "|", $pwdlastset, "|", $LastLogon) >> .\ADC-Users.txt  
 }



