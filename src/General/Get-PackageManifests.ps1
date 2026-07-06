#requires -version 3
#requires -module powershell-yaml

<#
.SYNOPSIS
  Get manifests for a WinGet package.
.DESCRIPTION
  Searches the GitHub API for WinGet manifests and returns manifests for a single package.
  Version:        1.0
  Creation Date:  15-11-2021
  Purpose/Change: Initial script development.
#>

#region begin boostrap
############### Bootstrap - Start ###############

# Clear screen.
Clear-Host;

############### Bootstrap - End ###############
#endregion

#region begin input
############### Input - Start ###############

# Search criteria.
$AppId = "Git.Git";
$AppVersion = "2.34.0"; # specify version to get specific package, but not required.

# Download folder.
$PackageOutput = ("{0}\InstallerPackages" -f [Environment]::GetFolderPath("Desktop"));

# GitHub API.
$GitHubApi = @{
     Master = "https://api.github.com/repos/microsoft/winget-pkgs/git/trees/master";
     Manifest = "https://api.github.com/repos/microsoft/winget-pkgs/git/trees/{0}?recursive=1";
     RawContent = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/";
};

############### Input - End ###############
#endregion

#region begin functions
############### Functions - Start ###############

# Write to the console.
Function Write-Log
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$false)][string]$Text
    )
 
    # If the input is empty.
    If([string]::IsNullOrEmpty($Text))
    {
        $Text = " ";
    }
    Else
    {
        # Write to the console.
        Write-Host("[" + (Get-Date).ToString("dd/MM-yyyy HH:mm:ss") + "]: " + $Text);
    }
}

# Get package manifests.
Function Get-Manifests
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$true)][string]$Master,
        [Parameter(Mandatory=$true)][string]$Manifest
    )

    # Get SHA.
    $Sha = (Invoke-RestMethod -Method Get -Uri $Master -ContentType "application/json").tree | Where-Object {$_.path -eq "manifests"} | Select-Object -ExpandProperty sha;

    # Get manifests.
    $Manifests = (Invoke-RestMethod -Method Get -Uri ($Manifest -f $Sha) -ContentType "application/json").tree;

    # Return manifests.
    Return ($Manifests | Where-Object {$_.type -eq "blob"});
}

# Search after a specific package manifest.
Function Search-PackageManifest
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$true)]$Manifests,
        [Parameter(Mandatory=$true)][string]$PackageId,
        [Parameter(Mandatory=$false)][string]$PackageVersion
    )
    
    # If version is not specified.
    If([string]::IsNullOrEmpty($PackageVersion))
    {
        # Write to log.
        Write-Log ("Searching after package id '{0}'" -f $PackageId);

        # Get package.
        Return $Manifests | Where-Object {
            $_.path -like ("*/{0}.yaml*" -f $PackageId) -or
            $_.path -like ("*/{0}.installer.yaml" -f $PackageId) -or
            $_.path -like ("*/{0}.locale.*.yaml" -f $PackageId)
        };
    }
    # If version is specified.
    Else
    {
        # Write to log.
        Write-Log ("Searching after package id '{0}' with specific version '{1}'" -f $PackageId, $PackageVersion);

        # Get package.
        Return $Manifests | Where-Object {
            ($_.path -like ("*/{0}.yaml*" -f $PackageId) -and $_.path -like ("*/{0}/*" -f $PackageVersion)) -or
            ($_.path -like ("*/{0}.installer.yaml" -f $PackageId) -and $_.path -like ("*/{0}/*" -f $PackageVersion)) -or
            ($_.path -like ("*/{0}.locale.*.yaml" -f $PackageId) -and $_.path -like ("*/{0}/*" -f $PackageVersion))
        };
    }
}

# Get package installer manifest.
Function Get-ManifestYaml
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$true)][string]$Uri
    )

    # Download YAML.
    $Yaml = Invoke-RestMethod -Method Get -Uri $Uri;

    # Return YAML (remove no-break space).
    Return ($Yaml -replace [char]0xfeff);
}

