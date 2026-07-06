# Purpose: getwineventxpathfilter — General-purpose PowerShell utilities.
#this does not work
[xml]$filter = @"
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-Diagnostics-Performance/Operational">
    <Select Path="Microsoft-Windows-Diagnostics-Performance/Operational">*[System[(EventID=302)]]</Select>
  </Query>
</QueryList>
"@

$events = Get-WinEvent -FilterXPath $filter