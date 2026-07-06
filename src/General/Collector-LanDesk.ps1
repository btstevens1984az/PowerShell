<# 
    .SYNOPSIS 
        Produce a XML collection file from "LanDesk" SQL Server source. (v5.0.101 - Oct 25, 2017) 
  
    .DESCRIPTION 
        Creates artifact collection file for uploading through the Microsoft WorkSpace service for SAM and APEX 
        engagements that require XML documents in a specific format. 
  
        The script is to be executed on a machine with access to the SQL database. 
  
        Note: To enable PowerShell script execution, it may be necessary to change the script execution policy. 
              To change the execution policy, from the PowerShell command prompt type the following command and press Enter 
              eg. PS C:>Set-ExecutionPolicy Unrestricted -Scope CurrentUser 
  
    .PARAMETER XmlFilePath 
        Fully Qualified Path to storage location of XML file to be created.  The application will automatically generate the file name. 
  
    .PARAMETER ServerName 
        Name of the server containing the database to access. 
  
    .PARAMETER DatabaseName 
        Name of the database containing information to collect. 
  
    .PARAMETER IntegratedSecurity 
        If specified, the connection to the database is made using Windows Integrated Authentication. 
        If this value is not specified the user may include a PSCredential object containing a valid SQL Server login using the Credential parameter. 
        If neither of these parameters are specified the user will be prompt to supply a valid SQL login at time execution. 
  
    .PARAMETER Credential 
        This parameter accepts a PSCredential object that should contain a valid SQL Server login. 
  
    .PARAMETER ProgressDisplay 
        If specified, the command window includes a progress activity indicator. 
  
    .PARAMETER SuppressLogFile 
        Log files are created by default, if this switch is included the creation of a Log file will be suppressed. 
  
    .PARAMETER LogFilePath 
        Fully Qualified Path to storage location of Log file to be created. If no path is specified the file will be created in the same folder as the XML file. The application will automatically generate the file name. 
  
    .PARAMETER FilterVersion 
        If included, the script will use a specified custom filter.  If not specified, the script will default to a Primary filter value. 
  
    .PARAMETER xDTCall 
        This value is reserved for internal processing and should be ignored when running this script in a PowerShell command window. 
  
    .PARAMETER DataSource 
        This value is reserved for internal processing and should be ignored when running this script in a PowerShell command window. 
  
    .PARAMETER AppVersion 
        This value is reserved for internal processing and should be ignored when running this script in a PowerShell command window. 
  
    .EXAMPLE 
        C:\TEMP\Collector-LanDesk.ps1 "C:\TEMP\" "SERVER01" "Database1" 
  
    .EXAMPLE 
        C:\TEMP\Collector-LanDesk.ps1 -XmlFilePath "C:\TEMP\" -ServerName "SERVER01" -DatabaseName "Database1" -IntegratedSecurity -ProgressDisplay -SuppressLogFile 
  
    .LINK 
        Website: InvisoCorp.com/SAM 
        Support Email: InvisoSA@InvisoCorp.com 
  
        DISCLAIMER: The sample scripts are not supported under any Microsoft standard support program or 
        service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further 
        disclaims all implied warranties including, without limitation, any implied warranties of merchantability 
        or of fitness for a particular purpose. The entire risk arising out of the use or performance of 
        the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
        or anyone else involved in the creation, production, or delivery of the scripts be liable for any 
        damages whatsoever (including, without limitation, damages for loss of business profits, business 
        interruption, loss of business information, or other pecuniary loss) arising out of the use of or 
        inability to use the sample scripts or documentation, even if Microsoft has been advised of the 
        possibility of such damages. 
  
#> 
[CmdletBinding(SupportsShouldProcess=$true)] 
Param ( 
    [Parameter(Mandatory=$true,Position=0)] 
        [string] $XmlFilePath, 
    [Parameter(Mandatory=$true,Position=1)] 
        [string] $ServerName, 
    [Parameter(Mandatory=$true,Position=2)] 
        [string] $DatabaseName, 
    [Parameter(Position=3)] 
        [switch] $IntegratedSecurity, 
    [Parameter(Position=4)] 
        [System.Management.Automation.PSCredential] $Credential, 
    [Parameter(Position=5)] 
        [switch] $ProgressDisplay, 
    [Parameter(Position=6)] 
        [switch] $SuppressLogFile, 
    [Parameter(Position=7)] 
        [string] $LogFilePath, 
    [Parameter(Position=8)] 
        [string] $FilterVersion = 'Primary', 
    [Parameter(Position=9)] 
        [switch] $xDTCall, 
    [Parameter(Position=10)] 
        [string] $DataSource, 
    [Parameter(Position=11)] 
        [string] $AppVersion 
) 
  
#region VARIABLES 
  
#region CONSTANTS 
#Make modifications to script specific values here 
Set-Variable -Name XmlFileExtension -Option Constant -Value 'xml'; 
Set-Variable -Name LogFileExtension -Option Constant -Value 'log'; 
Set-Variable -Name DiscoveryDate -Option Constant -Value (Get-Date -format s); 
Set-Variable -Name FileDate -Option Constant -Value (Get-Date -format 'M-d-yyyy H.m.s'); 
Set-Variable -Name Tab -Option Constant -Value ([char]9); 
Set-Variable -Name PSVersion -Option Constant -Value $PsVersionTable.PSVersion; 
Set-Variable -Name dotNetVersion -Option Constant -Value $PsVersionTable.CLRVersion; 
#endregion CONSTANTS 
  
#region WORKING VARIABLES 
#Set processing variable values 
$TableReadCount = 0; 
$TotalRowCount = 0; 
$StartDate = Get-Date; 
$ExecutionSuccess = $false; 
  
#Inialize Versioning object to be loaded from the initial SQLQuery call 
$Versioning = '' | Select-Object 'DataSource', 'AppVersion', 'ScriptVersion', 'DataOriginSource', 'PrimarySourceTool', 'PrimarySourceToolVersion', 'PSVersion', 'dotNetVersion', 'DiscoveryDate', 'AnonymizationIdentifier', 'AnonymizationCheckValue'; 
$Versioning.DataSource = $DataSource; 
$Versioning.AppVersion = $AppVersion; 
$Versioning.PSVersion = $PSVersion; 
$Versioning.dotNetVersion = $dotNetVersion; 
$Versioning.DiscoveryDate = $DiscoveryDate; 
  
#Initialize Output objects 
$XmlHeader = '<?xml version="1.0" standalone="yes"?>'; 
$XmlRootOpen = '<Root>'; 
$XmlRootClose = '</Root>'; 
  
#Initalize log file Hashtable capture variable 
$LogStore = @{}; 
  
