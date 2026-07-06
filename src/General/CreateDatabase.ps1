# Purpose: CreateDatabase — General-purpose PowerShell utilities.
# Creates the database and tables for ConfigMgr Client Health @AndersRodland.
[CmdletBinding()] 
param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$SQLServer
)

$CurrentVersion = '0.6.4'

$server = $SQLServer
$database = 'ClientHealth'
$domain = ((Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Domain) -replace ('(\.).*','')).ToUpper()


# Invoke-SqlCmd2 - Created by Chad Miller
function Invoke-Sqlcmd2 
{ 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
    [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
    [Parameter(Position=7, Mandatory=$false)] [ValidateScript({test-path $_})] [string]$InputFile, 
    [Parameter(Position=8, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As="DataRow" 
    ) 
 
    if ($InputFile) 
    { 
        $filePath = $(resolve-path $InputFile).path 
        $Query =  [System.IO.File]::ReadAllText("$filePath") 
    } 
 
    $conn=new-object System.Data.SqlClient.SQLConnection 
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
    $conn.ConnectionString=$ConnectionString 
     
    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
    if ($PSBoundParameters.Verbose) 
    { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
        $conn.add_InfoMessage($handler) 
    } 
     
    $conn.Open() 
    $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
    $cmd.CommandTimeout=$QueryTimeout 
    $ds=New-Object system.Data.DataSet 
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    [void]$da.fill($ds) 
    $conn.Close() 
    switch ($As) 
    { 
        'DataSet'   { Write-Output ($ds) } 
        'DataTable' { Write-Output ($ds.Tables) } 
        'DataRow'   { Write-Output ($ds.Tables[0]) } 
    } 
}

Function Get-DBVersion {
    $query = "SELECT Version from dbo.Configuration"
    try {
        $version = Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        $obj = $version | Select-Object -ExpandProperty Version
    }
    catch {
        try {
            $query = "SELECT ClientHealth from dbo.Configuration"
            $version = Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
            $obj = $version | Select-Object -ExpandProperty ClientHealth
        }
        catch {
            $obj = 0
        }
    }
    Write-Output $obj
}


function New-ClientHealthDatabase {
    # Create Database
    Write-Verbose "Creating database $database on server $Server."
    try {
        $query = "IF NOT EXISTS (SELECT [name] FROM sys.databases WHERE [name] = '$database')
        CREATE DATABASE $database"
        Invoke-Sqlcmd2 -ServerInstance $server -Query $query
        Write-Output 'Database created successfully.'
    } catch {
        $error = $_.Exception.Message
        $text = "Database: $database. $error"
        Write-Error $text
    }
}

Function New-CHTables {
    param([Parameter(Mandatory=$false)]$upgrade=$false)
    try {
        #ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
        $query = "IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'Configuration')
        CREATE TABLE dbo.Configuration
        (
            Name varchar(50) NOT NULL UNIQUE,
            Version varchar (10) NOT NULL
        )"
        Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        
        switch($upgrade) {
            $true {$text = 'Table dbo.Configuration upgraded successfully.'}
            $false {$text = 'Table dbo.Configuration created successfully.'}
        }

        Write-Output  $text
    }
    catch {
        $table = 'dbo.Configuration'
        $error = $_.Exception.Message
        $text = "Table: $table. $error"
        Write-Error $text
    }

    try {
        $version = $CurrentVersion
        $table = 'dbo.Configuration'
        $query= "begin tran
        if exists (SELECT * FROM $table WITH (updlock,serializable) WHERE Name='ClientHealth')
        begin
            UPDATE $table SET Version='"+$Version+"' WHERE Name = 'ClientHealth'
        end
        else
        begin
            INSERT INTO $table (Name, Version)
            VALUES ('ClientHealth', '"+$Version+"')
        end
        commit tran"

        Invoke-SqlCmd2 -ServerInstance $server -Database $Database -Query $query
    }
    catch {
        $table = 'dbo.Client'
        $error = $_.Exception.Message
        $text = "Table: $table. $error"
        Write-Error $text
    }

    try {
        #ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
        $query = "IF NOT EXISTS (SELECT [name] FROM sys.tables WHERE [name] = 'Clients')
        CREATE TABLE dbo.Clients
        (
            Hostname varchar(50) NOT NULL PRIMARY KEY,
            OperatingSystem varchar (100) NOT NULL,
            Architecture varchar(10) NOT NULL,
            Build varchar(50) NOT NULL,
            Manufacturer varchar(50),
            Model varchar(50),
            InstallDate smalldatetime,
            OSUpdates smalldatetime,
            LastLoggedOnUser varchar(50),
            ClientVersion varchar(20),
            PSVersion float,
            PSBuild int,
            Sitecode varchar(3),
            Domain varchar(50),
            MaxLogSize int,
            MaxLogHistory int,
            CacheSize int,
            ClientCertificate varchar(50),
            ProvisioningMode varchar(50),
            DNS varchar(100),
            Drivers varchar(100),
            Updates varchar(100),
            PendingReboot varchar(50),
            LastBootTime smalldatetime,
            OSDiskFreeSpace float,
            Services varchar(50),
            AdminShare varchar(50),
            StateMessages varchar(50),
            WUAHandler varchar(50),
            WMI varchar(50),
            ClientInstalled smalldatetime,
            Version varchar(10),
            Timestamp datetime,
            HWInventory smalldatetime
        )"
        Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        if ($upgrade -eq $false) {Write-Output 'Table dbo.Clients created successfully.'}
    }
    catch {
        $table = 'dbo.Clients'
        $error = $_.Exception.Message
        $text = "Table: $table. $error"
        Write-Error $text
    }

}

function Update-CHTables {
    
    $table = 'dbo.Configuration'
    $i = 0
    # Check if verison is 0.6.0 and handle that first.
    $version = Get-DBVersion
    if ($version -eq '0.6.0') {
        $query = "DROP TABLE dbo.Configuration"
        Invoke-Sqlcmd2 -ServerInstance $SQLServer -Database $database -Query $query
        New-CHTables -upgrade $true
    }
    
    try {
        #ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
        $query = "begin tran
        begin
            ALTER TABLE dbo.clients ADD HWInventory smalldatetime
        end
        commit tran"
        Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        Write-Output 'Table dbo.Clients updated successfully.'
        $i++
    }
    catch {
        $table = 'dbo.Clients'
        $error = $_.Exception.Message
        $text = "Table: $table. $error"
        Write-Error $text
    }

    try {
        #ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
        $query = "UPDATE dbo.Configuration SET Version = '"+$CurrentVersion+"'"
        Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        Write-Output 'Table dbo.Configuration updated successfully.'
        $i++
        
    }
    catch {
        
        $error = $_.Exception.Message
        $text = "Table: $table. $error"
        Write-Error $text
    }
    if ($i -eq 2) {
        Write-Output "Database upgrade successful"
    }
}

function Set-DBPermissions {
    # Permissions on database
    try {
        try {
            Write-Verbose "Granting permissions to $domain\Domain Computers to $database. Required when running script as administrator."
            $query = "USE master
            CREATE LOGIN `"$domain\Domain Computers`" FROM WINDOWS"
            Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        }
        Catch {
            $error = $_.Exception.Message
            Write-Error $error
        }
        try {
            $query = "USE $database
            CREATE USER `"$domain\Domain Computers`" FROM LOGIN `"$domain\Domain Computers`""
            Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        }
        Catch {
            $error = $_.Exception.Message
            Write-Error $error
        }
        try {
            $query = "ALTER ROLE db_datareader ADD MEMBER `"$domain\Domain Computers`""
            Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        }
        Catch {
            $error = $_.Exception.Message
            Write-Error $error
        }
        try {
            $query = "ALTER ROLE db_datawriter ADD MEMBER `"$domain\Domain Computers`""
            Invoke-Sqlcmd2 -ServerInstance $server -Database $database -Query $query
        }
        catch {Write-Error "Error creating login $domain\Domain Computers and setting permissiong on database $database "}
        Write-Output "SQL rights given to database ClientHealth for AD group: $domain\Domain Computers"
    }
    catch {
        Write-Error "Error created $domain\Domain Computers SQL login and grating rights to database dbo.Clients"
    }
}

$text = "ConfigMgr Client Health Database version: "+$CurrentVersion
Write-Output $text

# Check to make sure we don't do anything on a database that is at current version.
$dbVersion = Get-DBVersion
$OVersion = $dbVersion -replace ('\.', '')
$NVersion = $CurrentVersion -replace ('\.', '')

if (($dbVersion -ne 0) -and ($OVersion -lt $NVersion)) {
    # Upgrade existing database (function handles both new and upgrades)
    Update-CHTables
}
elseif ($OVersion -eq 0) {
    # Create new database from scratch
    New-ClientHealthDatabase
    New-CHTables
    Set-DBPermissions
}
else {
    $text = "Database is already at version: $CurrentVersion. No need to upgrade."
    Write-Output $text
}