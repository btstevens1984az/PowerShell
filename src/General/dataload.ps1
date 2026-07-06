# Purpose: dataload — General-purpose PowerShell utilities.
param( [string]$TargetName          = "pbi_sccm",
       [string]$SourceServer,
       [string]$SourceDatabase,
       [string]$DestinationServer,
       [string]$DestinationDatabase
)


$sql_uid=""
$sql_pwd=""
$sql_srv=$DestinationServer
$sql_db=$DestinationDatabase
$sql_srv_source=$SourceServer
$sql_db_source=$SourceDatabase
$bcp_batch_size=40000

# Make sure we execute the newest (or at least the ones installed by us)
$bcp = "$env:ProgramFiles\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\bcp.exe"
$sqlcmd = "$env:ProgramFiles\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\sqlcmd.exe"

New-Item Logs -ItemType Directory -ErrorAction Ignore
$current_time   =  Get-Date -Format "yyyyMMdd-HHmmss"
$bcp_error_log  = ".\Logs\bcp_errors_$($current_time).txt"
$bcp_output_log = ".\Logs\bcp_log_$($current_time).txt"


#region Win32 credential manager
# This region reuses code published at https://gist.github.com/toburger/2947424, under:
# 
# The MIT License
# 
# Copyright (c) 2012 Tobias Burger
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