# Create a Regex object to remove invalid XML characters from collected data before writing to file 
$InvalidXmlCharactersRegex = New-Object System.Text.RegularExpressions.Regex("[^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-\u10FFFF]"); 
  
#Translate FilterVersion into bit map value 
$FilterSet = Switch ($FilterVersion) 
        { 
            'No Filter' {0} 
            'Primary' {1} 
            'Microsoft Only' {2} 
            'Microsoft' {3} 
            'Publisher List Only' {4} 
            'Publisher List' {5} 
            'Publisher List and Microsoft Only' {6} 
            'Publisher List and Microsoft' {7} 
            default {-1} 
        } 
  
#Prepare output file path values 
#Be sure the XML path variable ends with a backslash 
If ($XmlFilePath.EndsWith('\') -ne $true) 
{ 
    $XmlFilePath += '\'; 
} 
  
#Be sure the Log file path is defined and ends with a backslash or set it value to the XML path 
If(!$LogFilePath) 
{ 
    $LogFilePath = $XmlFilePath; 
} 
If ($LogFilePath.EndsWith('\') -ne $true) 
{ 
    $LogFilePath += '\'; 
} 
#endregion WORKING VARIABLES 
#endregion VARIABLES 
  
#region FUNCTIONS 
Function Add-LogEntry 
{ 
Param 
( 
    $LineValue 
) 
    $LogStoreLineCount = ($LogStore.Count + 1); 
    $LogStore[$LogStoreLineCount] += $LineValue; 
}; 
  
Function SqlCodeBlock 
{ 
@" 
SET NOCOUNT ON; 
  
DECLARE 
    @ColumnList nvarchar(4000) 
    ,@GroupByList nvarchar(4000) 
    ,@GroupBy nvarchar(4000) 
    ,@QualifiedEntity nvarchar(150) 
    ,@SchemaDefault nvarchar(128) 
    ,@EntityRow int 
    ,@EntityRowMax int 
    ,@EntityId int 
    ,@EntitySchema nvarchar(128) 
    ,@EntityName nvarchar(128) 
    ,@EntityXMLName nvarchar(128) 
    ,@EntityType nvarchar(2) 
    ,@SqlCommand nvarchar(4000) 
    ,@SchemaId int 
    ,@SchemaName nvarchar(128) 
    ,@Filter nvarchar(4000) 
    ,@FilterRow int 
    ,@FilterRowMax int 
    ,@FilterVersion int 
    ,@GroupConnect nvarchar(100) 
    ,@ItemConnect nvarchar(100) 
    ,@FilterGroup nvarchar(100) 
    ,@SQLFilter nvarchar(4000) 
    ,@SetSelectable bit 
    ,@DataOriginName nvarchar(128) 
    ,@DataOriginScriptVersion nvarchar(20) 
    ,@PrimarySourceTool nvarchar(255) 
    ,@PrimarySourceToolVersion nvarchar(255) 
    ,@FileNamePrefix nvarchar(255); 
  
SET @EntityRowMax = 8; 
SET @FilterRowMax = 14; 
SET @FilterVersion = 1; 
SET @DataOriginName = N'LanDesk'; 
SET @DataOriginScriptVersion = N'5'; 
SET @PrimarySourceTool = N'LanDesk'; 
SET @PrimarySourceToolVersion = N'5.0.101'; 
SET @FileNamePrefix = N'landesk'; 
  
IF OBJECT_ID('tempdb..#ResultSet') IS NOT NULL 
BEGIN 
    DROP TABLE #ResultSet; 
END 
  
IF OBJECT_ID('tempdb..#EntitySelect') IS NOT NULL 
BEGIN 
    DROP TABLE #EntitySelect; 
END 
  
IF OBJECT_ID('tempdb..#ColumnSelect') IS NOT NULL 
BEGIN 
    DROP TABLE #ColumnSelect; 
END 
  
IF OBJECT_ID('tempdb..#ColumnFilter') IS NOT NULL 
BEGIN 
    DROP TABLE #ColumnFilter; 
END 
CREATE TABLE #ResultSet 
( 
    [ResultRow] int IDENTITY(1,1) NOT NULL 
    ,[ResultType] nvarchar(50) NOT NULL 
    ,[TableName] nvarchar(128) NULL 
    ,[ResultString] nvarchar(max) NULL 
); 
  
CREATE TABLE #EntitySelect 
( 
    [EntityRow] int NOT NULL 
    ,[EntityId] int NOT NULL 
    ,[EntitySchema] nvarchar(128) NOT NULL 
    ,[EntityName] nvarchar(128) NOT NULL 
    ,[EntityXMLName] nvarchar(128) NOT NULL 
    ,[EntityType] nvarchar(2) NOT NULL 
); 
  
CREATE TABLE #ColumnSelect 
( 
    [SelectRow] int NOT NULL 
    ,[EntityId] int NOT NULL 
    ,[ColumnName] nvarchar(128) NOT NULL 
    ,[ColumnSelect] nvarchar(1000) NOT NULL 
    ,[SkipExistsCheck] bit NOT NULL 
    ,[GroupBy] bit NOT NULL 
); 
  
CREATE TABLE #ColumnFilter 
( 
    [SelectRow] int NOT NULL 
    ,[EntityId] int NOT NULL 
    ,[ItemConnector] nvarchar(10) NOT NULL 
    ,[FilterVersion] int NOT NULL  
    ,[FilterGroup] int NOT NULL 
    ,[FilterGroupConnect] nvarchar(10) NOT NULL 
    ,[ColumnName] nvarchar(128) NOT NULL 
    ,[ColumnFilter] nvarchar(500) NOT NULL 
); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'DataOriginName' 
        ,@DataOriginName 
    ); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'DataOriginScriptVersion' 
        ,@DataOriginScriptVersion 
    ); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'PrimarySourceTool' 
        ,@PrimarySourceTool 
    ); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'PrimarySourceToolVersion' 
        ,@PrimarySourceToolVersion 
    ); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'FileNamePrefix' 
        ,@FileNamePrefix 
    ); 
  
INSERT INTO 
    #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
    ) 
    VALUES 
    ( 
        N'EntityCount' 
        ,@EntityRowMax 
    ); 
  
INSERT INTO 
     #EntitySelect 
