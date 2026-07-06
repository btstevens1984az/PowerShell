function Get-ExecutedPrograms {
<#
.SYNOPSIS
    Get a list of recently executed programs from the MUI cache.
.DESCRIPTION
    The Get-MuiCache cmdlet gets a list of recently executed programs from the MUI cache.
.EXAMPLE
    PS C:\> Get-ExecutedPrograms
.EXAMPLE
    PS C:\>Get-ExecutedPrograms | Out-File -Path C:\something.csv
.EXAMPLE
    PS C:\>Get-ExecutedPrograms -ComputerName 93.13.252.112
.EXAMPLE
    PS C:\>Get-ExecutedPrograms -ComputerName 93.13.252.112,COMPUTER02,COMPUTER03
.EXAMPLE
    PS C:\> Get-Content -Path C:\something.txt | Get-ExecutedPrograms
#>

    param (
        [parameter(
            Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $ComputerName = $env:ComputerName
    )

    process {
        foreach ($Computer in $ComputerName) {
            $Name = $Computer.ToUpper()

            if ($Name -ne $env:ComputerName) {
                Get-MuiCache $Name
                Get-CompatibilityAssistant $Name
            }
            else {
                Get-MuiCache
                Get-CompatibilityAssistant
            }
        }
    }
}

function Get-MuiCache {
    $ScriptBlock = {
        $RegistryKeyPaths = 'HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache',
                            'HKCU:\SOFTWARE\Microsoft\Windows\ShellNoRoam\MUICache'

        foreach ($RegistryKeyPath in $RegistryKeyPaths) {
            if (Test-Path -Path $RegistryKeyPath) {
                $KeyProperty = Get-Item -Path $RegistryKeyPath | Select-Object -ExpandProperty Property

                switch -wildcard ($KeyProperty) {
                    '*.FriendlyAppName' { $Path = $_ -Split('.FriendlyAppName') }
                    '*.ApplicationCompany' { $Path = $_ -Split('.ApplicationCompany') }
                    Default { continue }
                }
                Get-Item -Path $Path[0]
            }
            else {
                Write-Warning -Message ("{0} path does not exist" -f $RegistryKeyPath)
            }
        }
    }

    if ($args[0]) {
        Invoke-Command -ComputerName $args[0] -ScriptBlock $ScriptBlock
    }
    else {
        Invoke-Command -ScriptBlock $ScriptBlock
    }
}

function Get-CompatibilityAssistant {
    $ScriptBlock = {
        $RegistryKeyPaths =
            'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Persisted',
            'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store'

        foreach ($RegistryKeyPath in $RegistryKeyPaths) {
            if (Test-Path -Path $RegistryKeyPath) {
                $KeyProperties = Get-Item -Path $RegistryKeyPath | Select-Object -ExpandProperty Property
                foreach ($KeyProperty in $KeyProperties) {
                    Get-FileInformation -Path $KeyProperty
                }
            }
            else {
                Write-Warning -Message ("{0} path does not exist" -f $RegistryKeyPath)
            }
        }
    }

    if ($args[0]) {
        Invoke-Command -ComputerName $args[0] -ScriptBlock $ScriptBlock
    }
    else {
        Invoke-Command -ScriptBlock $ScriptBlock
    }
}

function Get-FileInformation {
<#
.SYNOPSIS
    This function returns file properties.
.DESCRIPTION
    This function returns file properties.
.EXAMPLE
    PS C:\> Get-FileInformation -Path c:\windows\system32\calc.exe
#>

    [CmdletBinding()]

    param(
        [parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
        [alias('FilePath')]
        [string]
        $Path
    )

    $Item = Get-Item -Path $Path

    [PSCustomObject]@{
        TypeName          = 'FileInformation'
        FullName          = $Item.FullName
        LastWriteTime     = $Item.LastWriteTime
        CreationTime      = $Item.CreationTime
        FileSize          = "{0:N0}" -f $Item.Length
        Attributes        = $Item.Attributes
        ProductName       = $Item.VersionInfo.ProductName
        ProductVersion    = $Item.VersionInfo.ProductVersion
        FileDescription   = $Item.VersionInfo.FileDescription
        FileVersion       = $Item.VersionInfo.FileVersion
        CompanyName       = $Item.VersionInfo.CompanyName
        LastAccessTime    = $Item.LastAccessTime
    }
}