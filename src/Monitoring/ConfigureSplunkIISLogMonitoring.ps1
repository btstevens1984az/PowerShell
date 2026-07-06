<#
    ConfigureSplunkIISLogMonitoring.ps1
#>
<#
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
 You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and 
 distribute the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks
  to market Your software product in which the Sample Code is embedded; (ii) to include a valid 
  copyright notice on Your software product in which the Sample Code is embedded;
   and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any
    claims or lawsuits, including attorneys’ fees, 
  that arise or result from the use or distribution of the Sample Code.
#>

#region General Functions
Function Expand-EnvironmentString
{
<#
.Synopsis
   Expands/resolves environment variable stings like %computername%
.DESCRIPTION
   Expands/resolves environment variable stings like %computername%
.PARAMETER  Path
    Specify a string with an environment variable in the format of %var%\restof\Path
.EXAMPLE
   PS C:\Expand-EnvironmentString -path "%SystemDrive%\inetpub\logs\LogFiles"
   C:\inetpub\logs\LogFiles
.EXAMPLE
   PS C:\ "%SystemDrive%\inetpub\logs\LogFiles" | Expand-EnvironmentString
   C:\inetpub\logs\LogFiles
.INPUTS
   A string with an %envVar%
.OUTPUTS
   The same string inputed with environment variables expanded.
#>  
    param(
    [parameter( Mandatory=$True,
                    Position = 0,
                    HelpMessage="A string with an %envVar%",
                    ValueFromPipeline=$True, 
	                ValueFromPipelineByPropertyName=$True)]
    [string]$Path)
    process
    {    
    (New-object -ComObject "Wscript.Shell").expandEnvironmentStrings($Path)
    }
}
Function Get-IISLogInfo
{
<#
.Synopsis
   Get IIS log information for all sites on the server
.DESCRIPTION
   Get IIS log information for all sites on the server. It will return objects
   with site informaiton with additional properties of:
   SiteProtocol (i.e. http,https,ftp)
   LogPath (i.e. C:\inetpub\logs\LogFiles\W3SVC2) which is the specific site log path
   LogDirectory (i.e. C:\inetpub\logs\LogFiles) the parent log path definied in IIS.
   LogPathExists ($true or $false based on where the log directory exists. If no logs have
    been written yet then it might not exist).

   This command targets the local IIS server and requires Powershell version 3 and
   the IIS WebAdministration Module.
.EXAMPLE
    get-website
.EXAMPLE
    get-website | select-object name,site*,logpath*,LogDirectory
#>
    #requires -module WebAdministration
    #Requites -version 3
    [cmdletbinding()]
    param()
    Write-Verbose "Querying for sites on server: $($env:COMPUTERNAME)"
    $sites = get-website
    Write-Verbose "Customizing site output"
    $sites | Add-Member -Name LogDirectory -MemberType ScriptProperty -Value {
        if ($this.logfile.directory -like "%*")
        {
            $this.logfile.directory | Expand-EnvironmentString
        }
        else
        {
            $this.logfile.directory
        }
        
        }
    $sites | Add-Member -Name SiteProtocol -MemberType ScriptProperty -Value {$this.bindings.collection.protocol}
    $sites | Add-Member -Name LogPath -MemberType ScriptProperty -Value {
                if ($this.siteProtocol -like "http*")
                {
                    $this.LogDirectory+"\W3SVC$($this.id)"
                }
                elseif($this.siteProtocol -like "ftp*")
                {
                     $this.LogDirectory+"\FTPSVC$($this.id)"
                }
                else
                {
                    Write-Error "no known protocols detected"
                    "unknownProtocol"
                }

            }
    $sites | Add-Member -Name LogPathExists -MemberType ScriptProperty -Value {Test-Path -Path $this.logpath }   
       
    Write-Verbose "Site information gathering was successful, returning data"
    $sites
}
Function Remove-DoubleBlankLines
{
    param([string[]]$Strings)
    
    $previous = "placeholder"
    foreach($string in $strings)
    {
            if($previous -or $string)
            {
                $previous = $string
                $string
            }
            elseif( $previous -and -not $string)
            {
                $previous = $string
                $string
            }
            elseif(-not $previous -and -not $string)
            {
                #do nothing and skip the second emptyline
            }

        }

    

}
#endregion General Functions

#region Splunk Specific Functions
Function new-SplunkLogPath
{
    param(
            [parameter( Mandatory=$True,
                    ValueFromPipeline=$True, 
	                ValueFromPipelineByPropertyName=$True)]
            [string[]]$LogPath)
    process
    {
        foreach ($path in  $logpath)
        {
            "[monitor://D:\inetpub\logs\LogFiles\W3SVC*\*.log]"
        }

    }

}