( 
    [EntityRow] 
    ,[EntityId] 
    ,[EntitySchema] 
    ,[EntityName] 
    ,[EntityXMLName] 
    ,[EntityType] 
) 
SELECT 1, 167, N'dbo', N'Bios', N'Bios', N'U' 
UNION SELECT 2, 168, N'dbo', N'CompSystem', N'CompSystem', N'U' 
UNION SELECT 3, 169, N'dbo', N'Computer', N'Computer', N'U' 
UNION SELECT 4, 170, N'dbo', N'NetworkAdapter', N'NetworkAdapter', N'U' 
UNION SELECT 5, 171, N'dbo', N'Operating_System', N'Operating_System', N'U' 
UNION SELECT 6, 172, N'dbo', N'Processor', N'Processor', N'U' 
UNION SELECT 7, 173, N'dbo', N'Product', N'Product', N'U' 
UNION SELECT 8, 174, N'dbo', N'ProductComputer', N'ProductComputer', N'U'; 
  
INSERT INTO 
     #ColumnSelect 
( 
    [SelectRow] 
    ,[EntityId] 
    ,[ColumnName] 
    ,[ColumnSelect] 
    ,[SkipExistsCheck] 
    ,[GroupBy] 
) 
SELECT 1, 167, N'BiosDate', N'[BiosDate] AS [BiosDate]', 0, 0 
UNION SELECT 2, 167, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 3, 167, N'SerialNum', N'[SerialNum] AS [SerialNum]', 0, 0 
UNION SELECT 4, 168, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 5, 168, N'Manufacturer', N'[Manufacturer] AS [Manufacturer]', 0, 0 
UNION SELECT 6, 168, N'Model', N'[Model] AS [Model]', 0, 0 
UNION SELECT 7, 169, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 8, 169, N'DeviceName', N'[DeviceName] AS [DeviceName]', 0, 0 
UNION SELECT 9, 169, N'DomainName', N'[DomainName] AS [DomainName]', 0, 0 
UNION SELECT 10, 169, N'HWLastScanDate', N'CONVERT(nvarchar(23), [HWLastScanDate], 126) AS [HWLastScanDate]', 0, 0 
UNION SELECT 11, 169, N'QualifiedUser', N'[QualifiedUser] AS [QualifiedUser]', 0, 0 
UNION SELECT 12, 169, N'SWLastScanDate', N'CONVERT(nvarchar(23), [SWLastScanDate], 126) AS [SWLastScanDate]', 0, 0 
UNION SELECT 13, 170, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 14, 170, N'PhysicalAddress', N'[PhysicalAddress] AS [PhysicalAddress]', 0, 0 
UNION SELECT 15, 171, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 16, 171, N'OSType', N'[OSType] AS [OSType]', 0, 0 
UNION SELECT 17, 171, N'Version', N'[Version] AS [Version]', 0, 0 
UNION SELECT 18, 172, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 19, 172, N'CoresPerPkg', N'[CoresPerPkg] AS [CoresPerPkg]', 0, 0 
UNION SELECT 20, 172, N'ProcCount', N'[ProcCount] AS [ProcCount]', 0, 0 
UNION SELECT 21, 172, N'Type', N'[Type] AS [Type]', 0, 0 
UNION SELECT 22, 173, N'Product_Idn', N'[Product_Idn] AS [Product_Idn]', 0, 0 
UNION SELECT 23, 173, N'Publisher', N'[Publisher] AS [Publisher]', 0, 0 
UNION SELECT 24, 173, N'Title', N'[Title] AS [Title]', 0, 0 
UNION SELECT 25, 173, N'Version', N'[Version] AS [Version]', 0, 0 
UNION SELECT 26, 174, N'Computer_Idn', N'[Computer_Idn] AS [Computer_Idn]', 0, 0 
UNION SELECT 27, 174, N'Product_Idn', N'[Product_Idn] AS [Product_Idn]', 0, 0; 
  
INSERT INTO 
     #ColumnFilter 
( 
    [SelectRow] 
    ,[EntityId] 
    ,[ColumnName] 
    ,[ColumnFilter] 
    ,[ItemConnector] 
    ,[FilterVersion] 
    ,[FilterGroup] 
    ,[FilterGroupConnect] 
) 
SELECT 1, 173, N'Title', N'Title NOT LIKE ''%KB%''', N'AND', 1, 1, N'AND' 
UNION SELECT 2, 173, N'Title', N'Title NOT LIKE ''%.NET Framework%''', N'AND', 1, 1, N'AND' 
UNION SELECT 3, 173, N'Title', N'Title NOT LIKE ''%Update%''', N'AND', 1, 1, N'AND' 
UNION SELECT 4, 173, N'Title', N'Title NOT LIKE ''%Service Pack%''', N'AND', 1, 1, N'AND' 
UNION SELECT 5, 173, N'Title', N'Title NOT LIKE ''%Proof%''', N'AND', 1, 1, N'AND' 
UNION SELECT 6, 173, N'Title', N'Title NOT LIKE ''%Components%''', N'AND', 1, 1, N'AND' 
UNION SELECT 7, 173, N'Title', N'Title NOT LIKE ''%Tools%''', N'AND', 1, 1, N'AND' 
UNION SELECT 8, 173, N'Title', N'Title NOT LIKE ''%MUI%''', N'AND', 1, 1, N'AND' 
UNION SELECT 9, 173, N'Title', N'Title NOT LIKE ''%Redistributable%''', N'AND', 1, 1, N'AND' 
UNION SELECT 10, 173, N'Publisher', N'Publisher LIKE ''%vmware%''', N'OR', 4, 2, N'AND' 
UNION SELECT 11, 173, N'Publisher', N'Publisher LIKE ''%citrix%''', N'OR', 4, 2, N'AND' 
UNION SELECT 12, 173, N'Publisher', N'Publisher LIKE ''%oracle%''', N'OR', 4, 2, N'AND' 
UNION SELECT 13, 173, N'Publisher', N'Publisher LIKE ''%red%hat%''', N'OR', 4, 2, N'AND' 
UNION SELECT 14, 173, N'Publisher', N'Publisher LIKE ''%microsoft%''', N'OR', 2, 2, N'AND'; 
  
-- Loop through each Entity and build SELECT scripts. 
SET @EntityRow = 0; 
WHILE @EntityRow < @EntityRowMax 
BEGIN 
    SELECT 
        @EntityId = [EntityId] 
        ,@EntitySchema = [EntitySchema] 
        ,@EntityName = [EntityName] 
        ,@EntityXMLName = [EntityXMLName] 
        ,@EntityType = [EntityType] 
        ,@EntityRow = [EntityRow] 
    FROM 
        #EntitySelect 
    WHERE 
        [EntityRow] = @EntityRow + 1; 
  