$sig = @"
[DllImport("Advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr CredentialPtr);

[DllImport("Advapi32.dll", EntryPoint = "CredFree", SetLastError = true)]
public static extern bool CredFree([In] IntPtr cred);

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct NativeCredential
{
    public UInt32 Flags;
    public CRED_TYPE Type;
    public IntPtr TargetName;
    public IntPtr Comment;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
    public UInt32 CredentialBlobSize;
    public IntPtr CredentialBlob;
    public UInt32 Persist;
    public UInt32 AttributeCount;
    public IntPtr Attributes;
    public IntPtr TargetAlias;
    public IntPtr UserName;

    internal static NativeCredential GetNativeCredential(Credential cred)
    {
        NativeCredential ncred = new NativeCredential();
        ncred.AttributeCount = 0;
        ncred.Attributes = IntPtr.Zero;
        ncred.Comment = IntPtr.Zero;
        ncred.TargetAlias = IntPtr.Zero;
        ncred.Type = CRED_TYPE.GENERIC;
        ncred.Persist = (UInt32)1;
        ncred.CredentialBlobSize = (UInt32)cred.CredentialBlobSize;
        ncred.TargetName = Marshal.StringToCoTaskMemUni(cred.TargetName);
        ncred.CredentialBlob = Marshal.StringToCoTaskMemUni(cred.CredentialBlob);
        ncred.UserName = Marshal.StringToCoTaskMemUni(System.Environment.UserName);
        return ncred;
    }
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct Credential
{
    public UInt32 Flags;
    public CRED_TYPE Type;
    public string TargetName;
    public string Comment;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
    public UInt32 CredentialBlobSize;
    public string CredentialBlob;
    public UInt32 Persist;
    public UInt32 AttributeCount;
    public IntPtr Attributes;
    public string TargetAlias;
    public string UserName;
}

public enum CRED_TYPE : uint
{
    GENERIC = 1,
    DOMAIN_PASSWORD = 2,
    DOMAIN_CERTIFICATE = 3,
    DOMAIN_VISIBLE_PASSWORD = 4,
    GENERIC_CERTIFICATE = 5,
    DOMAIN_EXTENDED = 6,
    MAXIMUM = 7,      // Maximum supported cred type
    MAXIMUM_EX = (MAXIMUM + 1000),  // Allow new applications to run on old OSes
}

public class CriticalCredentialHandle : Microsoft.Win32.SafeHandles.CriticalHandleZeroOrMinusOneIsInvalid
{
    public CriticalCredentialHandle(IntPtr preexistingHandle)
    {
        SetHandle(preexistingHandle);
    }

    public Credential GetCredential()
    {
        if (!IsInvalid)
        {
            NativeCredential ncred = (NativeCredential)Marshal.PtrToStructure(handle, typeof(NativeCredential));
            Credential cred = new Credential();
            cred.CredentialBlobSize = ncred.CredentialBlobSize;
            cred.CredentialBlob = Marshal.PtrToStringUni(ncred.CredentialBlob, (int)ncred.CredentialBlobSize / 2);
            cred.UserName = Marshal.PtrToStringUni(ncred.UserName);
            cred.TargetName = Marshal.PtrToStringUni(ncred.TargetName);
            cred.TargetAlias = Marshal.PtrToStringUni(ncred.TargetAlias);
            cred.Type = ncred.Type;
            cred.Flags = ncred.Flags;
            cred.Persist = ncred.Persist;
            return cred;
        }
        else
        {
            throw new InvalidOperationException("Invalid CriticalHandle!");
        }
    }

    override protected bool ReleaseHandle()
    {
        if (!IsInvalid)
        {
            CredFree(handle);
            SetHandleAsInvalid();
            return true;
        }
        return false;
    }
}
"@
Add-Type -MemberDefinition $sig -Namespace "ADVAPI32" -Name 'Util'
#endregion

function Cleanup
{
    del "$env:TEMP\pbist_sccm_in.txt" -ErrorAction Ignore
    del "$env:TEMP\pbist_sccm_transformed.txt" -ErrorAction Ignore
}

function Get-Setting
{
    param([string]$SettingName)

    [string]$result = ""
    [string]$query = "SET NOCOUNT ON; SELECT value FROM pbist_sccm.[configuration] WHERE name='$SettingName' AND configuration_group='SolutionTemplate' AND configuration_subgroup='System Center'"
    
    if ( [string]::IsNullOrEmpty($script:sql_uid) )
    {
        $result = & $script:sqlcmd -I -a 32767 -S $script:sql_srv -d $script:sql_db -E -Q $query -h -1
    } else
    {
        $result = & $script:sqlcmd -I -a 32767 -S $script:sql_srv -d $script:sql_db -U $script:sql_uid -P $script:sql_pwd -Q $query -h -1
    }

    return $result.TrimEnd()
}


function Set-Config-Value
{
    param([string]$Name,
          [string]$Value)

    [string]$query = "SET NOCOUNT ON;
                      DELETE FROM pbist_sccm.[configuration] WHERE name='$Name' AND configuration_group='SolutionTemplate' AND configuration_subgroup='System Center';
                      INSERT INTO pbist_sccm.[configuration](configuration_group, configuration_subgroup, NAME, [value], [visible]) VALUES ('SolutionTemplate', 'System Center', '$Name', '$Value', 1)" 
    
    if ( [string]::IsNullOrEmpty($script:sql_uid) )
    {
        $result = & $script:sqlcmd -I -a 32767 -S $script:sql_srv -d $script:sql_db -E -Q $query -h -1
    } else
    {
        $result = & $script:sqlcmd -I -a 32767 -S $script:sql_srv -d $script:sql_db -U $script:sql_uid -P $script:sql_pwd -Q $query -h -1
    }
}


# configuration_group	configuration_subgroup	name
# SolutionTemplate	System Center	versionImage


$nCredPtr= New-Object IntPtr
$success = [ADVAPI32.Util]::CredRead($TargetName, 1, 0, [ref] $nCredPtr)

if ($success)
{
    $critCred = New-Object ADVAPI32.Util+CriticalCredentialHandle $nCredPtr
    try
    {
        $cred = $critCred.GetCredential()
        $sql_uid = $cred.UserName
        $sql_pwd = $cred.CredentialBlob
        $cred = $null
    }
    catch
    {
        Write-Information "Credentials in Windows Credential Manager for Target: $TargetName were empty"
        Write-Information "Target server will use integrated authentication"
    }
}
else
{
    Write-Information "No credentials were found in Windows Credential Manager for TargetName: $TargetName"
    Write-Information "Target server will use integrated authentication"
}


$file2table = [ordered]@{ "site.sql"                = "pbist_sccm.site_staging";
                          "update.sql"              = "pbist_sccm.update_staging";
                          "user.sql"                = "pbist_sccm.user_staging";
                          "usercomputer.sql"        = "pbist_sccm.usercomputer_staging";
                          "computermalware.sql"     = "pbist_sccm.computermalware_staging";
                          "computer.sql"            = "pbist_sccm.computer_staging";                      
                          "malware.sql"             = "pbist_sccm.malware_staging";
                          "scanhistory.sql"         = "pbist_sccm.scanhistory_staging";
                          "program.sql"             = "pbist_sccm.program_staging";
                          "computerupdate.sql"      = "pbist_sccm.computerupdate_staging";                      
                          "computerprogram.sql"     = "pbist_sccm.computerprogram_staging";
                          "collection.sql"          = "pbist_sccm.collection_staging";
                          "computercollection.sql"  = "pbist_sccm.computercollection_staging";
                         };


# Delete our files we use in case they already exist
Cleanup

foreach ($k in $file2table.Keys)
{
    $f = $file2table[$k]
    "`nStarting processing for $f"
    "`tStartDateTime: " + (Get-Date)
    "`tGenerating content"
    
    & $sqlcmd -I -a 32767 -f o:65001 -W -h-1 -s `"`t`" -E -w 2048 -S $sql_srv_source -d $sql_db_source -i $k -o "$env:TEMP\pbist_sccm_in.txt"
    if ($LASTEXITCODE -ne 0)
    {
        "Error generating content!!!"
        exit $LASTEXITCODE
    }

    "`tProcess temporary files"
    # Need to replace things like NULL since it won't be interpreted correctly
    Get-Content "$env:TEMP\pbist_sccm_in.txt" -ReadCount 50000 | ForEach-Object {$_ -replace '(\t?)(NULL)(\t?)', '$1$3' | Add-Content -Encoding UTF8 "$env:TEMP\pbist_sccm_transformed.txt"}
    if ($LASTEXITCODE -ne 0)
    {
        "Error processing content!!!"
        exit $LASTEXITCODE
    }

    "`tTable truncate"
    if ( [string]::IsNullOrEmpty($sql_uid) )
    {
       & $sqlcmd -I -a 32767 -S $sql_srv -d $sql_db -E -Q "TRUNCATE TABLE $f"
    } else
    {
       & $sqlcmd -I -a 32767 -S $sql_srv -d $sql_db -U $sql_uid -P $sql_pwd -Q "TRUNCATE TABLE $f"    
    }

    if ($LASTEXITCODE -ne 0)
    {
        "Error truncating destination table!!!"
        exit $LASTEXITCODE
    }

    "`tTable load"
    if ( [string]::IsNullOrEmpty($sql_uid) )
    {
        & $bcp $f in "$env:TEMP\pbist_sccm_transformed.txt" -c -C 65001 -k -t `"`t`" -S $sql_srv -d $sql_db -T -a 32767 -b $bcp_batch_size -e $bcp_error_log  2>&1 | out-file $bcp_output_log
    } else
    {
        & $bcp $f in "$env:TEMP\pbist_sccm_transformed.txt" -c -C 65001 -k -t `"`t`" -S $sql_srv -d $sql_db -U $sql_uid -P $sql_pwd -a 32767 -b $bcp_batch_size -e $bcp_error_log 2>&1 | Out-File $bcp_output_log
    }

    if ($LASTEXITCODE -ne 0)
    {
        if (Test-Path $bcp_output_log)
        {
            [string]$error_log = [System.IO.File]::ReadAllText($bcp_output_log)
            if ($error_log.IndexOf("Error") -gt -1 -and $error_log.IndexOf("Unable to open BCP host data-file") -gt -1)
            {
                continue
            }
        }

        "Error inserting data for $f!!!"
        exit 100
    } 
    
    "`tDeleting temporary content"
    Cleanup

    "`tEndDateTime: " + (Get-Date)
}

if ( [string]::IsNullOrEmpty($sql_uid) )
{
    & $sqlcmd -I -a 32767 -S $sql_srv -d $sql_db -E -i "process data.sql"
} else
{
    & $sqlcmd -I -a 32767 -S $sql_srv -d $sql_db -U $sql_uid -P $sql_pwd -i "process data.sql"
}

Set-Config-Value -Name "lastLoadTimestamp" -Value (Get-Date -Format d)

Get-ChildItem ".\Logs" | where {$_.length -eq 0} | Remove-Item -ErrorAction Ignore
