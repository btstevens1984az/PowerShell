# Purpose: Measure-UsnConsumption — General-purpose PowerShell utilities.
<#
    Concept By Todd Maxey, toddmax@microsoft.com

    Queries the NTFS USN jounral of whatever volume(s) you specify. This does not use
    the newer USN record versions in order to maintain backwards compatibility with older versions.
#>

Filter Query-UsnJournal
{
    Param([Parameter(Mandatory=$False, ValueFromPipeline=$True)][String[]]$DriveLetter = $Env:SystemDrive)

    If (-Not((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)))
    {
        Write-Error "This cmdlet requires administrative privileges and UAC elevation."
        Return
    }

    $NativeAPI = @'
        using System;
        using System.IO;
        using System.Threading;

        using System.Runtime.InteropServices;
        
        public class NativeAPI
        {
            public const Int64 INVALID_HANDLE_VALUE = -1;
            public const int FSCTL_QUERY_USN_JOURNAL = 0x000900f4;

            [StructLayout(LayoutKind.Sequential)]
            public struct USN_RECORD 
            {
                public UInt32 RecordLength;
                public UInt16 MajorVersion;
                public UInt16 MinorVersion;
                public UInt64 FileReferenceNumber;
                public UInt64 ParentFileReferenceNumber;
                public Int64 Usn;
                public Int64 TimeStamp;  // strictly, this is a LARGE_INTEGER in C
                public UInt32 Reason;
                public UInt32 SourceInfo;
                public UInt32 SecurityId;
                public UInt32 FileAttributes;
                public UInt16 FileNameLength;
                public UInt16 FileNameOffset;         // immediately after the FileNameOffset comes an array of WCHARs containing the FileName
            }

            [StructLayout(LayoutKind.Sequential)]
            public struct USN_JOURNAL_DATA
            {
                public long UsnJournalID;   
                public long FirstUsn;       
                public long NextUsn;        
                public long LowestValidUsn; 
                public long MaxUsn;         
                public long MaximumSize;    
                public long AllocationDelta;
            }

            [StructLayout(LayoutKind.Sequential)]
            public struct READ_USN_JOURNAL_DATA
            {
                public Int64 StartUsn;
                public UInt32 ReasonMask;
                public UInt32 ReturnOnlyOnClose;
                public UInt64 Timeout;
                public UInt64 BytesToWaitFor;
                public UInt64 UsnJournalID;
            }

            [System.Flags]
            public enum USN_REASON : uint
            {
                DATA_OVERWRITE        = 0x00000001,
                DATA_EXTEND           = 0x00000002,
                DATA_TRUNCATION       = 0x00000004,
                NAMED_DATA_OVERWRITE  = 0x00000010,
                NAMED_DATA_EXTEND     = 0x00000020,
                NAMED_DATA_TRUNCATION = 0x00000040,
                FILE_CREATE           = 0x00000100,
                FILE_DELETE           = 0x00000200,
                EA_CHANGE             = 0x00000400,
                SECURITY_CHANGE       = 0x00000800,
                RENAME_OLD_NAME       = 0x00001000,
                RENAME_NEW_NAME       = 0x00002000,
                INDEXABLE_CHANGE      = 0x00004000,
                BASIC_INFO_CHANGE     = 0x00008000,
                HARD_LINK_CHANGE      = 0x00010000,
                COMPRESSION_CHANGE    = 0x00020000,
                ENCRYPTION_CHANGE     = 0x00040000,
                OBJECT_ID_CHANGE      = 0x00080000,
                REPARSE_POINT_CHANGE  = 0x00100000,
                STREAM_CHANGE         = 0x00200000,
                CLOSE                 = 0x80000000
            } 

            [System.Flags]
            public enum USN_SOURCE : uint
            {
                DATA_MANAGEMENT        = 0x00000001,
                AUXILIARY_DATA         = 0x00000002,
                REPLICATION_MANAGEMENT = 0x00000004
            }

            [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
            public static extern IntPtr CreateFile(
                [MarshalAs(UnmanagedType.LPTStr)] string filename,
                [MarshalAs(UnmanagedType.U4)] FileAccess access,
                [MarshalAs(UnmanagedType.U4)] FileShare share,
                IntPtr securityAttributes, // optional SECURITY_ATTRIBUTES struct or IntPtr.Zero
                [MarshalAs(UnmanagedType.U4)] FileMode creationDisposition,
                [MarshalAs(UnmanagedType.U4)] FileAttributes flagsAndAttributes,
                IntPtr templateFile);


            [DllImport("kernel32.dll", SetLastError=true)]
            //[ReliabilityContract(Consistency.WillNotCorruptState, Cer.Success)]
            //[SuppressUnmanagedCodeSecurity]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool CloseHandle(IntPtr hObject);

            [DllImport("Kernel32.dll", CharSet=CharSet.Auto, SetLastError=true)]
            public static extern bool DeviceIoControl(
                IntPtr hDevice,
                uint dwIoControlCode,
                ref long InBuffer,
                int nInBufferSize, 
                ref USN_JOURNAL_DATA OutBuffer,
                int nOutBufferSize,
                ref int pBytesReturned,
                IntPtr UnUsed);
        }
'@

    Add-Type -TypeDefinition $NativeAPI

    :NextDrive Foreach ($Drive In $DriveLetter)
    {
        If (-Not($Drive.EndsWith(':')))
        {
            $Drive = $Drive + ':'
        }

        [IntPtr]$DriveHandle = [NativeAPI]::CreateFile("\\.\$Drive", [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite, [IntPtr]::Zero, [System.IO.FileMode]::Open, 0, [IntPtr]::Zero)
        If ($DriveHandle.ToInt32() -EQ [NativeAPI]::INVALID_HANDLE_VALUE)
        {
            Write-Error "Unable to open drive $Drive."
            Continue NextDrive
        }

        $JournalData = New-Object NativeAPI+USN_JOURNAL_DATA
        $ReadData    = New-Object NativeAPI+READ_USN_JOURNAL_DATA
        $UsnRecord   = New-Object NativeAPI+USN_RECORD
    
        [Long]$BytesRead = 0

        If (([NativeAPI]::DeviceIOControl(
            $DriveHandle, 
            [NativeAPI]::FSCTL_QUERY_USN_JOURNAL, 
            [ref]$Null,
            0,
            [ref]$JournalData,
            [System.Runtime.InteropServices.Marshal]::SizeOf($JournalData),
            [ref]$BytesRead,
            [IntPtr]::Zero)) -EQ 0)
        {
            Write-Error "DeviceIoControl failed during USN Journal query on drive $Drive with error code $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"

            If ($DriveHandle.ToInt32() -GT 0)
            {
                If ([NativeAPI]::CloseHandle($DriveHandle) -EQ 0)
                {
                    Write-Warning "Could not close handle to drive $Drive."
                }
            }

            Continue NextDrive
        }

        If ($DriveHandle.ToInt32() -GT 0)
        {
            If ([NativeAPI]::CloseHandle($DriveHandle) -EQ 0)
            {
                Write-Warning "Could not close handle to drive $Drive."
            }
        }

        $UsnJournalInfo = New-Object PSObject

        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Drive Letter'     -Value $Drive
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Timestamp'        -Value (Get-Date)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'USN Journal ID'   -Value ("0x{0:x}" -f $JournalData.UsnJournalID)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'First USN'        -Value ("0x{0:x}" -f $JournalData.FirstUsn)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Next USN'         -Value ("0x{0:x}" -f $JournalData.NextUsn)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Lowest Valid USN' -Value ("0x{0:x}" -f $JournalData.LowestValidUsn)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Max USN'          -Value ("0x{0:x}" -f $JournalData.MaxUsn)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Maximum Size'     -Value ("0x{0:x}" -f $JournalData.MaximumSize)
        $UsnJournalInfo | Add-Member -MemberType NoteProperty -Name 'Allocation Delta' -Value ("0x{0:x}" -f $JournalData.AllocationDelta)        

        Write-Output $UsnJournalInfo
    }
}


<#
    Concept By Todd Maxey, toddmax@microsoft.com

    Utilizes Query-UsnJournal to measure USN Journal consumption over time. USN consumption
    at an extremely high rate can predict failures in services that rely on the USN journal (e.g. FRS, DFSR, etc.)
#>

Filter Measure-UsnConsumption
{
    Param([Parameter()][ValidateRange(5,([Uint16]::MaxValue))][UInt16]$DurationInSeconds = 60,
          [Parameter()][UInt32]$UsnConsumptionThreshold = 1000000,
          [Parameter()][String[]]$DriveLetter = $Env:SystemDrive,
          [Parameter()][Bool]$LogEvent = $True)


    If (-Not((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)))
    {
        Write-Error "This cmdlet requires administrative privileges and UAC elevation."
        Return
    }

    $UsnMeasurementBeforeCollection = @()

    # Collect a USN Journal measurement for each drive specified and add it to the collection.
    Foreach ($Drive In $DriveLetter)
    {
        $UsnMeasurementBeforeCollection += Query-UsnJournal -DriveLetter $Drive
    }
    
    Start-Sleep -Seconds $DurationInSeconds

    $UsnMeasurementAfterCollection = @()

    Foreach ($Drive In $DriveLetter)
    {
        $UsnMeasurementAfterCollection += Query-UsnJournal -DriveLetter $Drive
    }

    Foreach ($Drive In $DriveLetter)
    {
        $Drive = $Drive.Trim(':').Trim()

        $Before = $UsnMeasurementBeforeCollection | Where { ($_.'Drive Letter').StartsWith($Drive) }
        $After  = $UsnMeasurementAfterCollection  | Where { ($_.'Drive Letter').StartsWith($Drive) }

        $UsnMeasurementObject = New-Object PSObject
        $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'Drive Letter' -Value $Before.'Drive Letter'
        $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'Journal ID' -Value $After.'USN Journal ID'
        $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'DurationInSeconds' -Value $DurationInSeconds
        $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'USNs Consumed' -Value (($After.'Next USN') - ($Before.'Next USN'))
        $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'Threshold' -Value $UsnConsumptionThreshold
        If ($UsnMeasurementObject.'USNs Consumed' -GT $UsnConsumptionThreshold)
        {
            $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'Threshold Crossed' -Value $True
        }
        Else
        {
            $UsnMeasurementObject | Add-Member -MemberType NoteProperty -Name 'Threshold Crossed' -Value $False
        }

        Write-Output $UsnMeasurementObject

        If ($LogEvent)
        {
            # Register the event log source... squelch the error if the event log source has already been registered.
            Try
            {
                New-EventLog -LogName System -Source 'Measure-UsnConsumption' -ErrorAction Stop
            }
            Catch 
            { 
                If ($_.Exception.Message -NotLike "*already registered*")
                {
                    Write-Error $_
                }
            }

            If ($UsnMeasurementObject.'Threshold Crossed')
            {
                Write-EventLog -LogName System -Source 'Measure-UsnConsumption' -EntryType Error -EventId 2288 -Message "USN journal consumption on drive $Drive is high. This can be a predictor of failure in services that utilize the USN journal such as FRS and DFSR. Investigate applications and services causing high disk activity using Resource Monitor.`n`nDrive Letter: $($UsnMeasurementObject.'Drive Letter')`nJournal ID: $($UsnMeasurementObject.'Journal ID')`nMeasurement Duration: $($UsnMeasurementObject.'DurationInSeconds') seconds`nUSNs Consumed: $($UsnMeasurementObject.'USNs Consumed')`nThreshold: $($UsnMeasurementObject.'Threshold')`nThreshold Crossed: $($UsnMeasurementObject.'Threshold Crossed')"
            }
            Else
            {
                Write-EventLog -LogName System -Source 'Measure-UsnConsumption' -EntryType Information -EventId 2287 -Message "This informational event details the rate of USN consumption on the $Drive drive. It is currently below the configured threshold.`n`nDrive Letter: $($UsnMeasurementObject.'Drive Letter')`nJournal ID: $($UsnMeasurementObject.'Journal ID')`nMeasurement Duration: $($UsnMeasurementObject.'DurationInSeconds') seconds`nUSNs Consumed: $($UsnMeasurementObject.'USNs Consumed')`nThreshold: $($UsnMeasurementObject.'Threshold')`nThreshold Crossed: $($UsnMeasurementObject.'Threshold Crossed')"
            }

            If (-Not(Test-Path -Path HKLM:\SOFTWARE\Measure-UsnJournal\ -PathType Container))
            {
                New-Item HKLM:\SOFTWARE\Measure-UsnJournal\ | Out-Null
            }

            [String]$RegistryValue = [String]::Empty
            Try
            {
                $RegistryValue = (Get-ItemProperty HKLM:\SOFTWARE\Measure-UsnJournal $Drive -ErrorAction Stop).$Drive
            }
            Catch
            {

            }

            If ($RegistryValue.Length -GT 0)
            {
                If ($RegistryValue -NotLike ($UsnMeasurementObject).'Journal ID')
                {
                    Write-EventLog -LogName System -Source 'Measure-UsnConsumption' -EntryType Error -EventId 2289 -Message "USN journal ID change detected since the last time this script ran! This can be a predictor of failure in services that utilize the USN journal such as FRS and DFSR. Examine FRS or DFSR logs to ensure that the service is healthy.`n`nDrive Letter: $($UsnMeasurementObject.'Drive Letter')`nPrevious Journal ID: $RegistryValue`nNew Journal ID: $($UsnMeasurementObject.'Journal ID')`nMeasurement Duration: $($UsnMeasurementObject.'DurationInSeconds') seconds`nUSNs Consumed: $($UsnMeasurementObject.'USNs Consumed')`nThreshold: $($UsnMeasurementObject.'Threshold')`nThreshold Crossed: $($UsnMeasurementObject.'Threshold Crossed')"
                }

                Set-ItemProperty HKLM:\SOFTWARE\Measure-UsnJournal $Drive -Value ($UsnMeasurementObject).'Journal ID' -Force | Out-Null
            }
            Else
            {
                New-ItemProperty HKLM:\SOFTWARE\Measure-UsnJournal $Drive -Value ($UsnMeasurementObject).'Journal ID' -Force | Out-Null
            }
        }
    }
}

Measure-UsnConsumption


#Useage:
#Measure-UsnConsumption [-DurationInSeconds][-UsnConsumptionThreshold][-DriveLetter][-DriveLetter]

# Switches:
# -DurationInSeconds    Duration between the sample of NextUSN. Default is 60 seconds
# -UsnConsumptionThreshold    The threshold that a event log error will be generated based on the difference between the new NextUSN samples. Default is 1,000,000
# -DriveLetter    The volume to run the test agains. Default is the volume of the system drive.
# -LogEvent    Log results in System event log. Boolean. Default is $True