-- Validate Table Schema 
    SET @SchemaDefault = @EntitySchema; 
    SET @SchemaId = 
    CASE 
        WHEN (SELECT [Schema_Id] FROM [sys].[objects] WHERE [Name] = @EntityName AND SCHEMA_NAME([Schema_Id]) = @SchemaDefault) IS NOT NULL 
        THEN SCHEMA_ID(@SchemaDefault) 
        ELSE (SELECT TOP 1 [Schema_Id] FROM [sys].[objects] WHERE [Name] = @EntityName) 
    END; 
    SET @SchemaName = COALESCE(SCHEMA_NAME(@SchemaId), @SchemaDefault); 
  
    SET @ColumnList = NULL; 
    SET @GroupByList = NULL; 
    SET @Filter = NULL; 
    SET @QualifiedEntity = COALESCE((N'[' + @SchemaName + N'].'),N'') + N'[' + @EntityName + N']'; 
    SET @EntityType = RTRIM(@EntityType); 
    SET @SQLFilter = N''; -- Include any filter conditions 
    SET @SetSelectable = 'FALSE'; 
  
    INSERT INTO 
        #ResultSet 
    ( 
        [ResultType] 
        ,[ResultString] 
        ) 
    VALUES 
    ( 
        N'Log' 
        ,N'Validating and generating SQL collection script for ' + @QualifiedEntity + N'.' 
    ); 
  
    IF (@SchemaName <> @EntitySchema) 
        INSERT INTO 
            #ResultSet 
        ( 
            [ResultType] 
            ,[ResultString] 
        ) 
        VALUES 
        ( 
            N'Log' 
            ,CHAR(9) + N'Default Schema value not found changed from ' + @EntitySchema + N' To ' + @SchemaName + N'.' 
        ); 
  
-- Verify specified Entity EXISTS and contains SELECTable columns 
    IF EXISTS (SELECT * FROM [sys].[objects] WHERE [schema_id] = @SchemaId AND [name] = @EntityName AND [type] = @EntityType) 
    BEGIN 
  
-- Check for and log missing columns 
        SELECT 
            @ColumnList = STUFF( 
                (SELECT 
                    N', ' + [L].[ColumnName]  
                FROM 
                    #ColumnSelect AS [L] 
                INNER JOIN 
                    #EntitySelect AS [E] 
                ON 
                    [E].[EntityId] = [L].[EntityId] 
                LEFT OUTER JOIN 
                    [sys].[columns] AS [C] 
                ON 
                    [L].[ColumnName] COLLATE database_default = [C].[name] 
                LEFT OUTER JOIN 
                    [sys].[objects] AS [T] 
                ON 
                    [C].[object_id] = [T].[object_id] 
                AND 
                    [T].[Name] = [E].[EntityName] COLLATE database_default 
                AND 
                    [T].[schema_id] = @SchemaId 
                WHERE 
                    [E].[EntityName] COLLATE database_default = @EntityName 
                AND 
                    [L].[SkipExistsCheck] = 'FALSE' 
                AND 
                    [C].[name] IS NULL 
                FOR XML PATH (N'')) 
            , 1, 2, N''); 
  
        IF (@ColumnList IS NOT NULL) 
            INSERT INTO 
                #ResultSet 
            ( 
                [ResultType] 
                ,[ResultString] 
            ) 
            VALUES 
            ( 
                N'Log' 
                ,CHAR(9) + N'List of missing columns - (' + @ColumnList + N').' 
            ); 
  
-- Generate variable containing list of desired Attributes validated against sys.objects on the DB to avoid selecting missing columns. 
        SELECT 
            @ColumnList = STUFF( 
                (SELECT 
                    N', ' + [L].[ColumnSelect]  
                FROM 
                    #ColumnSelect AS [L] 
                INNER JOIN 
                    #EntitySelect AS [E] 
                ON 
                    [E].[EntityId] = [L].[EntityId] 
                INNER JOIN 
                    [sys].[columns] AS [C] 
                ON 
                    [L].[ColumnName] COLLATE database_default = [C].[name] 
                INNER JOIN 
                    [sys].[objects] AS [T] 
                ON 
                    [C].[object_id] = [T].[object_id] 
                AND 
                    [T].[Name] = [E].[EntityName] COLLATE database_default 
                AND 
                    [T].[schema_id] = @SchemaId 
                WHERE 
                    [E].[EntityName] COLLATE database_default = @EntityName 
                AND 
                    [L].[SkipExistsCheck] = 'FALSE' 
                ORDER BY 
                    [C].[column_id] 
                FOR XML PATH (N'')) 
            , 1, 2, N''); 
  
        SELECT 
            @ColumnList = @ColumnList +  
                COALESCE((SELECT 
                    N', ' + [L].[ColumnSelect]  
                FROM 
                    #ColumnSelect AS [L] 
                INNER JOIN 
                    #EntitySelect AS [E] 
                ON 
                    [E].[EntityId] = [L].[EntityId] 
                WHERE 
                    [E].[EntityName] COLLATE database_default = @EntityName 
                AND 
                    [L].[SkipExistsCheck] = 'TRUE' 
                FOR XML PATH (N'')), N''); 
  
-- If at least one Attribute value is available to select set the SetSelectable variable TRUE 
        IF @ColumnList IS NOT NULL 
        BEGIN 
            SET @SetSelectable = 'TRUE'; 
            SELECT 
                @GroupByList = STUFF( 
                    (SELECT 
                        N', ' + [L].[ColumnName]  
                    FROM 
                        #ColumnSelect AS [L] 
                    INNER JOIN 
                        #EntitySelect AS [E] 
                    ON 
                        [E].[EntityId] = [L].[EntityId] 
                    WHERE 
                        [E].[EntityName] COLLATE database_default = @EntityName 
                    AND 
                        [L].[GroupBy] = 1 
                    FOR XML PATH (N'')) 
                , 1, 2, N''); 
  
-- If at least one Attribute value is available to group by clean up the list and set the Set Group By 
            IF @GroupByList IS NOT NULL 
                SET @GroupBy = N' GROUP BY ' + @GroupByList; 
            ELSE 
-- If no Attribute value is available, set a default to append no Filter condition 
                SET @GroupBy = N''; 
  
  
