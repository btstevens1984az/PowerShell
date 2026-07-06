# Purpose: Get-WSUSConfiguration — Windows Server Update Services administration.
﻿Param(
    [Parameter(Mandatory=$True,HelpMessage="Please specify CSV file location")]
        $InputFile,
    [Parameter(Mandatory=$False)]        
        $OutPut = "$ENV:USERPROFILE\Desktop\WSUS_Configuration.CSV"
)
$ScriptBlock = {

$WSUS = Get-ItemProperty "HKLM:\Software\Microsoft\Update Services\Server\Setup"

    $DObject = New-Object PSObject
        $DObject | Add-Member -MemberType NoteProperty -Name "SqlDatabaseName" -Value $190.190.53.202.SqlDatabaseName
        $DObject | Add-Member -MemberType NoteProperty -Name "SqlServerName" -Value $190.190.53.202.SqlServerName
        $DObject | Add-Member -MemberType NoteProperty -Name "ContentDir" -Value $190.190.53.202.ContentDir
        $DObject | Add-Member -MemberType NoteProperty -Name "UsingSSL" -Value $190.190.53.202.UsingSSL
        $DObject | Add-Member -MemberType NoteProperty -Name "PortNumber" -Value $190.190.53.202.PortNumber
        $DObject | Add-Member -MemberType NoteProperty -Name "VersionString" -Value $190.190.53.202.VersionString
        $DObject | Add-Member -MemberType NoteProperty -Name "TargetDir" -Value $190.190.53.202.TargetDir
        $DObject | Add-Member -MemberType NoteProperty -Name "ServicePackLevel" -Value $190.190.53.202.ServicePackLevel
        $DObject | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value (Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
    $DObject
}

IF(Test-Path $InputFile){
    
    $Servers = Import-Csv $InputFile
    $EmptyArray = @()
    foreach($item in $Servers)
    {
        Try{
            Write-host "Processing $($item.Server) Server" -ForegroundColor Green
            $Command = Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $item.Server -ErrorAction STOP
            $EmptyArray += $Command
        }
        Catch{
            Write-host "Failed to Connect or WSUS not installed : $($item.Server)" -ForegroundColor RED
        }
    }

    $EmptyArray | Export-Csv $OutPut
}
Else{
    Write-Host " -- Please type correct file path ---" -ForegroundColor RED
}