Function Remove-SplunkSetting
{
    param ($SplunkSettings,$RemoveSetting)
    $count = 1
    $lineNumber = ($SplunkSettings | Select-String -Pattern $RemoveSetting -SimpleMatch).LineNumber
    $newconfig = @()
    $newConfig = $SplunkSettings | ForEach-Object {
    if ($count -ge $lineNumber -and $count -le ($lineNumber+2))
    {
        Write-Verbose "removing config for $RemoveSetting"
    }
    Else
    {
     $_
    }
    $count++
    }
    #return updated config
    $newconfig
}

Function Add-SplunkSetting
{
  param ($SplunkSettings,$AddSetting)   

  if ($AddSetting -like "*ftp*")
  {
$newSetting = @"

$AddSetting
sourcetype=w3cftp
ignoreOlderThan = 60d
"@
  }
  else
  {
    $newSetting = @"

$AddSetting
sourcetype=iis
ignoreOlderThan = 60d
"@
  }
  $SplunkSettings += $newSetting
  $SplunkSettings
}

Function Update-SplunkLogForwarderConfig
{
<#
.Synopsis
   Sample function to update splunk log forwarding configuration for IIS.
.DESCRIPTION
   Sample function to update splunk log forwarding configuration for IIS. The function assumes 
   only IIS logs are being collected using the specific splunk configuraiton file.
.Parameter SiteInfo
    This parameter takes as input the output from the Get-IISLogInfo function.
.Parameter SplunkConfigPat
    Path to splunk Configuration file.
.EXAMPLE
   Update-SplunkLogForwarderConfig -siteInfo $SiteInfo  -Verbose -WhatIf
.EXAMPLE
    To run function without confimation prompts
   Update-SplunkLogForwarderConfig -siteInfo $SiteInfo  -confirm:$false
#>
[cmdletbinding(SupportsShouldProcess = $true,
                ConfirmImpact='High')]
    param(
    [string]$SplunkConfigPath = 'c:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf',
    [parameter(Mandatory=$true)]
    $siteInfo
)

if (-not (Test-Path $SplunkConfigPath))
{
    throw "splunk config file not found at: $SplunkConfigPath"
}

$splunkConfig = Get-Content $SplunkConfigPath
$newSplunkConfig = $splunkConfig
$monitors = $splunkConfig | Select-String -Pattern "monitor" 
$differences = compare-object ($siteinfo.splunklogPath | select -Unique)  $monitors.line 
    if (-not ($differences))
    {
        Write-Verbose "No differences detected between IIS logfile directories and Splunk Config"
    }
    else
    {
        #update for differences
        #if sideindicator <= add config
        #if Sideindicator => remove config
       $remove = $differences  | where sideindicator -eq '=>' | Select-Object -ExpandProperty InputObject
       $add = $differences | where sideindicator -EQ '<=' | Select-Object -ExpandProperty InputObject
       if ($remove)
       {
        Foreach ($removeSetting in $remove)
        {
            if ($pscmdlet.ShouldProcess($removeSetting, "Removing log configuration"))
            {$newSplunkConfig = Remove-SplunkSetting -SplunkSettings $newSplunkConfig -RemoveSetting $removeSetting}
        }
   }
        if ($add)
        {
        foreach ($addSetting in $add)
        {
            if ($pscmdlet.ShouldProcess($addSetting, "Adding log configuration"))
            {$newSplunkConfig = Add-SplunkSetting -SplunkSettings $newSplunkConfig -AddSetting $addSetting}
        }
    
    }
    if ($pscmdlet.ShouldProcess($SplunkConfigPath, "Updating log collection configuration and backing up previous setting"))
    {
        $newSplunkConfig = Remove-DoubleBlankLines -Strings $newSplunkConfig
        $splunkConfig | Set-Content -PassThru "$SplunkConfigPath.backup" -Verbose
        $newSplunkConfig | Set-Content -Path $SplunkConfigPath -Verbose
        Restart-service -Name SplunkForwarder -Verbose
        
    }
    }
}

#endregion Splunk Specific Functions

$SiteInfo = Get-IISLogInfo -Verbose

#Add Splunk Log Path
$SiteInfo | Add-Member -Name SplunkLogPath -MemberType ScriptProperty -Value {

             "[monitor://"+$this.logPath.substring(0,(($this.logpath.length) -1)) +"*\*.log]"   
    
            }  
#$SiteInfo | select name,site*,logpath*,LogDirectory,splunk*
Update-SplunkLogForwarderConfig -siteInfo $SiteInfo  -Verbose -WhatIf

#Update-SplunkLogForwarderConfig -siteInfo $SiteInfo  -Verbose -Confirm:$false