-- Check for and log missing columns in the Filter clause 
                SELECT @Filter = STUFF( 
                    (SELECT 
                        N', ' + [F].[ColumnName]  
                    FROM 
                        #ColumnFilter AS [F] 
                    INNER JOIN 
                        #EntitySelect AS [E] 
                    ON 
                        [E].[EntityId] = [F].[EntityId] 
                    LEFT OUTER JOIN 
                        [sys].[columns] AS [C] 
                    ON 
                        [F].[ColumnName] COLLATE database_default = [C].[name] 
                    LEFT OUTER JOIN 
                        [sys].[objects] AS [T] 
                    ON 
                        [C].[object_id] = [T].[object_id] 
                    AND 
                        [E].[EntityName] COLLATE database_default = [T].[Name] 
                    AND 
                        [T].[schema_id] = @SchemaId 
                    WHERE 
                        [E].[EntityName] COLLATE database_default = @EntityName 
                    AND 
                        (@FilterVersion & [F].[FilterVersion]) = [F].[FilterVersion] 
                    AND 
                        [C].[name] IS NULL 
                    FOR XML PATH (N'')) 
                , 1, 2, N''); 
  
                IF (@Filter IS NOT NULL) 
                    INSERT INTO 
                        #ResultSet 
                    ( 
                        [ResultType] 
                        ,[ResultString] 
                    ) 
                    VALUES 
                    ( 
                        N'Log' 
                        ,CHAR(9) + N'List of missing Filter columns - (' + @Filter + N').' 
                    ); 
  
                SET @Filter = N''; 
                SET @GroupConnect = N''; 
                SET @ItemConnect = N''; 
                SET @FilterGroup = 0; 
  
                SELECT @Filter = @Filter + ( 
                    CASE 
                        WHEN @Filter = N'' 
                        THEN N' (' + REPLACE(COALESCE([F].[ColumnFilter], N''), N'<schemaname>', @SchemaName) 
                        WHEN  @FilterGroup = [FilterGroup] 
                        THEN N' ' + @ItemConnect + N' ' + REPLACE(COALESCE([F].[ColumnFilter], N''), N'<schemaname>', @SchemaName) 
                    WHEN  @FilterGroup < [FilterGroup] 
                    THEN  N') ' + @GroupConnect + N' (' + REPLACE(COALESCE([F].[ColumnFilter], N''), N'<schemaname>', @SchemaName) 
                END) 
                    ,@ItemConnect = [ItemConnector] 
                    ,@GroupConnect = [FilterGroupConnect] 
                    ,@FilterGroup = [FilterGroup] 
                FROM 
                    #ColumnFilter AS [F] 
                INNER JOIN 
                    #EntitySelect AS [E] 
                ON 
                    [E].[EntityId] = [F].[EntityId] 
                INNER JOIN 
                    [sys].[columns] AS [C] 
                ON 
                    [F].[ColumnName] COLLATE database_default = [C].[name] 
                INNER JOIN 
                    [sys].[objects] AS [T] 
                ON 
                    [C].[object_id] = [T].[object_id] 
                AND 
                    [E].[EntityName] COLLATE database_default = [T].[Name] 
                AND 
                    [T].[schema_id] = @SchemaId 
                WHERE 
                    [E].[EntityName] COLLATE database_default = @EntityName 
                AND 
                    (@FilterVersion & [F].[FilterVersion]) = [F].[FilterVersion] 
                ORDER BY 
                    [FilterGroup] 
            IF @Filter > N'' 
                SET @SQLFilter = N' WHERE' + SUBSTRING(@Filter, 1, LEN (@Filter) - CASE WHEN RIGHT(@Filter, 5) = N') AND' THEN 4 WHEN RIGHT(@Filter, 4) = N') OR' THEN 3 ELSE 0 END) + N')'; 
            ELSE 
                SET @SQLFilter = N''; 
            END 
            ELSE 
            BEGIN 
                INSERT INTO 
                    #ResultSet 
                ( 
                    [ResultType] 
                    ,[ResultString] 
                ) 
                VALUES 
                ( 
                    N'Log' 
                    ,CHAR(9) + N'No Selectable columns found in table.' 
                ); 
            END 
    END 
    ELSE 
    BEGIN 
        INSERT INTO 
            #ResultSet 
        ( 
            [ResultType] 
            ,[ResultString] 
        ) 
        VALUES 
        ( 
            N'Log' 
            ,CHAR(9) + N'Table does not exist.' 
        ) 
    END 
  
--If the Entity EXISTS and has selectable rows generate the script to collect data. 
    IF @SetSelectable = 'TRUE' 
    BEGIN 
        SET @SqlCommand = N'SELECT ' + @ColumnList + N' FROM ' + @QualifiedEntity + N' WITH (NOLOCK)' + @SQLFilter + @GroupBy; 
  
        INSERT INTO 
            #ResultSet 
        ( 
            [ResultType] 
            ,[ResultString] 
        ) 
        VALUES 
        ( 
            N'Log' 
            ,CHAR(9) + N'SQL script generated.' 
        ) 
  
        INSERT INTO 
            #ResultSet 
        ( 
            [ResultType] 
            ,[TableName] 
            ,[ResultString] 
        ) 
        VALUES 
        ( 
            N'Script' 
            ,@EntityXMLName 
            ,@SqlCommand 
        ); 
    END 
    ELSE 
    BEGIN 
        INSERT INTO 
            #ResultSet 
        ( 
            [ResultType] 
            ,[ResultString] 
        ) 
        VALUES 
        ( 
            N'Log' 
            ,CHAR(9) + N'Table has no Selectability. See prior Warning for more information. No Script created.' 
        ); 
    END 
END 
  
--Return results of code generation. 
SELECT 
    [ResultRow] 
    ,[ResultType] 
    ,[TableName] 
    ,[ResultString] 
FROM 
    #ResultSet; 
"@ 
} 
#endregion FUNCTIONS 
  
