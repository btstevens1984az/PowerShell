# Purpose: Get-Size — Reusable PowerShell function libraries.
Function Get-Size {
Param(
[Parameter(ValueFromPipeline=$True, Mandatory=$True)]
[Array] $Computers,
[Parameter(ValueFromPipeline=$True, Mandatory=$True, ValueFromPipelineByPropertyName=$true)]
[ValidateNotNullOrEmpty()]
[System.String] $Path
)

Function Class-Size($size)
{
IF($size -ge 1GB)
{
"{0:n2}" -f  ($size / 1GB) + " GB"
}
ELSEIF($size -ge 1MB)
{
"{0:n2}" -f  ($size / 1MB) + " MB"
}
ELSE
{
"{0:n2}" -f  ($size / 1KB) + " KB"
}
} 

function Get-FolderSize 
{
Param(
$Path, [Array]$Computers
) 
$Array = @()
Foreach($Computer in $Computers)
    {
    $ErrorActionPreference = "SilentlyContinue"

$Length = Invoke-Command -ComputerName $Computer -ScriptBlock {
 (Get-ChildItem $args[0] -Recurse | Measure-Object -Property Length -Sum).Sum

} -ArgumentList $Path

$Result = "" | Select Computer,Folder,Length
$Result.Computer = $Computer
$Result.Folder = $Path
$Result.Length = Class-Size $length
$array += $Result

}

return $array
}

Get-FolderSize -Computers $Computers -Path $Path
}