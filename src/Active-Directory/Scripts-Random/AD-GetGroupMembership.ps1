# Purpose: AD-GetGroupMembership — Active Directory user, group, and domain administration.

$users = Get-Content -Path c:\temp\users.txt

foreach($user in $users){

    Get-ADUser $user -Properties memberof | Select-Object name,@{n="MemberOf";e={($_.memberof -replace 'CN=(.+?)(OU|DC)=.+','$1')} } | Export-csv -Append c:\temp\memberof.csv
}


$users = Get-Content -Path c:\temp\users.txt

foreach($user in $users){

    (& "cmd.exe" @("/c", "net user $user /domain") | Select-String 'Full name')[0]
    (& "cmd.exe" @("/c", "net user $user /domain") | Select-String 'Global group memberships' -Context 1,6)[0]
}