#region PROGRAM MAIN 
Try 
{ 
#region PREPROCESS VALIDATION 
# Perform initial validation checks before continuing 
    Add-LogEntry -LineValue $('Processing Begin: ' + $(Get-Date -format s).Replace('T',' ')); 
  
#Capture the current parameter settings 
    Add-LogEntry -LineValue $($Tab+'List of parameter values used for this script execution'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'XmlFilePath = (' + $XmlFilePath + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'ServerName = (' + $ServerName + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'DatabaseName = (' + $DatabaseName + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'IntegratedSecurity = (' + $(If($IntegratedSecurity){'On'}Else{'Off'}) + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'Credential = (' + $(If($Credential){'Value Supplied'}Else{'Value Not Supplied'}) + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'ProgressDisplay = (' + $(If($ProgressDisplay){'On'}Else{'Off'}) + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'SuppressLogFile = (' + $(If($SuppressLogFile){'On'}Else{'Off'}) + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'LogFilePath = (' + $LogFilePath + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'FilterVersion = (' + $FilterVersion + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'xDTCall = (' + $(If($xDTCall){'On'}Else{'Off'}) + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'PSVersion = (' + $PSVersion + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'dotNetVersion = (' + $dotNetVersion + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'DataSource = (' + $DataSource + ')'); 
    Add-LogEntry -LineValue $($Tab+$Tab+'AppVersion = (' + $AppVersion + ')'); 
  
    Try 
    { 
        Add-LogEntry -LineValue $($Tab+'Validating parameters'); 
# Validate that XML file path value is accessible 
        If ($(Test-Path $XmlFilePath) -eq $false) 
        { 
            $ErrorMessage = 'Could not access specified Xml File Path'; 
        } 
# Validate that Log file path value is accessible if output not suppressed 
        ElseIf (!$SuppressLogFile -and ($(Test-Path $LogFilePath) -eq $false)) 
        { 
            $ErrorMessage = 'Could not access specified Log File Path'; 
        } 
# Validate that FilterSet value is not 0 
        ElseIf ($FilterSet -eq -1) 
        { 
            $ErrorMessage = 'Invalid FilterVersion specified'; 
        } 
# Get Credentials if IntegratedSecurity was not select and script was not called by xDT 
        ElseIf (!$IntegratedSecurity -and !$Credential) 
        { 
# If call was initiated by xDT throw an error as it is responsible for collecting 
# credentials of setting IntegratedSecurity flag 
            If ($xDTCall) 
            { 
                $ErrorMessage = 'Valid SQL Server credentials required or IntegratedSecurity must be specified'; 
            } 
            Else 
            { 
# Otherwise get them from the user 
                Add-LogEntry -LineValue $($Tab+'Getting user SQL Server Login information'); 
                Try 
                { 
                    If ($psversiontable.psversion.major -lt 3) 
                    { 
                        $Credential = Get-Credential; 
                    } 
                    Else 
                    { 
                        $Credential = Get-Credential -Message 'SQL Server database credentials'; 
                    } 
                } 
                Catch 
                { 
                    $ErrorMessage = 'Valid SQL Server credentials required or IntegratedSecurity must be specified'; 
                } 
            } 
        } 
    } 
    Catch 
    { 
        $ErrorMessage = $_.Exception.Message; 
    } 
  
    If (!$ErrorMessage -and !$IntegratedSecurity) 
    { 
        Add-LogEntry -LineValue $($Tab+'Validating SQL Server Login UserName entered'); 
        If (!$Credential.UserName) 
        { 
            $ErrorMessage = 'Valid credentials required'; 
        } 
        Else 
        { 
            $UserName = $Credential.UserName.TrimStart("\"); 
            $Password = $Credential.GetNetworkCredential().Password; 
        } 
    } 
#endregion PREPROCESS VALIDATION 
  
#region GENERATE SCRIPTS 
# Build a database connection string 
    If (!$ErrorMessage) 
    { 
        Try 
        { 
            If ($IntegratedSecurity) 
            { 
                $ConnectionString = "Database=$DatabaseName; Server=$ServerName; Integrated Security=True; Persist Security Info=False"; 
            } 
            Else 
            { 
                $ConnectionString =  "Database=$DatabaseName; Server=$ServerName; UID=$UserName; PWD=$Password; Persist Security Info=False;Integrated Security=False;"; 
            } 
  
# Construct and open the Database Connection 
            Add-LogEntry -LineValue $($Tab+'Opening connection to Database'); 
            $Connection = New-Object System.Data.SqlClient.SqlConnection; 
            $Connection.ConnectionString = $ConnectionString; 
            $Connection.Open(); 
  
# Execute the ScriptBlock to generate the SQL collection scripts 
# The return set will also include Source specific processing information and log activity data. 
            Add-LogEntry -LineValue $($Tab+'Generating SQL Scripts' + $(': ' + $(Get-Date -format s).Replace('T', ' '))); 
            $FilterSetString = '@FilterVersion = ' + $FilterSet; 
            $SqlQuery = ([string](Get-Item Function:SqlCodeBlock).ScriptBlock).Replace('@"', '').Replace('"@', '').Replace('@FilterVersion = 1', $FilterSetString); 
            $ReaderCommand = New-Object System.Data.SqlClient.SqlCommand($SqlQuery, $Connection); 
            $Reader = $ReaderCommand.ExecuteReader(); 
            If ($Reader.HasRows) 
            { 
                $Results = @(); 
                While ($Reader.Read()) 
                { 
                    $Properties = @{}; 
                    $Reader.GetSchemaTable() | ForEach-Object { $Properties[$_.ColumnName] = $Reader[$_.ColumnName]}; 
                    $Results += New-Object -TypeName psobject -Property $Properties; 
                } 
            } 
            $Reader.Close(); 
  
# Collect processing values retrieved from the ScriptBlock execution 
            ForEach ($LogEntry In $Results) 
            { 
                Switch ($LogEntry.ResultType)  
                { 
                    'DataOriginName' 
                    { 
                        $Versioning.DataOriginSource = $LogEntry.ResultString; 
                        continue; 
                    } 
                    'DataOriginScriptVersion' 
                    { 
                        $Versioning.ScriptVersion = $LogEntry.ResultString; 
                        continue; 
                    } 
                    'PrimarySourceTool' 
                    { 
                        $Versioning.PrimarySourceTool = $LogEntry.ResultString; 
                        continue; 
                    } 
                    'PrimarySourceToolVersion' 
                    { 
                        $Versioning.PrimarySourceToolVersion = $LogEntry.ResultString; 
                        continue; 
                    } 
                    'FileNamePrefix' 
                    { 
                        $FileNamePrefix = $LogEntry.ResultString; 
                        continue; 
                    } 
                    'EntityCount' 
                    { 
                        $MaxTableCount = $LogEntry.ResultString; 
                        continue; 
                    } 
                } 
            } 
#Capture the current processing settings 
            Add-LogEntry -LineValue $($Tab+$Tab+'List of processing values used for this script execution'); 
            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+'DataOriginName = (' + $Versioning.DataOriginSource + ')'); 
            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+'ScriptVersion = (' + $Versioning.ScriptVersion + ')'); 
            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+'PrimarySourceTool = (' + $Versioning.PrimarySourceTool + ')'); 
            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+'PrimarySourceToolVersion = (' + $Versioning.PrimarySourceToolVersion + ')'); 
        } 
        Catch 
        { 
            $ErrorMessage = 'Problem connecting to database'; 
            If ($_.Exception.InnerException.Message) 
            { 
                $ErrorMessage += ' - ' + $_.Exception.InnerException.Message; 
            } 
        } 
    } 
