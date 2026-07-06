# Purpose: Install-AzAutomationModuleWithDependencies — Microsoft Azure cloud resource management.
function Check-InstalledModule {
    <#
    .SYNOPSIS
        Checks if a module is installed for Azure Automation resource. If the module has older version than required - removes the module
    .DESCRIPTION
        Checks if a module is installed for Azure Automation resource. If the module has older version than required - removes the module
    .PARAMETER AutomationAccountName
        Target Azure automation account's name
    .PARAMETER ResourceGroupName
        Target Azure automation account's resource group
    .PARAMETER ModuleName
        Module name
    .PARAMETER ModuleVersion
        Module version
    .OUTPUTS
        Returns [bool] or Error/[string] data depending on circumstances
            [bool]$true - the module is found and satisfies version parameter
            [bool]$false - the module is not installed or has been removed due to its version
            [string]/error - in case of errors
    .EXAMPLE
        Check-InstalledModule -AutomationAccountName 'SampleAutomation' -ResourceGroupName 'SampleRG' -ModuleName 'Az.Accounts' -ModuleVersion '1.8'
        Checking if SampleAutomation automation accound belonging to SampleRG resource group has Az.Accounts module with ver. 1.8 or higher
    #>
    #Requires -Module 'Az.Automation'
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$AutomationAccountName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ResourceGroupName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ModuleName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ModuleVersion
    )

    # check if connected to azure context
    if (-not $(Get-Azcontext)) {
        Write-Error "No subscription found in the context.  Please ensure that the credentials you provided are authorized to access an Azure subscription, then run Connect-AzAccount to login."
        Exit
    }

    $Return = $false

    # check if module exists
    $ModuleExists = Get-AzAutomationModule -AutomationAccountName "$AutomationAccountName" -ResourceGroupName "$ResourceGroupName" `
                                            -Name "$ModuleName" -ErrorAction SilentlyContinue

    if ($ModuleExists) {
    # check the version
        if ([version]$ModuleExists.Version -ge [version]$ModuleVersion) {
            $Return = $true
        }
        else {
            Write-Warning "The module is installed, but it has version issues: $($ModuleExists.Version)"

            Write-Host "Removing Module: " -NoNewline
            Write-Host "$($ModuleExists.Name)" -ForegroundColor Yellow -NoNewline
            Write-Host "; Version:" -NoNewline
            Write-Host "$($ModuleExists.Version)" -ForegroundColor Yellow -NoNewline
            Write-Host "; AutomationAccountName:" -NoNewline
            Write-Host "$AutomationAccountName" -ForegroundColor Yellow -NoNewline
            Write-Host "; ResourceGroupName:" -NoNewline
            Write-Host "$ResourceGroupName" -ForegroundColor Yellow

            # removing
            try {
                Remove-AzAutomationModule -AutomationAccountName "$AutomationAccountName" -ResourceGroupName "$ResourceGroupName" `
                                            -Name "$ModuleName" -ErrorAction SilentlyContinue -Force
            }
            catch {
                # error handling
                Write-Error $_.Exception
                return $_.Exception
            }

            # verification
            $Timeout = 90
            $Timer = 0
            $Step = 2
            do {
                Write-Host '.' -NoNewline
                Start-Sleep -Seconds $Step
                $Timer += $Step

                $ModuleExists = Get-AzAutomationModule -AutomationAccountName "$AutomationAccountName" -ResourceGroupName "$ResourceGroupName" `
                                                        -Name "$ModuleName" -ErrorAction SilentlyContinue
            } while (($null -ne $ModuleExists) -or ($Timer -lt $Timeout))

            Write-Host ''

            # checking verification timeout
            if ($ModuleExists -and ($Timer -ge $Timeout)) {
                $Err = "Error removing the module, existed on timout: $Timeout"
                Write-Error $Err
                return $Err
            }
            else {Write-Host 'Removed'}
        }

    }

    return $Return
}

function Get-ModuleDependenciesRecursively {
    <#
    .SYNOPSIS
        Searches a module dependencies recursively utilising PowerShellGet module and returns the list as a custom object
    .DESCRIPTION
        Searches a module dependencies recursively utilising PowerShellGet module and returns the list as a custom object
    .PARAMETER ModuleName
        Root module name
    .PARAMETER Level
        Recursivity level for each run, helps to build installation sequesnce
    .PARAMETER MinVersion
        Module minimum version
    .PARAMETER ReqVersion
        Module required version
    .PARAMETER RepositoryName
        Repository name to search in
    .OUTPUTS
        Returns ps custom object with all dependencies recursively
    .EXAMPLE
        Get-ModuleDependenciesRecursively -ModuleName 'Az' -Level 0 -ReqVersion 1.5.5 -RepositoryName 'PSGallery'
        Searching for all dependencies for Az module with required version 1.5.5 in PSGallery repository
    #>
    #Requires -Module PowerShellGet
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ModuleName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][int]$Level,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$MinVersion,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$ReqVersion,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$RepositoryName
    )

    # check if connected to azure context
    if (-not $(Get-Azcontext)) {
        Write-Error "No subscription found in the context.  Please ensure that the credentials you provided are authorized to access an Azure subscription, then run Connect-AzAccount to login."
        Exit
    }

    # collection of modules to return
    $ModulesToReturn = @()

    # get the module
    if ($ReqVersion) {
        $Module = Find-Module -Name "$ModuleName" -RequiredVersion "$ReqVersion" -Repository "$RepositoryName"
    }
    else {
        $Module = Find-Module -Name "$ModuleName" -Repository "$RepositoryName"
    }

    # check min version
    if ($MinVersion) {
        if ([version]$($Module.Version) -lt [version]$MinVersion) {
            Write-Error "Module:'$($Module.Name)', ModuleVersion:'$($Module.Version)' found in RepositoryName:'$($Module.Repository)' is less than MininumVersion:'$MinVersion'"
            return $null
        }
    }

    $ModulesToReturn += [pscustomobject]@{
                                            Name = "$($Module.Name)"
                                            Version = "$($Module.Version)"
                                            Repository = "$($Module.Repository)"
                                            Priority = $Level
                                            InstallationStatus = 'NotStarted'
                                        }

    # get root module's dependencies
    $ModuleDependencies = $Module.Dependencies

    foreach ($Dependency in $ModuleDependencies) {
        # set $RequiredVersion
        if ($Dependency.RequiredVersion) {
            $ModulesToReturn += Get-ModuleDependenciesRecursively -ModuleName "$($Dependency.Name)" -ReqVersion "$($Dependency.RequiredVersion)" `
                                            -RepositoryName "$($Module.Repository)" -Level $($Level+1)
        }
        elseif ($Dependency.MinimumVersion) {
            $ModulesToReturn += Get-ModuleDependenciesRecursively -ModuleName "$($Dependency.Name)" -MinVersion "$($Dependency.MinimumVersion)" `
                                            -RepositoryName "$($Module.Repository)" -Level $($Level+1)
        }
        else {
            $ModulesToReturn += Get-ModuleDependenciesRecursively -ModuleName "$($Dependency.Name)" `
                                            -RepositoryName "$($Module.Repository)" -Level $($Level+1)
        }
    }

    return $ModulesToReturn
}

