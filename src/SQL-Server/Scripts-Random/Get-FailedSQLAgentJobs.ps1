# -----------------------------------------------------------------------------------------
# Script: Get-FailedSQLAgentJobs.ps1
# Date: September 19, 2015
# Version: 1.0
# Purpose: This script is used to retrive failed SQL Server Agent jobss.
#
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3
<#
    .SYNOPSIS        Retrieve failed SQL Server Agent Jobs on local and remote systems.
        .DESCRIPTION        Uses WMI to find all the SQL Server instances on a local or remote computer and then quereis each SQL Server instance for teh failed
        SQL Server Agent jobs.

    .Link 
        https://toolsmith.brycoretechnologies.com
    
        SQL SCRIPT SOURCES: 
        https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/
        http://sqlrepository.co.uk/code-snippets/sql-dba-code-snippets/script-to-finds-failed-sql-server-agent-jobs/
#>
[Cmdletbinding()]
Param (
    $ComputerName = $env:COMPUTERNAME
)


function Get-QueryResults {

    Param (
        $SQLConnection,
        $Query
    )

    #try {
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

    <#}
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
    }#>


    
}$sqlagentquery = [ordered]@{    "Failed SQL Agent Jobs" = "DECLARE @Date datetime 
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
                   WHERE h.run_status = 0 AND msdb.dbo.agent_datetime(h.run_date, h.run_time)> @Date                    ORDER BY h.instance_id DESC"}$sqlagentjobsparams = @{    'ComputerName' = $ComputerName    'Class' = 'SqlServiceAdvancedProperty'    'ErrorAction' = 'SilentlyContinue'}if ($FS_Credential) {

    $sqlagentjobsparams.Credential = $FS_Credential
}# Get the sqlservices running on the computer by querying wmi namespace of SQL Server. This works with SQL Server 2005 and greater$sqlwminamespace = @('ComputerManagement', 'ComputerManagement10', 'ComputerManagement11', 'ComputerManagement12')$jobstatusresult = @()$installedinstance = @()if (Test-Connection -Computer $ComputerName -Count 1 -BufferSize 16 -Quiet ) { #try {    foreach ($namespace in $sqlwminamespace) {        $getinstance = Get-WmiObject @sqlagentjobsparams -Namespace "root\Microsoft\SqlServer\$namespace"        if ($getinstance) {            $installedinstance += $getinstance | Where-Object {$_.PropertyName -eq 'VERSION'} | Select-Object ServiceName, PropertyName, PropertyStrValue        }    }    # Once we have installed SQL Server instances on the server go through them and get the SQL Agent Job Status        if ($installedinstance) {        foreach ($instance in $installedinstance) {            if ($instance.ServiceName -like '*ReportServer*') {                continue            }            if ($instance.ServiceName -like '*OLAPService*') {                continue            }            if ($instance.ServiceName -like '*ANALYSIS*') {                continue            }            $queryresult = @()                        $ServiceName = $instance.ServiceName            if ($ServiceName -eq 'MSSQLSERVER') {                $ConnectionString = "Server=$ComputerName;Integrated Security=SSPI;"            }            else {                # Remove MSSQL$ from the servcie name                $ServiceName = $ServiceName.ToString().Replace('MSSQL$', '')                $ConnectionString = "Server=$ComputerName\$ServiceName;Integrated Security=SSPI;"
            }

            #$ConnectionString 
            $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)            foreach ($key in $sqlagentquery.Keys) {                                #$sqlagentquery[$key]                $queryresult += Get-QueryResults -SQLConnection $cn -Query $sqlagentquery[$key]            }            #$queryresult.Tables            foreach ($table in $queryresult.Tables) {                if ($table.IsNull(0)) {                continue            }
            $queryresulthash = [ordered]@{                "Computer Name" = $ComputerName;                "SQL Server Instance" = $table.Item('Server_Name');                "Agent Job Name" = $table.Item('Agnet_Job_Name');                "Step Name" = $table.Item('Step_name');                "Step ID" = $table.Item('Step ID');                "Command Executed " = $table.Item('Command_executed');                "Databse Name" = $table.Item('Databse_Name');                "Run DateTime" = $table.Item('Run_DateTime').ToString();                "Severity" = $table.Item('Severity');                "Error Message" = $table.Item('Error_Message');                "Number of retry attempts" = $table.Item('Number_of_retry_attempts');                "Job Status" = $table.Item('Job_Status');                "Outcome of the previous execution" = $table.Item('Outcome_of_the_previous_execution')            }            $objjobstatus = New-Object -TypeName PSObject -Property $queryresulthash            $jobstatusresult += $objjobstatus            }            $queryresult = $null            $cn.Close()                }        $jobstatusresult        }  <#} catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $ComputerName"       $ExceptionMessage
     }#>}
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}