#endregion GENERATE SCRIPTS 
  
    If (!$ErrorMessage) 
    { 
#region COLLECT AND WRITE XMLFILE 
        Try 
        { 
# Add Sql code generation Log values to the Log Capture collection 
            ForEach ($LogEntry In $($Results | Sort-Object ResultRow | Where-Object {$_.ResultType -EQ 'Log'}).ResultString) 
            { 
                Add-LogEntry -LineValue $($Tab+$Tab+$LogEntry); 
            } 
            $SqlResult = ($Results | Sort-Object ResultRow | Where-Object {$_.ResultType -EQ 'Script'}) | Select-Object TableName, @{Name='Query';Expression={$_.ResultString}}; 
  
# If we were able to run the SQLQuery Generate Xml and Log file stream names 
            If ($FileNamePrefix) 
            { 
                $XmlFileName = $XmlFilePath + $FileNamePrefix + '_' + $FileDate + '.' + $XmlFileExtension; 
                $LogFileName = $LogFilePath + $FileNamePrefix + '_' + $FileDate + '.' + $LogFileExtension; 
            } 
            Else 
            { 
                $ErrorMessage = 'Missing processing file prefix name value'; 
            } 
            If (!$ErrorMessage) 
            { 
                Add-LogEntry -LineValue $($Tab+'Running SQL Scripts and writing data' + $(': ' + $(Get-Date -format s).Replace('T', ' '))); 
                $ScriptTableCount = $SqlResult.Count; 
  
                If ($ScriptTableCount -gt 0) 
                { 
# Create XML output file stream Object 
                    Add-LogEntry -LineValue $($Tab+'Creating Xml file'); 
                    Try 
                    { 
                        $XMLFileStream = New-Object System.IO.StreamWriter $XmlFileName; 
                        $XMLFIleStream.AutoFlush = $true; 
                    } 
                    Catch 
                    { 
                        $ErrorMessage = 'Could not create XML File'; 
                        Throw; 
                    } 
  
                    Add-LogEntry -LineValue $($Tab+'Creating Xml file'); 
#Output Header Elements 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Adding Xml Header element'); 
                    $XMLFileStream.WriteLine($XmlHeader); 
  
#Output Opening Root element 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Adding opening Root element'); 
                    $XMLFileStream.WriteLine($XmlRootOpen); 
  
#Output Versioining element 
                    $Table = 'Versioning'; 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Adding Versioning element'); 
                    $WriteList = 'DataSource', 'AppVersion', 'ScriptVersion', 'DataOriginSource', 'PrimarySourceTool', 'PrimarySourceToolVersion', 'PSVersion', 'dotNetVersion', 'DiscoveryDate', 'AnonymizationIdentifier', 'AnonymizationCheckValue'; 
                    $Versioning | Select-Object $WriteList | ForEach-Object {$_.psobject.properties | ForEach-Object {$XMLFileStream.WriteLine($Tab + '<' + $Table + '>')} {$XMLFileStream.WriteLine($($Tab + $Tab + '<' + $_.name + '>' + $_.value + '</' + $_.name + '>'))} {$XMLFileStream.WriteLine($Tab + '</' + $Table + '>')}}; 
  
# Populate Table Elements 
                    ForEach ($Table In $SqlResult) 
                    { 
                        $TableName = $Table.TableName; 
                        $SQLTableQuery = $Table.Query; 
  
                        Add-LogEntry -LineValue $($Tab+$Tab+'Adding ' + $TableName + ' element'); 
                        If ($ProgressDisplay) 
                        { 
                            Write-Progress -Id 0 -Activity 'Collecting Data' -Status $('Processing ' + $TableReadCount + ' of ' + $MaxTableCount) -CurrentOperation $TableName; 
                        } 
                        Try 
                        { 
                            $ReaderCommand = New-Object System.Data.SqlClient.SqlCommand($SQLTableQuery, $Connection); 
                            $Reader = $ReaderCommand.ExecuteReader(); 
                            $TableCollectStart = Get-Date; 
                            $RowCount = 0; 
                            If ($Reader.HasRows) 
                            { 
                                While ($Reader.Read()) 
                                { 
                                    $ColumnLoop = $Reader.FieldCount; 
# Write opening Outer Element row 
                                    $XMLFileStream.WriteLine($Tab+'<'+$TableName+'>'); 
                                    For ($i=0; $i -lt $ColumnLoop; $i++) 
                                    { 
                                        $ReadColumnName = $Reader.GetName($i); 
                                        $ReadColumnValue = ($invalidXmlCharactersRegex.Replace($Reader.GetValue($i), "")).replace('&', '&amp;').replace("'", '&apos;').replace('"', '&quot;').replace('<', '&lt;').replace('>', '&gt;') 
# Write Inner Element rows 
                                        $XMLFileStream.WriteLine($Tab+$Tab+'<'+$ReadColumnName+'>'+$ReadColumnValue+'</'+$ReadColumnName+'>') 
                                    } 
# Write closing Outer Element row 
                                    $XMLFileStream.WriteLine($Tab+'</'+$TableName+'>'); 
                                    $RowCount++; 
                                } 
                            } 
# Capture final element processing metrics and add to LogFile 
                            $TableCollectEnd = Get-Date; 
                            $TimeDiff = $TableCollectEnd - $TableCollectStart; 
                            $TimeMilliSeconds = [int]$TimeDiff.TotalMilliSeconds; 
                            $TableReadCount++; 
                            $TotalRowCount = $TotalRowCount + $RowCount; 
                            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+([string]$RowCount) + ' element entries added in ' + [string]$TimeMilliSeconds + ' milliseconds'); 
                            $Reader.Close(); 
                        } 
                        Catch 
                        { 
                            $ErrorMessage = $_.Exception.Message; 
                            Add-LogEntry -LineValue $($Tab+$Tab+$Tab+$ErrorMessage); 
                        } 
                    } 
  
# Complete file write (output process metadata and close Root element 
                    $EndDate = Get-Date; 
                    $TimeDiff = $EndDate - $StartDate; 
                    $TimeSeconds = [int]$TimeDiff.TotalSeconds; 
                    $TimeMilliSeconds = [int]$TimeDiff.TotalMilliSeconds; 
  
# Write log wrap up entries 
                    Add-LogEntry -LineValue $($Tab+'Results of data collection processing'); 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Number of items processed: ' + [string]$TableReadCount + ' out of ' + $MaxTableCount + ' requested'); 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Total number of element entries written: ' + [string]$TotalRowCount); 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Total processing time in milliseconds: ' + [string]$TimeMilliSeconds); 
  
# Write ProcessResult element 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Adding ProcessResult element'); 
                    $Table = 'ProcessResult'; 
                    $WriteList = 'ElementsCollected', 'ElementsRequested', 'ElementItemsTotal', 'ProcessTimeStart', 'ProcessTimeEnd', 'ProcessTimeInMilliseconds', 'ExecutionStatus', 'ExecutionStatusMessage'; 
                    $i=@{}; 
                    $i.ElementsCollected = $TableReadCount; 
                    $i.ElementsRequested = $MaxTableCount; 
                    $i.ElementItemsTotal = $TotalRowCount; 
                    $i.ProcessTimeStart = $(Get-Date $StartDate -format s); 
                    $i.ProcessTimeEnd = $(Get-Date $EndDate -format s); 
                    $i.ProcessTimeInMilliseconds = $TimeMilliSeconds; 
                    If ($MaxTableCount -ne $TableReadCount -and $LogStore -match 'List of missing columns') 
                    { 
                        $i.ExecutionStatus = 'Incomplete'; 
                        $i.ExecutionStatusMessage = 'Missing table elements and column elements.'; 
                    } 
                    ElseIf ($MaxTableCount -ne $TableReadCount) 
                    { 
                        $i.ExecutionStatus = 'Incomplete'; 
                        $i.ExecutionStatusMessage = 'Missing table elements.'; 
                    } 
                    ElseIf ($LogStore -match 'List of missing columns') 
                    { 
                        $i.ExecutionStatus = 'Incomplete'; 
                        $i.ExecutionStatusMessage = 'Missing column elements.'; 
                    } 
                    Else 
                    { 
                        $i.ExecutionStatus = 'Success'; 
                        $i.ExecutionStatusMessage = 'All requested elements and columns collected.'; 
                    } 
                    $ProcessResult = New-Object PSObject -Property $i; 
                    $ProcessResult | Select-Object $WriteList | ForEach-Object {$_.psobject.properties | ForEach-Object {$XMLFileStream.WriteLine($Tab + '<' + $Table + '>')} {$XMLFileStream.WriteLine($($Tab + $Tab + '<' + $_.name + '>' + $_.value + '</' + $_.name + '>'))} {$XMLFileStream.WriteLine($Tab + '</' + $Table + '>')}}; 
# Write closing Root element 
                    Add-LogEntry -LineValue $($Tab+$Tab+'Adding closing Root element'); 
                    $XMLFileStream.WriteLine($XmlRootClose); 
                } 
                Else 
                { 
                    $ErrorMessage = 'No selectable rows found using the specified parameters'; 
                } 
            } 
        } 
        Catch 
        { 
            $ErrorMessage = $_.Exception.Message; 
        } 
