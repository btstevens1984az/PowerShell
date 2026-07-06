# Purpose: Get-BlockedProcess — Windows desktop configuration and management.
<#    .Synopsis     Gets blocking process on SQL Server   .Description    Gets block process on SQL Server and allows you to kill the header blocker    SQL SCRIPT SOURCES:     http://www.databasejournal.com/features/mssql/article.php/3923371/Top-10-Transact-SQL-Statements-a-SQL-Server-DBA-Should-Know.htm   .Link     Http://toolmaker.brycoretechnologies.com #>

[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME
    
 )

function Get-QueryResults {

    Param (
        $SQLConnection,
        $Query
    )

    $ds = New-object "System.Data.DataSet" "BlockedProcessData"
    $da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($Query, $SQLConnection)
    $da.Fill($ds) | Out-Null
    if ($ds.Tables[0].Rows.Count  -gt 0) {
        return $ds
    }

    # Return an empty dataset
    $newRow = $ds.Tables[0].NewRow()
    $ds.Tables[0].Rows.Add($newRow)

    return $ds
    #return $null
    
}function Invoke-KillProcess {    Param (
        $SQLInstance,
        $SPID
    )        $ConnectionString = "Server=$SQLInstance;Integrated Security=SSPI;"    $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)    $query = "Kill $SPID"    #$tempresult = @()    Get-QueryResults -SQLConnection $cn -Query $query    if ($tempresult) {        return $true    }    return $tempresult}$sqlagentquery = [ordered]@{    "SQL Instance" = "SELECT           SERVERPROPERTY('MachineName') as Host,          SERVERPROPERTY('InstanceName') as Instance,          CONNECTIONPROPERTY('local_net_address') AS IPAddress,          SERVERPROPERTY('Edition') as Edition, /*shows 32 bit or 64 bit*/          SERVERPROPERTY('ProductLevel') as ProductLevel, /* RTM or SP1 etc*/          Case SERVERPROPERTY('IsClustered') when 1 then 'CLUSTERED' else          'STANDALONE' end as ServerType, @@VERSION as VersionNumber"    "Blocked Process" = "SELECT s.session_id 
                         ,r.STATUS 
                         ,r.blocking_session_id 'blocked by'
                         ,r.wait_type
                         ,wait_resource
                         ,r.wait_time / (1000.0) 'Wait Time (in Sec)'
                         ,r.cpu_time
                         ,r.logical_reads
                         ,r.reads
                         ,r.writes
                         ,r.total_elapsed_time / (1000.0) 'Elapsed Time (in Sec)'
                         ,Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
                         (
                            CASE r.statement_end_offset
                              WHEN - 1
                              THEN Datalength(st.TEXT)
                            ELSE r.statement_end_offset
                            END - r.statement_start_offset
                          ) / 2
                          ) + 1) AS statement_text
                          ,Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + 
                          Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text
                          ,r.command
                          ,s.login_name
                          ,s.host_name
                          ,s.program_name
                          ,s.host_process_id
                          ,s.last_request_end_time
                          ,s.login_time
                          ,r.open_transaction_count
                          FROM sys.dm_exec_sessions AS s
                          INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
                          CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
                          WHERE r.session_id != @@SPID
                          ORDER BY r.cpu_time DESC
                            ,r.STATUS
                            ,r.blocking_session_id                            ,s.session_id"}$checklistparams = @{    'ComputerName' = $ComputerName    'Class' = 'SqlServiceAdvancedProperty'    'ErrorAction' = 'SilentlyContinue'}if ($FS_Credential) {

    $checklistparams.Credential = $FS_Credential
}# Get the sqlservices running on the computer by querying wmi namespace of SQL Server. This works with SQL Server 2005 and greater$sqlwminamespace = @('ComputerManagement', 'ComputerManagement10', 'ComputerManagement11', 'ComputerManagement12')$installedinstance = @()if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) { #$psboundparameters# Check if we are invokging the call back function.# If we are execute it and exitif ($CallBackParams) {    #$CallBackParams    if ($CallBackParams['Instance'] -eq $null) {        $InstanceName = $ComputerName    }    else {        $InstanceName = "$ComputerName\$CallBackParams['Instance']"    }    #$InstanceName    $SPID = $CallBackParams.SPID    $callbackresult = Invoke-KillProcess -SQLInstance $InstanceName -SPID $SPID    #$callbackresult    if ($callbackresult) {        "Killed blocking process with SPID $SPID on $InstanceName"        return    }}foreach ($namespace in $sqlwminamespace) {    $getinstance = Get-WmiObject @checklistparams -Namespace "root\Microsoft\SqlServer\$namespace"    if ($getinstance) {        $installedinstance += $getinstance | Where-Object {$_.PropertyName -eq 'VERSION'} | Select-Object ServiceName, PropertyName, PropertyStrValue    }}# Once we have installed SQL Server instances on the server go through them and get the Blocking process if any$result = @()if ($installedinstance) {    #$installedinstance    foreach ($instance in $installedinstance) {        if ($instance.ServiceName -like '*ReportServer*') {           continue        }        if ($instance.ServiceName -like '*OLAPService*') {           continue        }        if ($instance.ServiceName -like '*ANALYSIS*') {           continue        }        $queryresult = @()        $ServiceName = $instance.ServiceName        if ($ServiceName -eq 'MSSQLSERVER') {            $ConnectionString = "Server=$ComputerName;Integrated Security=SSPI;"        }        else {            # Remove MSSQL$ from the servcie name            $ServiceName = $ServiceName.ToString().Replace('MSSQL$', '')            $ConnectionString = "Server=$ComputerName\$ServiceName;Integrated Security=SSPI;"
        }

        #$ConnectionString 
        $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)        foreach ($key in $sqlagentquery.Keys) {            #$sqlagentquery[$key]            $tempresult = @()            $tempresult = Get-QueryResults -SQLConnection $cn -Query $sqlagentquery[$key]            #$tempresult | gm             if (!($tempresult.Tables[0].Rows[0].IsNull(0))) {                $queryresult += $tempresult            }            $tempresult = $null        }         #$queryresult.Tables         #$queryresult.Tables.Count         # Check if we actually have a blocking process        if($queryresult.Tables.Count -le  1) {            "No blocked processes found"            return        }        if ($ServiceName -eq 'MSSQLSERVER') {            $header = "SQL Server Blocked processes for Instance {0} ran on {1}" -f ($ComputerName, (Get-Date))        }        else {            $header = "SQL Server Blocked Processes for Instance {0}\{1} ran on {2}" -f ($ComputerName, $ServiceName, (Get-Date))        } 

        $fsresult = Format-FSTypes -InputObject $queryresult.Tables -Type 'ForeScript.Types.SQLServerData' -Header $header
        $result += $fsresult        $queryresult = $null    }    } # Check if we actually have a blocking process <#if($result.Length -eq 1) {    "No blocked processes found"    return }#> # Output all of the blocked processe results foreach ($r in $result) {    $r }}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}