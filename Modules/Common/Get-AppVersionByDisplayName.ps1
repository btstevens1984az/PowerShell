# Purpose: Get-AppVersionByDisplayName — Reusable PowerShell function libraries.
function Get-AppVersionByDisplayName
{
    param
    (
        [parameter(Mandatory)]
        [string]
        $DisplayName,

        [parameter(Mandatory = $false)]
        [validateset('eq')]
        [string]
        $Operator
    )

    $UninstallKeys = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'

    foreach($key in $UninstallKeys)
    {
        switch($Operator)
        {
            Default
            {
                $property = Get-ChildItem -Path $key | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -match $DisplayName}
                if($property)
                {
                    return $property.DisplayVersion
                }
            }
            'eq'
            {
                $property = Get-ChildItem -Path $key | ForEach-Object {Get-ItemProperty $_.pspath} | Where-Object {$_.DisplayName -eq $DisplayName}
                if($property)
                {
                    return $property.DisplayVersion
                }
            }
        }
    }
}