# Purpose: Invoke-SQLServerCheckList — SQL Server administration and queries.
Function Invoke-SQLServerCheckList {<#    .Synopsis     Executes a series of SQL scripts againts a database server to retrieve SQL Agent job status   .Description    Executes a series of SQL scripts againts a database server to retrieve SQL Agent job status as it reates to backup jobs and other SQL Agent Jobs    CHECKLISTTYPE: Database    SQL SCRIPT SOURCES:     http://www.databasejournal.com/features/mssql/article.php/3923371/Top-10-Transact-SQL-Statements-a-SQL-Server-DBA-Should-Know.htm
    https://servergeeks.wordpress.com/2013/05/14/t-sql-monitoring-database-backup-status/
    http://thomaslarock.com/2012/05/how-to-find-long-running-backups-in-sql-server/
    https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/
    http://sqlrepository.co.uk/code-snippets/sql-dba-code-snippets/script-to-finds-failed-sql-server-agent-jobs/   .Link     Http://toolmaker.brycoretechnologies.com #>

[CmdletBinding()]
 Param (
    $ComputerName = $env:COMPUTERNAME
    
 )

function Get-QueryResults {

    Param (
        $SQLConnection,
        $Query
    )

    try {
    $ds = New-object "System.Data.DataSet" "SQLServerChecklistData"
    #$ds = New-object "System.Data.DataTable" "SQLServerChecklistData"
    $da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($Query, $SQLConnection)
    $da.Fill($ds) | Out-Null
    #return @(,$ds)

    if ($ds.Tables[0].Rows.Count  -gt 0) {
        return $ds
    }


    # Return an empty dataset
    $newRow = $ds.Tables[0].NewRow()
    #$newRow[0] = $Query
    $ds.Tables[0].Rows.Add($newRow)  

    return $ds

    }
    catch {
        # Return a dataset with the error
        $ds = New-object "System.Data.DataSet" "SQLServerChecklistData"
        $dt = New-object "System.Data.DataTable" "SQLServerChecklistData"
        $dt.Columns.Add('Query')
        $dt.Columns.Add('Error')
        $ds.Tables.Add($dt)
        $newRow = $ds.Tables[0].NewRow()
        $newRow[0] = $Query
        $newRow[1] = $_
        $ds.Tables[0].Rows.Add($newRow)  

        $ds
    }


    
}$sqlagentquery = [ordered]@{    "SQL Instance" = "SELECT           SERVERPROPERTY('MachineName') as Host,          SERVERPROPERTY('InstanceName') as Instance,          SERVERPROPERTY('Edition') as Edition, /*shows 32 bit or 64 bit*/          SERVERPROPERTY('ProductLevel') as ProductLevel, /* RTM or SP1 etc*/          Case SERVERPROPERTY('IsClustered') when 1 then 'CLUSTERED' else          'STANDALONE' end as ServerType, @@VERSION as VersionNumber"    "SysAdmin Role" = "SELECT l.name, l.createdate, l.updatedate, l.accdate, l.status, l.denylogin, l.hasaccess, l.isntname, l.isntgroup, l.isntuser                 FROM master.dbo.syslogins l WHERE l.sysadmin = 1 OR l.securityadmin = 1"    "Backup Status" = "SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, msdb.dbo.backupset.database_name, msdb.dbo.backupset.backup_start_date,

               msdb.dbo.backupset.backup_finish_date, msdb.dbo.backupset.expiration_date,

               CASE msdb..backupset.type

                WHEN 'D' THEN 'Database'

                WHEN 'L' THEN 'Log'

              END AS backup_type,

             msdb.dbo.backupset.backup_size, msdb.dbo.backupmediafamily.logical_device_name, msdb.dbo.backupmediafamily.physical_device_name,

             msdb.dbo.backupset.name AS backupset_name, msdb.dbo.backupset.description

             FROM msdb.dbo.backupmediafamily INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id

             WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 1)

             ORDER BY msdb.dbo.backupset.database_name, msdb.dbo.backupset.backup_finish_date"    "Long Running Backup" = "declare @MinAvgSecsDuration int = 2
                             ;
                             WITH BackupHistData AS
                             (
                                SELECT database_guid, type, MAX(backup_set_id) AS [MAX_BSID]
	                            ,AVG(CAST(DATEDIFF(s, backup_start_date, backup_finish_date) AS int)) AS [AVG]
	                            ,STDEVP(CAST(DATEDIFF(s, backup_start_date, backup_finish_date) AS int)) AS [SIGMA]
	                            FROM msdb.dbo.backupset GROUP BY database_guid, type
                              )
                                SELECT bup.database_name, bup.backup_set_id, bup.type
	                            ,CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int) AS [backup_time_sec]
	                            ,bhd.[AVG] as [avg_sec] ,(1.0*bhd.[AVG]+2.0*bhd.SIGMA) as [max_duration_sec]
                                 
                                 FROM BackupHistData bhd INNER JOIN msdb.dbo.backupset bup ON bhd.database_guid = bup.database_guid

                                /*Filter for the outliers*/
                                WHERE CAST(DATEDIFF(s, bup.backup_start_date, bup.backup_finish_date) AS int) > (1.0*bhd.[AVG]+2.0*bhd.SIGMA)

                                /*Filter for only the most recent backup, if desired*/
                                AND bup.backup_set_id = bhd.MAX_BSID

                                /*Filter for backups with an average duration time, if desired*/
                                AND bhd.[AVG] >= @MinAvgSecsDuration

                                /*Filter for specific backup types, if desired*/
                                AND bhd.type IN ('D', 'I', 'L')"    "Failed SQL Agent Jobs" = "DECLARE @Date datetime 
                      SET @Date = DATEADD(dd, -1, GETDATE()) -- Last 1 day


                     SELECT j.[name] [Agnet_Job_Name], js.step_name [Step_name], js.step_id [Step ID], js.command [Command_executed], js.database_name [Databse_Name],
                     msdb.dbo.agent_datetime(h.run_date, h.run_time) as [Run_DateTime] , h.sql_severity [Severity], h.message [Error_Message], h.server [Server_Name],
                     h.retries_attempted [Number_of_retry_attempts],
                     CASE h.run_status 
                      WHEN 0 THEN 'Failed'
                      WHEN 1 THEN 'Succeeded'
                      WHEN 2 THEN 'Retry'
                      WHEN 3 THEN 'Canceled'
                    END as [Job_Status],
                    CASE js.last_run_outcome
                      WHEN 0 THEN 'Failed'
                      WHEN 1 THEN 'Succeeded'
                      WHEN 2 THEN 'Retry'
                      WHEN 3 THEN 'Canceled'
                      WHEN 5 THEN 'Unknown'
                   END as [Outcome_of_the_previous_execution]
                   FROM msdb.dbo.sysjobhistory h INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id 
                   INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id AND h.step_id = js.step_id
                   WHERE h.run_status = 0 AND msdb.dbo.agent_datetime(h.run_date, h.run_time)> @Date                    ORDER BY h.instance_id DESC"    "Log Running Agent Jobs" = "Declare @Date1 datetime
                                Declare @Date2 datetime

                                Set @Date1 = DATEADD(dd, -2, GETDATE()) --2 Days ago
                                Set @Date2 = DATEADD(dd, -1, GETDATE()) --1 day ago

                                select j.name as 'JobName', s.step_id as 'Step', s.step_name as 'StepName',
                                msdb.dbo.agent_datetime(run_date, run_time) as 'RunDateTime',
                                ((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) as 'RunDurationMinutes'
                                From msdb.dbo.sysjobs j 
                                INNER JOIN msdb.dbo.sysjobsteps s 
                                ON j.job_id = s.job_id
                                INNER JOIN msdb.dbo.sysjobhistory h 
                                ON s.job_id = h.job_id 
                                AND s.step_id = h.step_id 
                                AND h.step_id <> 0
                                where j.enabled = 1   --Only Enabled Jobs
                                and  ((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) > 10 -- Jobs running longer than 10 minutes

                                and msdb.dbo.agent_datetime(run_date, run_time) 
                                BETWEEN @Date1 and @Date2 "    "Running SQL Agent Jobs" = "SELECT SYSJOBS.Name, SYSJOBS.Job_Id, SYSPROCESSES.HostName, SYSPROCESSES.LogiName, * 
                               FROM MSDB.dbo.SYSJOBS JOIN MASTER.dbo.SYSPROCESSES
                               ON SUBSTRING(SYSPROCESSES.PROGRAM_NAME,30,34) = MASTER.dbo.fn_varbintohexstr ( SYSJOBS.job_id) "}$checklistparams = @{    'ComputerName' = $ComputerName    'Class' = 'SqlServiceAdvancedProperty'    'ErrorAction' = 'SilentlyContinue'}if ($FS_Credential) {

    $checklistparams.Credential = $FS_Credential
}# Get the sqlservices running on the computer by querying wmi namespace of SQL Server. This works with SQL Server 2005 and greater$sqlwminamespace = @('ComputerManagement', 'ComputerManagement10', 'ComputerManagement11', 'ComputerManagement12')$installedinstance = @()if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) { #try {foreach ($namespace in $sqlwminamespace) {    $getinstance = Get-WmiObject @checklistparams -Namespace "root\Microsoft\SqlServer\$namespace"    if ($getinstance) {        $installedinstance += $getinstance | Where-Object {$_.PropertyName -eq 'VERSION'} | Select-Object ServiceName, PropertyName, PropertyStrValue    }}# Once we have installed SQL Server instances on the server go through them and get the SQL Agent Status#$queryresult = @()$result = @()if ($installedinstance) {    #$installedinstance    foreach ($instance in $installedinstance) {        if ($instance.ServiceName -like '*ReportServer*') {           continue        }        if ($instance.ServiceName -like '*OLAPService*') {           continue        }        if ($instance.ServiceName -like '*ANALYSIS*') {           continue        }        $queryresult = @()        $ServiceName = $instance.ServiceName        if ($ServiceName -eq 'MSSQLSERVER') {            $ConnectionString = "Server=$ComputerName;Integrated Security=SSPI;"        }        else {            # Remove MSSQL$ from the servcie name            $ServiceName = $ServiceName.ToString().Replace('MSSQL$', '')            $ConnectionString = "Server=$ComputerName\$ServiceName;Integrated Security=SSPI;"
        }

        #$ConnectionString 
        $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)        foreach ($key in $sqlagentquery.Keys) {            #$sqlagentquery[$key]            $queryresult += Get-QueryResults -SQLConnection $cn -Query $sqlagentquery[$key]        }        #$queryresult.Tables        if ($ServiceName -eq 'MSSQLSERVER') {            $header = "SQL Server Checklist for Instance {0} ran on {1}" -f ($ComputerName, (Get-Date))        }        else {            $header = "SQL Server Checklist for Instance {0}\{1} ran on {2}" -f ($ComputerName, $ServiceName, (Get-Date))        } 

        $fsresult = Format-FSTypes -InputObject $queryresult.Tables -Type 'ForeScript.Types.SQLServerData' -Header $header
        $result += $fsresult        $queryresult = $null        $cn.Close()    }    } #$queryresult.Tables <#if ($ServiceName -eq 'MSSQLSERVER') {    $header = "SQL Server Checklist for Instance {0} ran on {1}" -f ($ComputerName, (Get-Date)) } else {    $header = "SQL Server Checklist for Instance {0}\{1} ran on {2}" -f ($ComputerName, $ServiceName, (Get-Date)) } 

 $fsresult = Format-FSTypes -InputObject $queryresult.Tables -Type 'ForeScript.Types.SQLServerChecklist' -Header $header
 $fsresult#> # Output all of the ForeScript.Types.SQLServerChecklist results foreach ($r in $result) {    $r } <#} catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }#>}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}}