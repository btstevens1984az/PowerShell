function Get-DSCReport
{
<#
.Synopsis
   Sample function for retrieving DSC Reports from the standard WMF5 pull server.
.DESCRIPTION
   Sample function for retrieving DSC Reports from the standard WMF5 pull server.
.EXAMPLE
    $computers = 'testsrv1','testsrv2','testsrv3'
   Get-DSCReport -computerName $computers  | Sort-Object startdate -Descending | Out-GridView
.EXAMPLE
    #Retrieve all properties
   Get-DSCReport -computerName $computers -properties *
.Example
    #Specify Pull server
    Get-dscreport -computername "43.85.227.34://pull2.contoso.com:8080/PSDSCPullServer.svc"
.EXAMPLE
    #Specfify agent id to avoid having to contact managed nodes to retrieve the agent id.
    get-dscreport -AgentIDs "1216bdff-4fb7-43c9-9e01-f3aa884418cb","2e1114fc-d5ec-4253-91dd-2673af82889e"
   Tested against a WMF5.1 2016 pull server.
   Will likely require version 1.1 of the PSDesiredStateConfiguration module
   to ensure correct formatting of ResourcesInDesiredState and ResourcesNotInDesiredState when Tostring() is 
   invoked (i.e Out-Gridview).
   WMF version 5 requirement put in since version 4 simply hasn't been tested but besides the
   module version discussed above for PSDsiredStateConfguration, I can't think of any core PowerShell functionality
   used from a version later than 3.
#>

#Requires -version 5
#Requires -module PSDesiredStateConfiguration
    param(
    [cmdletbinding(DefaultParameterSetName='Computer')]
    [parameter(ParameterSetName='Computer',Mandatory)]
    [string[]]$computerName = @('testsrv1') ,
    [parameter(ParameterSetName='Computer')]
    [parameter(ParameterSetName='AgentID')]
    [ValidatePattern("^(http|https)")]
    [string]$reportSrvUrl = "https://pull2.kaylos.lab:8080/PSDSCPullServer.svc",
    [parameter(ParameterSetName='AgentID',
                Mandatory,
                HelpMessage = "Provide one or more agent ids to query for")]
    [string[]]$AgentIDs,
    [parameter(ParameterSetName='Computer')]
    [parameter(ParameterSetName='AgentID')]
    [string[]]$properties = @(    
                            'ComputerName',        
                            'InDesiredState',
                            'ConfigurationMode',
                            'ResourcesInDesiredState',
                            'ResourcesNotInDesiredState',
                            'RebootRequested',
                            'Status',
                            'ResourcesInDesiredStateText',
                            'ResourcesNotInDesiredStateText',
                            'startDate',
                            'EndDate',
                            'ConfigurationNames',
                            'ConifgurationDate',
                            'ConifgurationGenHost', 
                            'OsVersion',
                            'PsVersion',                        
                            'OperationType',
                            'JobId',      
                            'RefreshMode',
                            'IPv4Addresses',                                              
                            'StatusDataPS',
                            'AdditionalData',
                            'Errors')
        )
    if ($computername)
    {$agentids = (Get-DscLocalConfigurationManager -CimSession $computerName).agentid}

    foreach ($AgentId in $agentIDs)
    {
    $requestUri = "$reportSrvUrl/Nodes(AgentId='$AgentId')/Reports"
    Write-Verbose "Querying for $agentID"
    $request = Invoke-WebRequest -Uri $requestUri  -ContentType "application/json;odata=minimalmetadata;streaming=true;charset=utf-8" `
               -UseBasicParsing -Headers @{Accept = "application/json";ProtocolVersion = "2.0"} 
               #-ErrorAction SilentlyContinue -ErrorVariable ev
    $object = ConvertFrom-Json $request.content 
    $rtnObjs = $object.value
        Foreach($rtnobj in $rtnobjs)
        {
        $rtnobj | Add-Member -Name StatusDataPS -MemberType NoteProperty -Value ( $rtnObj.statusdata | ConvertFrom-Json)
        #Filter for only data with resource info
        if (!($rtnObj.StatusDataPS.ResourcesInDesiredState) -and !($rtnObj.StatusDataPS.ResourcesNotInDesiredState))
           {
               continue
           }
        $rtnobj | add-member -name ComputerName -MemberType NoteProperty -Value ($rtnobj.statusdataPS.hostname)
        $rtnobj | add-member -name IPv4Addresses -MemberType NoteProperty -Value ($rtnobj.statusdataPS.IPV4Addresses)
        $rtnobj | Add-Member -name ResourcesInDesiredState -MemberType NoteProperty -Value ($rtnobj.statusdataPS.ResourcesInDesiredState)
        $rtnobj | Add-Member -name ResourcesNotInDesiredState -MemberType NoteProperty -Value ($rtnobj.statusdataPS.ResourcesNotInDesiredState)
        $rtnobj | Add-Member -name ResourcesInDesiredStateText -MemberType NoteProperty -Value ($rtnobj.ResourcesInDesiredState.resourceid -join ';')
        $rtnobj | Add-Member -name ResourcesNotInDesiredStateText -MemberType NoteProperty -Value ($rtnobj.ResourcesNotInDesiredState.resourceid -join ';')
        $rtnobj | Add-Member -name StartDate -MemberType NoteProperty -Value ([datetime]($rtnobj.starttime)) 
        $rtnobj | Add-Member -name EndDate -MemberType NoteProperty -Value ([datetime]($rtnobj.endtime))
        $rtnObj | Add-Member -Name InDesiredState -MemberType ScriptProperty -Value {
                            if($this.ResourcesInDesiredState -ne $null -and $this.ResourcesNotInDesiredState -eq $null){$true} 
                            elseif($this.ResourcesNotInDesiredState) {$false}
                            else{"unknown"} 
                            }
        $rtnObj | Add-Member -Name OSVersion -MemberType ScriptProperty -Value {((($this.AdditionalData | where key -eq osversion).value -split ':')[1] -split ',' | select -First 1) -replace '"'}
        $rtnObj | Add-Member -Name PSVersion -MemberType ScriptProperty -Value {(((($this.AdditionalData | where key -eq psversion).value) -split ",")[1] -split ':')[1] -replace '"'}
        $rtnObj | Add-Member -Name ConfigurationMode -MemberType NoteProperty -Value ($rtnObj.StatusDataPS.MetaConfiguration.ConfigurationMode)
        $rtnObj | Add-Member -Name ConifgurationDate -MemberType NoteProperty -Value ([datetime](($rtnObj.StatusDataPS.MetaData -split ';') -replace "\w+:\W")[3])
        $rtnObj | Add-Member -Name ConifgurationGenHost -MemberType NoteProperty -Value ((($rtnObj.StatusDataPS.MetaData -split ';') -replace "\w+:\W")[4]) 
        $rtnObj | Add-Member -Name ConfigurationNames -MemberType NoteProperty -Value ($rtnObj.statusdataps.MetaConfiguration.ConfigurationDownloadManagers.configurationNames)
        #region update TypeInfo 
        foreach ($obj  in $rtnobj.StatusDataPS.ResourcesInDesiredState)
        {
            $obj.Psobject.Typenames.Insert(0,"Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/DesiredStateConfiguration/MSFT_ResourceInDesiredState")
        }
        foreach ($obj  in $rtnobj.StatusDataPS.ResourcesNotInDesiredState)
        {

            $obj.Psobject.Typenames.Insert(0,"Microsoft.Management.Infrastructure.CimInstance#root/Microsoft/Windows/DesiredStateConfiguration/MSFT_ResourceNotInDesiredState")
        }

        #endregion Update TypeInfo
        $rtnobj | Select-Object -Property $properties
            
        }
    }
}
$computers = "testsrv3","testsrv4","testsrv5"
$computers = "testsrv1","testsrv2","testsrv3"
$results = Get-DSCReport -computerName $computers  | Sort-Object startdate -Descending 


$results | ogv
#$results[0].StatusDataPS

#Test-DscConfiguration -CimSession $computers -Detailed
#
#$lcm = Get-DscLocalConfigurationManager -CimSession testsrv5
#$lcm.PartialConfigurations