function Install-AzAutomationModuleWithDependencies {
        <#
    .SYNOPSIS
        Installs Azure automation account module with all dependencies recursively
        Can be used with -ResolveOnly switch only to resolve and show the dependencies
    .DESCRIPTION
        Installs Azure automation account module with all dependencies recursively
        Can be used with -ResolveOnly switch only to resolve and show the dependencies
    .PARAMETER AutomationAccountName
        Target Azure automation account's name
    .PARAMETER ResourceGroupName
        Target Azure automation account's resource group
    .PARAMETER ModuleName
        Module name
    .PARAMETER ModuleVersion
        Module version
    .PARAMETER RepositoryName
        Repository name to search in. By default it's 'PSGallery'
    .PARAMETER ResolveOnly
        Allows to resolve dependencies and output them without installing the modules
    .OUTPUTS
        Logs the installation process into console interactively
        Returns error if one of deployment phases's failed
    .EXAMPLE
        Install-AzAutomationModuleWithDependencies -AutomationAccountName 'SampleAutomation' -ResourceGroupName 'SampleRG' -ModuleName 'Az'
        Installs latest Az module version with all dependencies into SampleAutomation automation account belonging tp SampleRG resource group
    .EXAMPLE
        Install-AzAutomationModuleWithDependencies -AutomationAccountName 'SampleAutomation' -ResourceGroupName 'SampleRG' -ModuleName 'Az.Accounts' -ModuleVersion '1.8' -ResolveOnly
        Resolves dependencies for Az.Accounts ver 1.8 without installing the module and its dependencies
    #>
    #Requires -Module 'PowerShellGet','Az.Automation'
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$AutomationAccountName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ResourceGroupName,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ModuleName,
        [Parameter(Mandatory = $false)][string]$ModuleVersion,
        [Parameter(Mandatory = $false)][string]$RepositoryName = 'PSGallery',
        [Parameter(Mandatory = $false)][switch]$ResolveOnly
    )

    # check if connected to azure context
    if (-not $(Get-Azcontext)) {
        Write-Error "No subscription found in the context.  Please ensure that the credentials you provided are authorized to access an Azure subscription, then run Connect-AzAccount to login."
        Exit
    }

    if ($ResolveOnly) {Write-Warning "No modules will be installed, the script is running in ResolveOnly mode"}
    Write-Host "Searching for root module..."

    # get root module
    if ($ModuleVersion) {
        $RootModule = Find-Module -Name "$ModuleName" -RequiredVersion "$ModuleVersion" -Repository "$RepositoryName"
    }
    else {
        $RootModule = Find-Module -Name "$ModuleName" -Repository "$RepositoryName"
    }

    if (-not $RootModule) {
        Write-Error "Module:'$ModuleName', ModuleVersion:'$ModuleVersion' canot be found in RepositoryName:'$RepositoryName'"
        Exit
    }

    Write-Host "Root module found: " -NoNewline
    Write-Host "$($RootModule.Name)" -ForegroundColor Yellow -NoNewline
    Write-Host "; Version:" -NoNewline
    Write-Host "$($RootModule.Version)" -ForegroundColor Yellow -NoNewline
    Write-Host "; Repository: " -NoNewline
    Write-Host "$($RootModule.Repository)" -ForegroundColor Yellow

    Write-Host "Resolving dependencies..."
    # initiate recursive dependencies search
    $ModulesInstallationList = Get-ModuleDependenciesRecursively -ModuleName "$($RootModule.Name)" `
                                            -ReqVersion "$($RootModule.Version)" -RepositoryName "$($RootModule.Repository)" -Level 0


    # sort the modules in their installation sequence and get only unique items
    $ModulesInstallationList = $ModulesInstallationList | Sort-Object Priority -Descending | Select-Object Name, Version, Repository, Priority, InstallationStatus -Unique

    # get deployment phases
    $DeploymentPhases = $ModulesInstallationList.Priority | Get-Unique | Sort-Object -Descending

    Write-Host "Modules found: " -NoNewline
    Write-Host "$($ModulesInstallationList.count)" -ForegroundColor Yellow
    $ModulesInstallationList | Select-Object Name, Version, Repository, Priority | Format-Table -AutoSize

    # if we do the actual installation
    if (-not $ResolveOnly) {
        Write-Host "Processing..."
        foreach ($Phase in $DeploymentPhases) {
            Write-Host "Deployment phase: " -NoNewline; Write-Host "$Phase" -ForegroundColor Yellow

            $ModulesInstallationPhase = $ModulesInstallationList.where({$_.Priority -eq $Phase})
            # installation
            for ($i=0; $i -lt $ModulesInstallationPhase.count; $i++) {

                Write-Host "Installing Module: " -NoNewline
                Write-Host "$($ModulesInstallationPhase[$i].Name)" -ForegroundColor Yellow -NoNewline
                Write-Host "; Version:" -NoNewline
                Write-Host "$($ModulesInstallationPhase[$i].Version)" -ForegroundColor Yellow -NoNewline
                Write-Host "; Repository: " -NoNewline
                Write-Host "$($ModulesInstallationPhase[$i].Repository)" -ForegroundColor Yellow

                # check if the module exists
                $ModuleExists = Check-InstalledModule -AutomationAccountName "$AutomationAccountName" -ResourceGroupName "$ResourceGroupName" `
                                                -ModuleName "$($ModulesInstallationPhase[$i].Name)" -ModuleVersion "$($ModulesInstallationPhase[$i].Version)"
                if ($ModuleExists -is [bool]) {
                    if ($ModuleExists) {
                        Write-Host "Skipped, already installed"
                        $ModulesInstallationPhase[$i].InstallationStatus = "Succeeded"
                    }
                    else {
                        try {
                            $ModulesInstallationPhase[$i].InstallationStatus = (New-AzAutomationModule -AutomationAccountName "$AutomationAccountName" -ResourceGroupName "$ResourceGroupName" `
                                        -Name "$($ModulesInstallationPhase[$i].Name)" `
                                        -ContentLinkUri "https://www.powershellgallery.com/api/v2/package/$($ModulesInstallationPhase[$i].Name)/$($ModulesInstallationPhase[$i].Version)" `
                                        -ErrorAction Stop).ProvisioningState
                        }
                        catch {
                            # error handling
                            Write-Error $_.Exception
                        }
                        Write-Host "Installation initiated"
                    }
                }
                else {Exit}
            }

            # verification

            # set timeouts
            if ($ModulesInstallationPhase.count -gt 20) {$Timeout = 550}
            else {$Timeout = 300 + ($ModulesInstallationPhase.count * 10)}
            $Timer = 0
            $Step = 5
            while (($ModulesInstallationPhase.where({$_.InstallationStatus -ne 'Succeeded' -and $_.InstallationStatus -ne 'Failed'}).count -ne 0) `
            -and ($Timer -lt $Timeout)) {
                Write-Host '.' -NoNewline
                Start-Sleep -Seconds $Step
                $Timer += $Step
                for ($i=0; $i -lt $ModulesInstallationPhase.count; $i++) {
                    if ($ModulesInstallationPhase[$i].InstallationStatus -ne 'Succeeded' -and $ModulesInstallationPhase[$i].InstallationStatus -ne 'Failed') {
                    $ModulesInstallationPhase[$i].InstallationStatus = (Get-AzAutomationModule -AutomationAccountName "$AutomationAccountName" `
                                                                                            -ResourceGroupName "$ResourceGroupName" `
                                                                                            -Name "$($ModulesInstallationPhase[$i].Name)" `
                                                                                            -ErrorAction SilentlyContinue).ProvisioningState
                    }

                }
            }

            Write-Host ''

            # checking verification timeout
            if (($Timer -ge $Timeout)) {
                $Err = "Error processing phase $Phase, existed on timout: $Timeout"
                # output results
                $ModulesInstallationPhase | Sort-Object Name | Format-Table -AutoSize
                Write-Error $Err
                return $Err
            }
            else {
                # output results
                $ModulesInstallationPhase | Sort-Object Name | Format-Table -AutoSize

                Write-Host "Deployment phase: " -NoNewline; Write-Host "$Phase" -ForegroundColor Yellow -NoNewline
                Write-Host " is completed"
            }

        }
    }
}

<#
# you can use the code below to connect and run the script
$spId = ''
$spSecret = ''
$tenantId = ''
$spCreds = New-Object System.Management.Automation.PSCredential($spId,$(ConvertTo-SecureString $spSecret -AsPlainText -Force))
Connect-AzAccount -ServicePrincipal -Credential $spCreds -Tenant $tenantId
Install-AzAutomationModuleWithDependencies -AutomationAccountName '' -ResourceGroupName '' -ModuleName '' #-ResolveOnly
#>