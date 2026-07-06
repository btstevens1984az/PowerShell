# Purpose: Optimize-Recyclebin — General-purpose PowerShell utilities.
function Optimize-RecycleBin {

Param($deleteBehaviour)

$signature = @'
    [DllImport("Shell32.dll",CharSet=CharSet.Unicode)]
    public static extern uint SHEmptyRecycleBin(
        IntPtr hwnd, 
        string pszRootPath, 
        uint dwFlags);
'@

$type = Add-Type -MemberDefinition $signature -Name FileUtils -Namespace W32Tools -PassThru

    if ($type::SHEmptyRecycleBin([System.IntPtr]::Zero,$null,$deleteBehaviour) -eq 0 )
    {
        return "Recycle Bin Emptied"
    }
}

<#
$NOCONFIRMATION = 0x00000001
$NOPROGRESSUI = 0x00000002
$NOSOUND = 0x00000004

Optimize-RecycleBin -deleteBehaviour ($NOSOUND -bor $NOCONFIRMATION)
#>