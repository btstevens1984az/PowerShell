# Purpose: Get-InstalledSoftwareUpdates — Reusable PowerShell function libraries.
################################################################ 
# Script Title: Get Installed Software Updates PowerShell Tool 
# Script File Name: Get-InstalledSoftwareUpdates.ps1 
# Date Created: 10/25/2016 
# Version: 1.0 
################################################################ 
 
#Requires -Version 3.0 
 
Function Get-InstalledSoftwareUpdates 
{ 
    <#  
      .SYNOPSIS  
        
          The Get Installed Software Updates PowerShell Tool provides a convenient way of listing detailed information about each installed update in a nicely formatted output display and will also display application updates like Office updates.  
          
      .DESCRIPTION  
        
          The Get Installed Software Updates PowerShell Tool, unlike the built-in 'Get-HotFix' cmdlet which only dispalys operating system only updates, has the ability to display both operating system and Office updates by using the 'Microsoft.Update.Session' com object via the '[activator]' type accelerator. Using this method seems to exhibit better performance at retrieving installed updates as opposed to using the 'New-Object -ComObject Microsoft.Update.Session' method. Also, the "Get-HotFix' cmdlet displays the installed on date in UTC format, if it displays it at all. This is one of the reasons I created this tool, because I need to know the exact date and time an update was installed for troubleshooting purposes in local standard time, not UTC time.  
        
       .PARAMETER ComputerName  
        
          Used to target one or more computers.  
 
          This parameter does not belong to a parameter set. 
        
      .PARAMETER Credential 
        
          Used to gain access to remote computers that require either other privileges than those used to initially run the script.  
 
          This parameter does not belong to a parameter set. 
           
      .PARAMETER KBID 
        
          Used to specify one or more KB IDs to be retrieved.  
 
          This parameter belongs to the 'KBID' parameter set and can only be used with the following parameters: ComptuerName and Credential.  
 
          The parameter value must be written in the form of a Micorosoft KB article ID, such as KB123456, or the script will produce and error.  
       
      .PARAMETER KBIDList 
        
          Used to specify one or more KB IDs within a list to be retrieved.  
 
          This parameter belongs to the 'KBIDList' parameter set and can only be used with the following parameters: ComptuerName and Credential.  
 
          This parameter will be validated by checkin the path of the list specifed as the value, if the path cannot be found an error will produced.  
       
      .PARAMETER InstalledOnDate 
        
          Used to retrieve updates that were installed on one or more specified dates. 
 
          This parameter belongs to the 'InstalledOnDate' parameter set and can only be used with the following parameters: ComptuerName and Credential.  
       
      .PARAMETER GetAllUpdates 
        
          This is a switching parameter that does not require a value that is used to retrieve all updates on one or more computers, or it be used to retrieve updates on just the local computer. 
 
          This parameter belongs to the 'GetAllUpdates' parameter set and can only be used with the following parameters: ComptuerName and Credential.  
 
          The 'GetAllUpdates' parameter set is the default parameter when no other parameter sets are specified in the command.  
 
          **Please see the NOTES section below for more information on how the default 'GetAllUpdates' parameter set is used.  
       
      .EXAMPLE  
  
        Retrieve all software updates from a local or remote computer 
  
        Local Computer 
        -------------- 
 
        The following commands will produce identical results: 
         
        - Get-InstalledSoftwareUpdates  
         
        - Get-InstalledSoftwareUpdates -GetAllUpdates 
 
        Output Displayed 
        ---------------- 
 
        ComputerName      : LocalComputer1 
        KBID              : KB2506143 
        InstalledOnDate   : 6/22/2016 
        InstallResultCode : 2 
        InstallTime       : 5:09 AM 
        RevisionNumber    : 501 
        SupportUrl        : http://support.microsoft.com 
        UpdateDescription : This package installs Microsoft Windows Management Framework 3.0 
        UpdateId          : 1c2e00ab-bcde-4ec8-8987-6c7380ce10b8 
        UpdateTitle       : Update for Windows (KB2506143) 
  
        Remote Computer 
        --------------- 
  
        The following commands will produce identical results: 
         
        - Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130' 
 
        - Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130' -GetAllUpdates 
 
        **Note**  
        --------- 
         
        The output displayed will be identical to local computer installed software update retrieval, except the 'ComputerName' property will show the remote computer's name 
         
        If credentials are required to retrieve installed software updates on remote computers, use the 'Credential' parameter with the value following the 'Domain\Username' format.  
  
      .EXAMPLE  
  
        Retrieve all software updates that were installed on a specified date from a local or remote computer 
 
        Local Computer 
        -------------- 
         
        Get-InstalledSoftwareUpdates -InstalledOnDate '6/22/2016' 
 
        Output Displayed 
        ---------------- 
 
        ComputerName      : LocalComputer1 
        KBID              : KB2461484 
        InstalledOnDate   : 6/22/2016 
        InstallResultCode : 2 
        InstallTime       : 5:42 AM 
        RevisionNumber    : 200 
        SupportUrl        : http://go.microsoft.com/fwlink/?LinkId=59048 
        UpdateDescription : Install this update to revise the definition files that are used to detect viruses, spyware, and other  
                            potentially unwanted software. Once you have installed this item, it cannot be removed. 
        UpdateId          : 26c0b169-e6dc-44af-97df-38de6a986792 
        UpdateTitle       : Definition Update for Microsoft Endpoint Protection - KB2461484 (Definition 1.223.2346.0) 
 
        ComputerName      : LocalComputer1 
        KBID              : KB2506143 
        InstalledOnDate   : 6/22/2016 
        InstallResultCode : 2 
        InstallTime       : 5:09 AM 
        RevisionNumber    : 501 
        SupportUrl        : http://support.microsoft.com 
        UpdateDescription : This package installs Microsoft Windows Management Framework 3.0 
        UpdateId          : 1c2e00ab-bcde-4ec8-8987-6c7380ce10b8 
        UpdateTitle       : Update for Windows (KB2506143) 
 
        ComputerName      : LocalComputer1 
        KBID              : KB958830 
        InstalledOnDate   : 6/22/2016 
        InstallResultCode : 2 
        InstallTime       : 4:37 AM 
        RevisionNumber    : 501 
        SupportUrl        : http://support.microsoft.com 
        UpdateDescription :  
        UpdateId          : b570825d-7ca2-4584-9c90-bc4cc016075d 
        UpdateTitle       : Update for Windows (KB958830) 
 
        Remote Computer 
        ---------------- 
 
        Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130' -InstalledOnDate '6/22/2016' 
 
        **Note** 
        --------- 
 
        The output displayed will be identical to local computer installed software update retrieval, except the 'ComputerName' property will show the remote computer's name 
         
        To retrieve information from multiple remote computers, use the following syntax: 
 
        Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130', 'RemoteComputer2', 'RemoteComputer3' -InstalledOnDate '6/22/2016' 
      
      .EXAMPLE  
          
        Retrieve one or more specified updates using their KB article ID from a local or remote computer 
 
        Local Computer 
        -------------- 
         
        Get-InstalledSoftwareUpdates -KBID 'KB2506143' 
 
        Output Displayed 
        ---------------- 
         
        ComputerName      : LocalComputer1 
        KBID              : KB2506143 
        InstalledOnDate   : 6/22/2016 
        InstallResultCode : 2 
        InstallTime       : 5:09 AM 
        RevisionNumber    : 501 
        SupportUrl        : http://support.microsoft.com 
        UpdateDescription : This package installs Microsoft Windows Management Framework 3.0 
        UpdateId          : 1c2e00ab-bcde-4ec8-8987-6c7380ce10b8 
        UpdateTitle       : Update for Windows (KB2506143) 
 
        Remote Computer 
        --------------- 
         
        Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130' -KBID 'KB2506143' 
 
        **Note** 
        --------- 
 
        The output displayed will be identical to local computer installed software update retrieval, except the 'ComputerName' property will show the remote computer's name 
         
        To retrieve information from multiple remote computers, use the following syntax: 
 
        Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130', 'RemoteComputer2', 'RemoteComputer3' -KBID 'KB2506143' 
  
      .EXAMPLE 
 
        Retrieve one or more specified updates from a local or remote computer using a list of KBIDs in a text based file 
 
        Local Computer 
        -------------- 
         
        Get-InstalledSoftwareUpdates -KBIDList "$env:USERPROFILE\Desktop\KBIDList.txt" 
 
        Remote Computer 
        --------------- 
 
        Get-InstalledSoftwareUpdates -ComputerName '156.117.247.130', 'RemoteComputer2', 'RemoteComputer3' -KBIDList "$env:USERPROFILE\Desktop\KBIDList.txt" 
  
 
        How the 'GetAllUpdates' Default Parameter Set is Used 
        +++++++++++++++++++++++++++++++++++++++++++++++++++++ 
         
        The following commands will produce identical results, because the 'GetAllUpdates' parameter set enabled as the default: 
 
        Retrieving from a Local Computer 
        -------------------------------- 
 
        - Get-InstalledSoftwareUpdates 
 
        - Get-InstalledSoftwareUpdates -GetAllUpdates 
 
        The first command above will use the 'GetAllUpdates' parameter set and will initiate the 'GetAllUpdates' parameter since no other parameter sets were specified.  
         
        The second command above will use the 'GetAllUpdates' parameter set, because the 'GetAllUpdates' parameter is a member (and only member) of the 'GetAllUpdates' paramater set.  
         
        Retrieving from a Remote Computer 
        --------------------------------- 
 
        - Get-InstalledSoftwareUpdates -Computer 'LocalComputer1' 
 
        - Get-InstalledSoftwareUpdates -Computer 'RemoteComputer1' -GetAllUpdates 
 
        These commands used to retrieve updates from a remote computer are identical in relation to the ones above to retrieve updates from a local computer in how the 'GetAllUpdates' parameter set is used.  
 
        Script Requirements 
        ------------------- 
 
        - PowerShell Version 3.0 
 
        - PS Remoting  
      
      #>  
     
    [CmdletBinding(DefaultParametersetName = 'GetAllUpdates')]  
     
    Param 
    ( 
        [Parameter(Position = 0)] 
            [ValidateNotNullOrEmpty()] 
            [Alias('CN')] 
            $ComputerName = $env:COMPUTERNAME, 
 
        [Parameter(Position = 1)] 
            [ValidateNotNullOrEmpty()] 
            [ValidateScript({ $ComputerName -ne $null})] 
            [Alias('Cred')] 
            [PSCredential] 
            [System.Management.Automation.Credential()] 
            $Credential = [System.Management.Automation.PSCredential]::Empty, 
         
        [Parameter(ParameterSetName = 'GetAllUpdates', Position = 2)] 
            [Alias('GAU')] 
            [Switch]$GetAllUpdates, 
         
        [Parameter(ParameterSetName = 'InstalledOnDate', Position = 2)] 
            [ValidateNotNullOrEmpty()] 
            [ValidatePattern('\d{0,2}/\d{0,2}/\d{4}')] 
            [Alias('IOD')] 
            $InstalledOnDate,  
 
        [Parameter(ParameterSetName = 'KBID', Position = 2)] 
            [ValidateNotNullOrEmpty()] 
            [ValidatePattern('KB(\d+)')] 
            [Alias('KB')] 
            $KBID, 
         
        [Parameter(ParameterSetName = 'KBIDList', Position = 2)] 
            [ValidateNotNullOrEmpty()] 
            [ValidateScript({ Test-Path -Path $_ })] 
            [Alias('KBList')] 
            [String]$KBIDList 
    ) 
 
    Begin  
    {    
        $NewLine = "`r`n" 
 
        If ((!($PSBoundParameters.ContainsKey('ComputerName'))) -and ($PSBoundParameters.ContainsKey('Credential'))) 
        { 
            $NewLine 
 
            Write-Warning -Message "The 'Credential' parameter cannot be used without the 'ComputerName' parameter." 
 
            $NewLine 
 
            Write-Output -Verbose "Please rerun the 'Get-InstalledSoftwareUpdates' tool witht the appropriate parameter usage" 
 
            Break 
        } 
         
        $ScriptBlockKBID = { 
 
            $NewLine = "`r`n" 
             
            $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID(“Microsoft.Update.Session”)) 
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher() 
            $UpdateCount = $UpdateSearcher.GetTotalHistoryCount() 
            $InstalledUpdates = $UpdateSearcher.QueryHistory(0, $UpdateCount) 
                         
            $OutputProperties = @( 
 
                Foreach ($Update in $InstalledUpdates) 
                { 
                    If ($Update.ResultCode -eq '2') 
                    { 
                        [pscustomobject]@{ 
                            'ComputerName' = $env:COMPUTERNAME.ToUpper() 
                            'KBID'= ([regex]::match($Update.Title,'KB(\d+)')).Value.ToUpper() 
                            'InstalledOnDate' = $Update.Date | Get-Date -Format d 
                            'InstallResultCode' = $Update.ResultCode 
                            'InstallTime' = $Update.Date | Get-Date -Format t 
                            'RevisionNumber' = $Update.UpdateIdentity.RevisionNumber 
                            'SupportUrl' = $Update.SupportUrl 
                            'UpdateDescription' = $Update.Description 
                            'UpdateId' = $Update.UpdateIdentity.UpdateId 
                            'UpdateTitle'= $Update.Title 
                        } 
                    } 
                } 
            ) 
 
            Foreach ($ArgID in $Args[0]) 
            { 
                $ArgID = $ArgID.ToUpper() 
                 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.KBID -eq $ArgID } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput   
                } 
 
                Else 
                { 
                    $NewLine[0] 
 
                    Write-Warning -Message "$ArgID is not installed on computer $env:COMPUTERNAME" 
 
                    $NewLine[0] 
                } 
            } 
 
            Foreach ($ID in $KBID) 
            { 
                $ID = $ID.ToUpper() 
                 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.KBID -eq $ID } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput   
                } 
 
                Else 
                { 
                    $NewLine[0] 
 
                    Write-Warning -Message "$ID is not installed on computer $env:COMPUTERNAME" 
 
                    $NewLine[0] 
                } 
            } 
        } 
         
        $ScriptBlockKBIDList = { 
 
            $NewLine = "`r`n" 
 
            $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID(“Microsoft.Update.Session”)) 
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher() 
            $UpdateCount = $UpdateSearcher.GetTotalHistoryCount() 
            $InstalledUpdates = $UpdateSearcher.QueryHistory(0, $UpdateCount) 
                         
            $OutputProperties = @( 
 
                Foreach ($Update in $InstalledUpdates) 
                { 
                    If ($Update.ResultCode -eq '2') 
                    { 
                        [pscustomobject]@{ 
                            'ComputerName' = $env:COMPUTERNAME.ToUpper() 
                            'KBID'= ([regex]::match($Update.Title,'KB(\d+)')).Value.ToUpper() 
                            'InstalledOnDate' = $Update.Date | Get-Date -Format d 
                            'InstallResultCode' = $Update.ResultCode 
                            'InstallTime' = $Update.Date | Get-Date -Format t 
                            'RevisionNumber' = $Update.UpdateIdentity.RevisionNumber 
                            'SupportUrl' = $Update.SupportUrl 
                            'UpdateDescription' = $Update.Description 
                            'UpdateId' = $Update.UpdateIdentity.UpdateId 
                            'UpdateTitle'= $Update.Title 
                        } 
                    } 
                } 
            ) 
             
            Foreach ($ArgID in $Args[0]) 
            { 
                $ArgID = $ArgID.ToUpper() 
                 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.KBID -eq $ArgID } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput    
                } 
 
                Else 
                { 
                    $NewLine[0] 
 
                    Write-Warning -Message "$ArgID is not installed on computer $env:COMPUTERNAME" 
 
                    $NewLine[0] 
                } 
            } 
 
            Foreach ($ID in $ListContent) 
            { 
                $ID = $ID.ToUpper() 
                 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.KBID -eq $ID } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput    
                } 
 
                Else 
                { 
                    $NewLine[0] 
 
                    Write-Warning -Message "$ID is not installed on computer $env:COMPUTERNAME" 
 
                    $NewLine[0] 
                } 
            } 
        } 
 
        $ScriptBlockInstalledOnDate = { 
 
            $NewLine = "`r`n" 
 
            $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID(“Microsoft.Update.Session”)) 
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher() 
            $UpdateCount = $UpdateSearcher.GetTotalHistoryCount() 
            $InstalledUpdates = $UpdateSearcher.QueryHistory(0, $UpdateCount) 
                         
            $OutputProperties = @( 
 
                Foreach ($Update in $InstalledUpdates) 
                { 
                    If ($Update.ResultCode -eq '2') 
                    { 
                        [pscustomobject]@{ 
                            'ComputerName' = $env:COMPUTERNAME.ToUpper() 
                            'KBID'= ([regex]::match($Update.Title,'KB(\d+)')).Value.ToUpper() 
                            'InstalledOnDate' = $Update.Date | Get-Date -Format d 
                            'InstallResultCode' = $Update.ResultCode 
                            'InstallTime' = $Update.Date | Get-Date -Format t 
                            'RevisionNumber' = $Update.UpdateIdentity.RevisionNumber 
                            'SupportUrl' = $Update.SupportUrl 
                            'UpdateDescription' = $Update.Description 
                            'UpdateId' = $Update.UpdateIdentity.UpdateId 
                            'UpdateTitle'= $Update.Title 
                        } 
                    } 
                } 
            ) 
             
            Foreach ($ArgDate in $Args[0]) 
            { 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.InstalledOnDate -eq $ArgDate } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput     
                } 
 
                Else 
                { 
                    $NewLine 
 
                    Write-Warning -Message "No update was installed on computer $env:COMPUTERNAME on the date of $ArgDate" 
 
                    $NewLine 
                } 
            } 
 
            Foreach ($Date in $InstalledOnDate) 
            { 
                $DisplayOutput = $OutputProperties | Where-Object -FilterScript { $_.InstalledOnDate -eq $Date } 
                 
                If ($DisplayOutput) 
                { 
                    $DisplayOutput     
                } 
 
                Else 
                { 
                    $NewLine 
 
                    Write-Warning -Message "No update was installed on computer $env:COMPUTERNAME on the date of $Date" 
 
                    $NewLine 
                } 
            } 
        } 
 
        $ScriptBlockSetDefault = { 
 
            $NewLine = "`r`n" 
 
            $UpdateSession = [activator]::CreateInstance([type]::GetTypeFromProgID(“Microsoft.Update.Session”)) 
            $UpdateSearcher = $UpdateSession.CreateUpdateSearcher() 
            $UpdateCount = $UpdateSearcher.GetTotalHistoryCount() 
            $InstalledUpdates = $UpdateSearcher.QueryHistory(0, $UpdateCount) 
                         
            $OutputProperties = @( 
 
                Foreach ($Update in $InstalledUpdates) 
                { 
                    If ($Update.ResultCode -eq '2') 
                    { 
                        [pscustomobject]@{ 
                            'ComputerName' = $env:COMPUTERNAME.ToUpper() 
                            'KBID'= ([regex]::match($Update.Title,'KB(\d+)')).Value.ToUpper() 
                            'InstalledOnDate' = $Update.Date | Get-Date -Format d 
                            'InstallResultCode' = $Update.ResultCode 
                            'InstallTime' = $Update.Date | Get-Date -Format t 
                            'RevisionNumber' = $Update.UpdateIdentity.RevisionNumber 
                            'SupportUrl' = $Update.SupportUrl 
                            'UpdateDescription' = $Update.Description 
                            'UpdateId' = $Update.UpdateIdentity.UpdateId 
                            'UpdateTitle'= $Update.Title 
                        } 
                    } 
                } 
            ) 
 
            $OutputProperties 
        } 
    } 
 
    Process 
    { 
        If ($PSBoundParameters.ContainsKey('ComputerName')) 
        { 
            $NewLine 
            Write-Output -Verbose '=======================================================' 
            $NewLine                                                                      
            Write-Output -Verbose '            Check Computer(s) Online Status            ' 
            $NewLine                                  
            Write-Output -Verbose '=======================================================' 
            $NewLine 
                 
            $OnlineStatusComputer = Foreach ($Computer in $ComputerName)  
            { 
                    $Computer = $Computer.ToUpper() 
                         
                    $Online = @(ForEach-Object -Process { If (Test-Connection -ComputerName $Computer -Count '1' -Quiet) { $Computer } }) 
 
                    $Offline = @(ForEach-Object -Process { If (!(Test-Connection -ComputerName $Computer -Count '1' -Quiet)) { $Computer } }) 
 
                    [pscustomobject] @{ 
                        'Online' = $Online; 
                        'Offline' = $Offline 
                    } 
            } 
 
            If ($OnlineStatusComputer.Online) 
            { 
                $NewLine  
                     
                Write-Output -Verbose "---------- Computer(s) Online ----------" 
                      
                $NewLine 
 
                $OnlineStatusComputer.Online 
            } 
 
            If ($OnlineStatusComputer.Offline) 
            { 
                $NewLine  
                     
                Write-Output -Verbose "---------- Computer(s) Offline ----------" 
                      
                $NewLine 
 
                $OnlineStatusComputer.Offline 
            }    
        } 
         
        If(($PSBoundParameters.ContainsKey('ComputerName')) -and ($PSBoundParameters.ContainsKey('Credential'))) 
        { 
            Switch ($PSCmdlet.ParameterSetName) 
            { 
                'KBID'  
                {  
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    {       
                        Foreach ($ID in $KBID) 
                        { 
                            Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock $ScriptBlockKBID -ArgumentList $ID |  
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
                     
                'KBIDList' 
                { 
                    $ListContent = Get-Content -Path $KBIDList 
                         
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Foreach ($ID in $ListContent) 
                        { 
                            Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock $ScriptBlockKBIDList -ArgumentList $ID | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
 
                'InstalledOnDate' 
                { 
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Foreach ($Date in $InstalledOnDate) 
                        { 
                            Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock $scriptBlockInstalledOnDate -ArgumentList $Date | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
 
                'GetAllUpdates' 
                { 
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Invoke-Command -ComputerName $Computer  -Credential $Credential -ScriptBlock $ScriptBlockSetDefault | 
                            Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                    } 
                } 
            } 
        } 
 
        ElseIF (($PSBoundParameters.ContainsKey('ComputerName')) -and (!($PSBoundParameters.ContainsKey('Credential')))) 
        {  
            Switch ($PSCmdlet.ParameterSetName) 
            { 
                'KBID'  
                {  
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    {       
                        Foreach ($ID in $KBID) 
                        { 
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockKBID -ArgumentList $ID | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
                     
                'KBIDList' 
                { 
                    $ListContent = Get-Content -Path $KBIDList 
                         
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Foreach ($ID in $ListContent) 
                        {   
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockKBIDList -ArgumentList $ID | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
 
                'InstalledOnDate' 
                { 
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Foreach ($Date in $InstalledOnDate) 
                        { 
                            Invoke-Command -ComputerName $Computer -ScriptBlock $scriptBlockInstalledOnDate -ArgumentList $Date | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                } 
 
                'GetAllUpdates' 
                { 
                    Foreach ($Computer in $OnlineStatusComputer.Online) 
                    { 
                        Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockSetDefault | 
                            Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                    } 
                } 
            } 
        } 
 
        ElseIF ((!($PSBoundParameters.ContainsKey('ComputerName'))) -and (!($PSBoundParameters.ContainsKey('Credential')))) 
        { 
            $Computer = $env:COMPUTERNAME 
                             
            If ($PSBoundParameters.Count -eq '0' -and $PSCmdlet.ParameterSetName -eq 'GetAllUpdates') 
            { 
                Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockSetDefault | 
                    Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
            }  
             
            Else 
            { 
                Switch ($PSCmdlet.ParameterSetName) 
                { 
                    'KBID'  
                    {  
                        Foreach ($ID in $KBID) 
                        { 
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockKBID -ArgumentList $ID | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
                     
                    'KBIDList' 
                    { 
                        $ListContent = Get-Content -Path $KBIDList 
                         
                        Foreach ($ID in $ListContent) 
                        {   
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockKBIDList -ArgumentList $ID | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
 
                    'InstalledOnDate' 
                    { 
                        Foreach ($Date in $InstalledOnDate) 
                        { 
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockInstalledOnDate -ArgumentList $Date | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                        } 
                    } 
 
                    'GetAllUpdates' 
                    { 
                            Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlockSetDefault | 
                                Select-Object -Property * -ExcludeProperty PSComputerName, RunSpaceId  
                    } 
                } 
            }   
        } 
    } 
 
    End {} 
}