#endregion COLLECT AND WRITE XMLFILE 
  
#region PROCESS SUCCESS FLAG 
        If (!$ErrorMessage) 
        { 
#If we made it all the way to the end without terminating set statue true 
            $ExecutionSuccess = $true; 
        } 
#endregion PROCESS SUCCESS FLAG 
    } 
} 
Catch 
{ 
    $ErrorMessage = $_.Exception.Message; 
} 
Finally 
{ 
#Close XML Stream 
    Try 
    { 
        If ($XMLFileStream) 
        { 
            $XMLFileStream.Close(); 
            Add-LogEntry -LineValue $($Tab+'Xml file ' + $XmlFilename + ' created.'); 
        } 
        Else 
        { 
#If there was no file to close, assume no file was opened and clear file name for output 
            $XmlFileName = ''; 
        } 
    } 
    Catch 
    { 
        If ($ErrorMessage) 
        { 
            $ErrorMessage += ': Failed to properly close XML File.'; 
        } 
        Else 
        { 
            $ErrorMessage = 'Failed to properly close XML File'; 
        } 
    } 
  
#Create and write Log file if not Suppressed 
    If (!$SuppressLogFile) 
    { 
#If we fell into the PROGRAM MAIN Catch we need to close our processing time stamp 
        If (!$EndDate) 
        { 
            $EndDate = Get-Date; 
            $TimeDiff = $EndDate - $StartDate; 
            $TimeMilliSeconds = [int]$TimeDiff.TotalMilliSeconds; 
        } 
#Write log file 
        Try 
        { 
            If (!$LogFileName) 
            { 
                $LogFileName = $LogFilePath + 'landesk_' + $FileDate + '.' + $LogFileExtension; 
            } 
            $LogFileStream = New-Object System.IO.StreamWriter $LogFileName; 
            $LogFileStream.AutoFlush = $true; 
            Add-LogEntry -LineValue $($Tab+'Script processing time in milliseconds: ' + $TimeMilliSeconds); 
            If (!$ExecutionSuccess) 
            { 
#If the script is exited with a Ctrl+C the flag will not be set and no error will have been generated 
                If (!$ErrorMessage) 
                { 
                    $ErrorMessage = 'Script execution terminated - file write incomplete.'; 
                } 
                Add-LogEntry -LineValue $($Tab+'ExecutionStatus = Failure'); 
                Add-LogEntry -LineValue $($Tab+'ExecutionStatusMessage = ERROR: ' + $ErrorMessage); 
            } 
            Else 
            { 
                If ($MaxTableCount -ne $TableReadCount -and $LogStore -match 'List of missing columns') 
                { 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatus = Incomplete'); 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatusMessage = Missing table elements and column elements.'); 
                } 
                ElseIf ($MaxTableCount -ne $TableReadCount) 
                { 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatus = Incomplete'); 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatusMessage = Missing table elements.'); 
                } 
                ElseIf ($LogStore -match 'List of missing columns') 
                { 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatus = Incomplete'); 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatusMessage = Missing column elements.'); 
                } 
                Else 
                { 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatus = Success'); 
                    Add-LogEntry -LineValue $($Tab+'ExecutionStatusMessage = All requested elements and columns collected.'); 
                } 
            } 
            Add-LogEntry -LineValue $('Processing End: ' + $((Get-Date -format s).Replace('T', ' '))); 
  
            $LogStore.GetEnumerator() | Sort-Object Name | ForEach-Object {$LogFileStream.WriteLine($_.Value)} -ErrorAction SilentlyContinue; 
            $LogFileStream.Close(); 
        } 
        Catch 
        { 
            If (!$xDTCall) 
            { 
                If ($ErrorMessage) 
                { 
                    $ErrorMessage += ': Could not create LOG File'; 
                } 
                Else 
                { 
                    $ErrorMessage = 'Could not create LOG File'; 
                } 
            } 
        } 
    } 
    $CollectionResults = '' | Select-Object 'CollectionSuccess', 'FileName', 'Error'; 
    $CollectionResults.CollectionSuccess = $ExecutionSuccess; 
    $CollectionResults.FileName = $XmlFileName; 
    $CollectionResults.Error = $ErrorMessage; 
} 
#endregion PROGRAM MAIN 
If ($xDTCall) 
{ 
    Return $CollectionResults; 
} 
Else 
{ 
    $CollectionResults | Format-List; 
} 