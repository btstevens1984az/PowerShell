# Purpose: Check-DiskDefrag — Storage management and disk operations.
Function Check-DiskDefrag {
$allservers = "114.148.18.125"
#$allservers = Get-Content "C:\Users\btrut2\Scripts\MachineList.txt";

Get-Wmiobject -class Win32_Volume -Filter "DriveType='3'" -Computername $allservers | %{
new-object psobject |
add-member -pass NoteProperty Server $_.__server |
add-member -pass NoteProperty DriveLetter $_.DriveLetter |
add-member -pass NoteProperty Label $_.Label |
add-member -pass NoteProperty CLusterSize $_.DefragAnalysis().DefragAnalysis.ClusterSize | 
add-member -pass NoteProperty AverageFragmentsPerFile $_.DefragAnalysis().DefragAnalysis.AverageFragmentsPerFile
}
}