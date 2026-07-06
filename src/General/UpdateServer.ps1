Function Update-MyAppServers
{
<#
.SYNOPSIS
Sample function to update files on an application share.
.DESCRIPTION
This function will update files on a application share and report on the outcome. 
It will also close open SMB sessions to allow for the file update for a specified exe.
This command uses CIMsessions to remotely close files so Winrm but be enabled as well as 
the target server being Windows 2012 or newer. Functionality to close all SMB session to the 
target share is available for older servers when using the ForceKillSMB parameter. Sometimes
the client will reestablish the connection before the file copy can take place which will prevent 
the copy. The output will contain a whenUpdated property which in the case no file update is made it will 
be the creationtime of the exe file specified, otherwise it will reflect the current time of when the function
was run when newer files were copied.
.PARAMETER ComputerName
Provide a ComputerName to update
.PARAMETER SourcePath
Provide a source file path for the files to copy to the target server.
.PARAMETER EXEName
Provide the name of the exe that is being updated.
.PARAMETER LocalSharePath
Provide the path on the local server to update the files.
.PARAMETER ShareName
Provide the name of the file share being updated.
.PARAMETER ForceKillSMB
Use this parameter if you want to kill all SMB sessions to the target file share in the case
that a CIMsession can't be used to only target the open file sessions of the specified EXE.
.EXAMPLE
PS C:\> Update-MyAppServers -computername 38.255.240.239
.EXAMPLE
$servers = 1..8 | %{"testsrv$_"}
$results = Update-MyAppServers -ComputerName $servers -Verbose -Confirm:$false
$results | Out-gridview
.EXAMPLE
#You can take the results of the command and filter it to retry computers that had failed previously.
$results | where updatestatus -eq "failed" |
 Update-MyAppServers -Verbose -Confirm:$false | Out-GridView

NAME        :  Update-MyAppServers
LAST UPDATED:  10/22/2015

  ****************************************************************
The sample scripts are not supported under any Microsoft standard support program
 or service. The sample scripts are provided AS IS without warranty of any kind. 
 Microsoft further disclaims all implied warranties including, without limitation,
 any implied warranties of merchantability or of fitness for a particular purpose.
 The entire risk arising out of the use or performance of the sample scripts and
 documentation remains with you. In no event shall Microsoft, its authors,
 or anyone else involved in the creation, production, or delivery of the
 scripts be liable for any damages whatsoever (including, without limitation,
 damages for loss of business profits, business interruption,
 loss of business information, or other pecuniary loss) arising out of the 
 use of or inability to use the sample scripts or documentation, even if Microsoft
 has been advised of the possibility of such damages. 
  ****************************************************************
.LINK
about_Functions                                                                                   
about_Functions_Advanced                                                                          
about_Functions_Advanced_Methods                                                                  
about_Functions_Advanced_Parameters                                                               
about_Functions_CmdletBindingAttribute
#>
#requires -version 3
[cmdletbinding(SupportsShouldProcess=$true,
                ConfirmImpact='High')]
param(
        [parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        mandatory=$true,
        HelpMessage = "Provide a server name to update")]
       [ValidateNotNullOrEmpty()]
       [string[]]$ComputerName ,
       [parameter(ValueFromPipelineByPropertyName=$true)]
       [validateScript({Test-path $_})]
       [string]$SourcePath = ".\serverUpdate",
       [parameter(ValueFromPipelineByPropertyName=$true)]
       [string]$EXEName = "WMIExplorer.exe",
       [parameter(ValueFromPipelineByPropertyName=$true)]
       [string]$LocalSharePath = "C:\appshare",
       [parameter(ValueFromPipelineByPropertyName=$true)]
       [string]$ShareName = "appshare",
       [switch]$ForceKillSMB

)
process
{
    ForEach ($computer in $computerName)
    {
        
        If ($PSCmdlet.ShouldProcess($computer,"Performing Server Update for $exename on $computer") )
        {
            $error.clear()
            $UpdateServerobj = [pscustomobject]@{
                    ComputerName = $computer
                    SourcePath = $SourcePath
                    ExeName = $EXEName
                    OldVersion=$null
                    NewVersion=(Get-Item "$SourcePath\$exename").VersionInfo.productversion
                    UpdateStatus = "Failed"
                    StatusMessage = $null           
                    SharePath = $null
                    UsersUsingFile=$null
                    WhenUpdated =$null
                    ErrorDetails = $null
                }
            if ( Test-Connection -ComputerName $Computer -Count 1 -Quiet)
            {
                Write-Verbose "$Computer Server Online - Proceding with update..." 
                # Define location of the destination path
                $SharePath = "\\$Computer\$ShareName"
                $UpdateServerobj.sharepath = $sharepath
                $oldFileInfo = Get-item "$SharePath\$exename"
                $UpdateServerobj.OldVersion =  $oldFileInfo.VersionInfo.productversion

                if ($UpdateServerobj.NewVersion -gt $UpdateServerobj.OldVersion)
                {
                try{
                    try
                    {
                        Get-SmbOpenFile -CimSession $Computer | where path -eq "$LocalSharePath\$EXEName" -OutVariable FilesInUse | Close-SmbOpenFile -Confirm:$false
                        if ($filesinuse)
                        {
                        $UpdateServerobj.UsersUsingFile = ($filesinuse.clientusername | Select-Object -unique) -join ";"
                        }
                    } 
                    catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException],[Microsoft.Management.Infrastructure.CimException]
                    {
                        if($ForceKillSMB)
                        {
                        $UsersWithOpenFiles = stop-SMBSession -ServerName $computer -sharename $ShareName
                        $UpdateServerobj.UsersUsingFile = $UsersWithOpenFiles -join ';'
                        }
                    }
                    try
                    {
                        $UpdateServerobj= Copy-AppFiles -UpdateServerobj $UpdateServerobj -sourcePath $SourcePath -SharePath $SharePath -computer $Computer 
                    }
                    catch [System.IO.IOException]
                    {
                        if ($_.exception.message -like "*another process*" -and $ForceKillSMB)
                        {
                        try{
                        $UsersWithOpenFiles = stop-SMBSession -ServerName $computer -sharename $ShareName
                        $UpdateServerobj.UsersUsingFile = $UsersWithOpenFiles -join ";"
                        Get-childitem $sourcePath | Copy-Item  -Destination $SharePath -Verbose -ErrorAction Stop
                        $UpdateServerobj.whenupdated = (get-date)
                        $UpdateServerobj.UpdateStatus = "Success"
                        $UpdateServerobj.StatusMessage = "Update Completed"
                        }
                        catch{

                            throw $_

                        }
                        }
                    }
                   }    
                   catch
                   {
                        $UpdateServerobj.whenupdated = (get-date)
                        $UpdateServerobj.newversion= $null
                        $UpdateServerobj.UpdateStatus = "Failed"
                        $UpdateServerobj.StatusMessage = "File copy failed: $($_.exception.message)"
                        write-verbose "Error occured during file copy to $computer"
                        Write-verbose "Error type was $($_.exception.gettype().Fullname)"
                        Write-error $_
                   }
                   Finally
                   {
                        if ($error)
                        {
                        $UpdateServerobj.ErrorDetails = $error.clone()
                        $error.Clear()
                        }
                        $UpdateServerobj
                   }
                }
                Else
                {
                    #File already up to date
                    $UpdateServerobj.StatusMessage = "File already up to date"
                    $UpdateServerobj.UpdateStatus = "Success"
                    $UpdateServerobj.WhenUpdated = $oldFileInfo.CreationTime
                    $UpdateServerobj
                }
            }
            else
            {
                    #pingFailed
                    $UpdateServerobj.StatusMessage = "Ping failed"
                    $UpdateServerobj.newversion = $null
                    $UpdateServerobj
            }
        
        }
        
    }

}#End of process block

}#End of function
Function Copy-AppFiles
{[cmdletbinding()]
param($UpdateServerobj,$sourcePath,$SharePath,$computer)

    write-verbose "Copying new file(s)..."
    If ($VerbosePreference = "continue")
    { 
        Get-childitem $sourcePath | Copy-Item  -Destination $SharePath -Verbose -Force
    }
    else
    {
        Get-childitem $sourcePath | Copy-Item  -Destination $SharePath -Force

    }
    write-verbose "$Computer Update Complete"
    write-verbose "Copy Completed successfully" 
    write-verbose "$Computer Application on TEST server has been updated successfully" 
    $UpdateServerobj.whenupdated = (get-date)
    $UpdateServerobj.UpdateStatus = "Success"
    $UpdateServerobj.StatusMessage = "Update Completed"
    $UpdateServerobj
}
Function stop-SMBSession
{
    param([string]$ServerName,[string]$sharename,[string]$localsharePath)
    try{
        Get-SmbOpenFile -CimSession $ServerName -ErrorAction stop| where path -like "$localsharePath*" -OutVariable serverConnections | Close-SmbOpenFile -Confirm:$false -Force -ErrorAction stop
        $ServerConnections.ClientUserName | Select-Object -unique
        }
     catch{
        #If cimsessions fail, try using WMI
        $ServerConnections = Get-WmiObject -ComputerName $computer -Class Win32_serverconnection -Filter "ShareName ='$shareName' and NumberofFiles > 0"
        if ($ServerConnections)
        {
            $ClientComputers = ($ServerConnections.ComputerName | Select-Object -unique)
            #$Clientusers = ($ServerConnections.username | Select-Object -unique)
            Foreach ($client in $ClientComputers)
            {
            Invoke-WmiMethod -ComputerName $ServerName -Path win32_process -Name create -ArgumentList "net session \\$client /delete /y" | Out-Null
            }
            $serverConnections.username | Select-Object -unique
        }
    }
}



#$servers = 1..8 | %{"testsrv$_"}
#$results = Update-MyAppServers -ComputerName $servers -Verbose -Confirm:$false -ForceKillSMB -SourcePath C:\temp\ServerUpdate
#$results | Out-GridView
#$results | ConvertTo-Html -CssUri .\example.css | Out-File .\serverUpdate.htm

#$results | where updatestatus -eq "failed" |
 #Update-MyAppServers -Verbose -Confirm:$false -ForceKillSMB | Out-GridView

