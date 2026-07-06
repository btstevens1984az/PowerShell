# Purpose: Get-MSIFileInformation — PowerShell automation.
param(
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$Path,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("ProductCode","ProductName","Manufacturer","MASTER_PREFERENCES","GPO_Script.VBS")]
    [string]$PROPERTY,

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("AppSearch","CostInitialize","ProductCode","FileCost","GPO_Script.VBS")]
    [string]$INSTALLUISEQUENCE
)

Process {
    try {
        #Read PROPERTY from MSI database
        $WindowsInstallerPROPERTY = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstallerPROPERTY.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstallerPROPERTY, @($Path.FullName, 0))
        $QueryPROPERTY = "SELECT Value FROM PROPERTY WHERE PROPERTY = '$($PROPERTY)'"
        $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($QueryPROPERTY))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
        $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
        $ValuePROPERTY = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)
        
        #Read INSTALLUISEQUENCE from MSI database
        $WindowsInstallerINSTALLUISEQUENCE = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstallerINSTALLUISEQUENCE.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $WindowsInstallerINSTALLUISEQUENCE, @($Path.FullName, 0))
        $QueryINSTALLUISEQUENCE = "SELECT Value FROM INSTALLUISEQUENCE WHERE ACTION = '$($INSTALLUISEQUENCE)'"
        $View = $MSIDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $MSIDatabase, ($QueryINSTALLUISEQUENCE))
        $View.GetType().InvokeMember("Execute", "InvokeMethod", $null, $View, $null)
        $Record = $View.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $View, $null)
        $ValueINSTALLUISEQUENCE = $Record.GetType().InvokeMember("StringData", "GetProperty", $null, $Record, 1)

        #Commit and close PROPERTY
        $MSIDatabase.GetType().InvokeMember("Commit", "InvokeMethod", $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember("Close", "InvokeMethod", $null, $View, $null)
        $MSIDatabase = $null
        $View = $null

        #Commit and close viewINSTALLUISEQUENCE
        $MSIDatabase.GetType().InvokeMember("Commit", "InvokeMethod", $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember("Close", "InvokeMethod", $null, $View, $null)  
        $MSIDatabase = $null
        $View = $null

        #Return the value
        return $ValuePROPERTY
        return $ValueINSTALLUISEQUENCE
    } 
    catch {
        Write-Warning -Message $_.Exception.Message ; break
    }
}
End {
    #Run garbage collection and release ComObject
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstallerPROPERTY) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstallerINSTALLUISEQUENCE) | Out-Null
    [System.GC]::Collect()
}