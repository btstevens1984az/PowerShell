# Purpose: Get-Msiinfo — PowerShell automation.
function Get-Msiinfo {
param (
    [IO.FileInfo] $FilePath
)

try {
    $windowsInstaller = New-Object -com WindowsInstaller.Installer

    $database = $windowsInstaller.GetType().InvokeMember(
            "OpenDatabase", "InvokeMethod", $Null, 
            $windowsInstaller, @($FilePath.FullName, 0)
        )
#Select all Values in the Table "Property" but without Columnstitels
    $q = "SELECT * FROM Property"
    $View = $database.GetType().InvokeMember(
            "OpenView", "InvokeMethod", $Null, $database, ($q)
        )

    $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)

    $record = $View.GetType().InvokeMember(
            "Fetch", "InvokeMethod", $Null, $View, $Null
        )

    while($record -ne $null)
    {

        $shortcut = $record.GetType().InvokeMember(
                "StringData", "GetProperty", $Null, $record, 2
            )
        $shortcut

        $record = $View.GetType().InvokeMember(
                "Fetch", "InvokeMethod", $Null, $View, $Null
            )
    }


    $View.GetType().InvokeMember("Close", "InvokeMethod", $Null, $View, $Null)

    #return $shortcut

} catch {
    throw "Failed to get MSI Values, error was: {0}." -f $_
}
}

Get-Msiinfo -FilePath "C:\Users\$env:USERNAME\Desktop\Chrome-64-140-x64.msi"