# Get package manifests(s).
Function Get-PackageManifests
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$true)]$Manifests,
        [Parameter(Mandatory=$true)][string]$PackageId,
        [Parameter(Mandatory=$false)][string]$PackageVersion,
        [Parameter(Mandatory=$true)]$GitHubApi
    )

    # Search after a specific manifest.
    $SearchResults = Search-PackageManifest -Manifests $Manifests -PackageId $PackageId -PackageVersion $PackageVersion;
    
    # Object array.
    $Results = @();

    # Foreach manifest.
    Foreach($SearchResult in $SearchResults)
    {
        # Only get installer manifests YAML.
        If($SearchResult)
        {
            # Construct YAML URI.
            $YamlUri = ("{0}{1}" -f $GitHubApi.RawContent, ($SearchResult).path);

            # Write to log.
            Write-Log ("Fetching YAML from '{0}'" -f $YamlUri);

            # Get manifest YAML.
            $ManifestYaml = Get-ManifestYaml -Uri $YamlUri;

            # Convert YAML to object.
            $ManifestObject = $ManifestYaml | ConvertFrom-Yaml | ConvertTo-Json | ConvertFrom-Json;

            # If it is a installer manifest.
            If($SearchResult | Where-Object {$_.path -like "*installer.yaml"})
            {
                # Add to results.
                $Results += [PSCustomObject]@{
                    Manifest = "Installer";
                    Identifier = $ManifestObject.PackageIdentifier;
                    Version = $ManifestObject.PackageVersion;
                    Data = $ManifestObject;
                };
            }
            # Else if it's a locale.
            ElseIf($SearchResult | Where-Object {$_.path -like "*locale.*.yaml"})
            {
                # Add to results.
                $Results += [PSCustomObject]@{
                    Manifest = "Locale";
                    Identifier = $ManifestObject.PackageIdentifier;
                    Version = $ManifestObject.PackageVersion;
                    Data = @(
                        [PSCustomObject]@{
                            ("{0}" -f $ManifestObject.PackageLocale) = $ManifestObject;
                        };
                    );
                };
                 
            }
            # Else if it's a singleton.
            ElseIf($SearchResult | Where-Object {$_.path -like ("*{0}.yaml" -f $PackageId)})
            {
                # Add to results.
                $Results += [PSCustomObject]@{
                    Manifest = "Singleton";
                    Identifier = $ManifestObject.PackageIdentifier;
                    Version = $ManifestObject.PackageVersion;
                    Data = $ManifestObject;
                };
                 
            }

            # Add to object array.
            $Results += $Result;
        }
    }

    # Return results.
    Return $Results;
}

# Download the package installer.
Function Download-PackageInstaller
{
    [cmdletbinding()]	
		
    Param
    (
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$OutputFolder
    )

    # Get filename.
    $FileName = ($Uri -split "/")[-1];

    # Full output path.
    $Output = ($OutputFolder + "\" + $FileName);

    # Write to log.
    Write-Log ("Creating folder '{0}'" -f $OutputFolder);

    # Create folder.
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null;

    # Check if the file already exist in output folder.
    If(Test-Path -Path $Output)
    {
        # Write to log.
        Write-Log ("File already exist at '{0}', will now delete" -f $Output);
        
        # Remove file prior to downloading.
        Remove-Item -Path $Output -Force -Confirm:$false;
    }

    # Write to log.
    Write-Log ("Downloading file from '{0}' to '{1}'" -f $Uri, $Output);

    # Download binary file.
    Invoke-WebRequest -Uri $Uri -OutFile $Output;
}

############### Functions - End ###############
#endregion

#region begin main
############### Main - Start ###############

# Write to log.
Write-Log ("Fetching package manifests");

# Get all installer manifests.
$Manifests = Get-Manifests -Master $GitHubApi.Master -Manifest $GitHubApi.Manifest;

# Get package manifests.
$PackageManifests = Get-PackageManifests -Manifests $Manifests -PackageId $AppId -PackageVersion $AppVersion -GitHubApi $GitHubApi;

############### Main - End ###############
#endregion

#region begin finalize
############### Finalize - Start ###############

############### Finalize - End ###############
#endregion