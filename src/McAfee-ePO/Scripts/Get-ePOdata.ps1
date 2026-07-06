# Purpose: Get-ePOdata — McAfee ePolicy Orchestrator reporting.
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} # Causes WebClient to ignore certification validation
$Credential = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"
$WebClient = New-Object System.Net.WebClient
$WebClient.Credentials = $Credential.GetNetworkCredential()
$Computer = Read-Host -Prompt "Enter PC name or username"
$SearchURL = $ePOServer + "/remote/system.find?searchText=" + $Computer + "&:output=xml"
$Results = New-Object System.Collections.ArrayList
[XML]$ResultXML = $WebClient.DownloadString($SearchURL).Replace("OK:`r`n","")
foreach ($Result in $ResultXML.result.list.row) {
	$Object = New-Object PSObject
	$Object | Add-Member -MemberType NoteProperty -Name ParentID            -Value $Result.'EPOComputerProperties.ParentID'
	$Object | Add-Member -MemberType NoteProperty -Name ComputerName        -Value $Result.'EPOComputerProperties.ComputerName'
	$Object | Add-Member -MemberType NoteProperty -Name Description         -Value $Result.'EPOComputerProperties.Description'
	$Object | Add-Member -MemberType NoteProperty -Name SystemDescription   -Value $Result.'EPOComputerProperties.SystemDescription'
	$Object | Add-Member -MemberType NoteProperty -Name TimeZone            -Value $Result.'EPOComputerProperties.TimeZone'
	$Object | Add-Member -MemberType NoteProperty -Name DefaultLangID       -Value $Result.'EPOComputerProperties.DefaultLangID'
	$Object | Add-Member -MemberType NoteProperty -Name UserName            -Value $Result.'EPOComputerProperties.UserName'
	$Object | Add-Member -MemberType NoteProperty -Name DomainName          -Value $Result.'EPOComputerProperties.DomainName'
	$Object | Add-Member -MemberType NoteProperty -Name IPHostName          -Value $Result.'EPOComputerProperties.IPHostName'
	$Object | Add-Member -MemberType NoteProperty -Name IPV6                -Value $Result.'EPOComputerProperties.IPV6'
	$Object | Add-Member -MemberType NoteProperty -Name IPAddress           -Value $Result.'EPOComputerProperties.IPAddress'
	$Object | Add-Member -MemberType NoteProperty -Name IPSubnet            -Value $Result.'EPOComputerProperties.IPSubnet'
	$Object | Add-Member -MemberType NoteProperty -Name IPSubnetMask        -Value $Result.'EPOComputerProperties.IPSubnetMask'
	$Object | Add-Member -MemberType NoteProperty -Name IPV4x               -Value $Result.'EPOComputerProperties.IPV4x'
	$Object | Add-Member -MemberType NoteProperty -Name IPXAddress          -Value $Result.'EPOComputerProperties.IPXAddress'
	$Object | Add-Member -MemberType NoteProperty -Name SubnetAddress       -Value $Result.'EPOComputerProperties.SubnetAddress'
	$Object | Add-Member -MemberType NoteProperty -Name SubnetMask          -Value $Result.'EPOComputerProperties.SubnetMask'
	$Object | Add-Member -MemberType NoteProperty -Name NetAddress          -Value $Result.'EPOComputerProperties.NetAddress'
	$Object | Add-Member -MemberType NoteProperty -Name OSType              -Value $Result.'EPOComputerProperties.OSType'
	$Object | Add-Member -MemberType NoteProperty -Name OSVersion           -Value $Result.'EPOComputerProperties.OSVersion'
	$Object | Add-Member -MemberType NoteProperty -Name OSServicePackVer    -Value $Result.'EPOComputerProperties.OSServicePackVer'
	$Object | Add-Member -MemberType NoteProperty -Name OSBuildNum          -Value $Result.'EPOComputerProperties.OSBuildNum'
	$Object | Add-Member -MemberType NoteProperty -Name OSPlatform          -Value $Result.'EPOComputerProperties.OSPlatform'
	$Object | Add-Member -MemberType NoteProperty -Name OSOEMID             -Value $Result.'EPOComputerProperties.OSOEMID'
	$Object | Add-Member -MemberType NoteProperty -Name CPUType             -Value $Result.'EPOComputerProperties.CPUType'
	$Object | Add-Member -MemberType NoteProperty -Name CPUSpeed            -Value $Result.'EPOComputerProperties.CPUSpeed'
	$Object | Add-Member -MemberType NoteProperty -Name NumOfCPU            -Value $Result.'EPOComputerProperties.NumOfCPU'
	$Object | Add-Member -MemberType NoteProperty -Name CPUSerialNum        -Value $Result.'EPOComputerProperties.CPUSerialNum'
	$Object | Add-Member -MemberType NoteProperty -Name TotalPhysicalMemory -Value $Result.'EPOComputerProperties.TotalPhysicalMemory'
	$Object | Add-Member -MemberType NoteProperty -Name FreeMemory          -Value $Result.'EPOComputerProperties.FreeMemory'
	$Object | Add-Member -MemberType NoteProperty -Name FreeDiskSpace       -Value $Result.'EPOComputerProperties.FreeDiskSpace'
	$Object | Add-Member -MemberType NoteProperty -Name TotalDiskSpace      -Value $Result.'EPOComputerProperties.TotalDiskSpace'
	$Object | Add-Member -MemberType NoteProperty -Name IsPortable          -Value $Result.'EPOComputerProperties.IsPortable'
	$Object | Add-Member -MemberType NoteProperty -Name Vdi                 -Value $Result.'EPOComputerProperties.Vdi'
	$Object | Add-Member -MemberType NoteProperty -Name OSBitMode           -Value $Result.'EPOComputerProperties.OSBitMode'
	$Object | Add-Member -MemberType NoteProperty -Name LastAgentHandler    -Value $Result.'EPOComputerProperties.LastAgentHandler'
	$Object | Add-Member -MemberType NoteProperty -Name UserProperty1       -Value $Result.'EPOComputerProperties.UserProperty1'
	$Object | Add-Member -MemberType NoteProperty -Name UserProperty2       -Value $Result.'EPOComputerProperties.UserProperty2'
	$Object | Add-Member -MemberType NoteProperty -Name UserProperty3       -Value $Result.'EPOComputerProperties.UserProperty3'
	$Object | Add-Member -MemberType NoteProperty -Name UserProperty4       -Value $Result.'EPOComputerProperties.UserProperty4'
	$Object | Add-Member -MemberType NoteProperty -Name SysvolFreeSpace     -Value $Result.'EPOComputerProperties.SysvolFreeSpace'
	$Object | Add-Member -MemberType NoteProperty -Name SysvolTotalSpace    -Value $Result.'EPOComputerProperties.SysvolTotalSpace'
	$Object | Add-Member -MemberType NoteProperty -Name Tags                -Value $Result.'EPOLeafNode.Tags'
	$Object | Add-Member -MemberType NoteProperty -Name ExcludedTags        -Value $Result.'EPOLeafNode.ExcludedTags'
	$Object | Add-Member -MemberType NoteProperty -Name LastUpdate          -Value $([DateTime]::Parse($Result.'EPOLeafNode.LastUpdate'))
	$Object | Add-Member -MemberType NoteProperty -Name ManagedState        -Value $Result.'EPOLeafNode.ManagedState'
	$Object | Add-Member -MemberType NoteProperty -Name AgentGUID           -Value $Result.'EPOLeafNode.AgentGUID'
	$Object | Add-Member -MemberType NoteProperty -Name AgentVersion        -Value $Result.'EPOLeafNode.AgentVersion'
	[void]$Results.Add($Object)
}
$Results
