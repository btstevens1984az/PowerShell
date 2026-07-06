# Purpose: AD-WildcardRemove — Active Directory user, group, and domain administration.
#   James Wylde

#----------------------------------------------------------------------------------------#
#   Modules


$user = "GROUP"
$group = "NAME TO SEARCH FOR"
$userGroup = Get-ADPrincipalGroupMembership -Identity $user | Select-Object -expand name | Where-Object ($_.name -like "*$group*")

foreach ($userGroup in $UserGroups) {
          $response = Read-Host ("remove user?")
          if ($response -match "^y$") {
               Remove-ADPrincipalGroupMembership -Identity $user -MemberOf $userGroup -WhatIf
          }
}
