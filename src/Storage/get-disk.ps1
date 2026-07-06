# Purpose: get-disk — Storage management and disk operations.
$erroractionpreference = "SilentlyContinue"
$objComputers = gc C:\AdminTasks\ScriptsPS\servers.txt
$smtpServer = "86.202.42.242" 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$emailFrom = "PowerShell2@example.com" 
$emailTo = "kkreitin@example.com" 

foreach ($Computer in $objComputers)

{
	    $objDisk = gwmi Win32_LogicalDisk -filter drivetype=3 -computer $Computer		
}

ComputerName = "$Computer"
Set wmiServices = GetObject ("winmgmts:{impersonationLevel=Impersonate}!//" & ComputerName)

' Get physical disk drive
Set wmiDiskDrives = wmiServices.ExecQuery ("SELECT Caption, DeviceID FROM Win32_DiskDrive")

For Each wmiDiskDrive In wmiDiskDrives
    WScript.Echo "Disk drive Caption: "& wmiDiskDrive.Caption & VbNewLine & "DeviceID: " & " (" & wmiDiskDrive.DeviceID & ")"

    'Use the disk drive device id to
    ' find associated partition
    query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" _
        & wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"    
    Set wmiDiskPartitions = wmiServices.ExecQuery(query)

    For Each wmiDiskPartition In wmiDiskPartitions
        'Use partition device id to find logical disk
        Set wmiLogicalDisks = wmiServices.ExecQuery _
            ("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" _
             & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 

        For Each wmiLogicalDisk In wmiLogicalDisks
            WScript.Echo "Drive letter associated" _
                & " with disk drive = " _ 
                & wmiDiskDrive.Caption _
                & wmiDiskDrive.DeviceID _
                & VbNewLine & " Partition = " _
                & wmiDiskPartition.DeviceID _
                & VbNewLine & " is " _
                & wmiLogicalDisk.DeviceID

		$subject = "Free Space on:", $Computer 
		$body = "Computer Name:", $Computer, "-", "Total Size:", ($objDisk.size), "-", "Free Space:", ($objDisk.Freespace)
		$smtp.Send($emailFrom,$emailTo,$subject,$body)

        Next      
    Next
Next



