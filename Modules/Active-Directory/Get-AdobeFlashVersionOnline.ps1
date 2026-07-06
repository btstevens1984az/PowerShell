# Purpose: Get-AdobeFlashVersionOnline — Active Directory user, group, and domain administration.
Function Get-AdobeFlashVersionOnline
{
    <#  
        .SYNOPSIS
            This function returns the current version of Flash from the Adobe website.
        .DESCRIPTION
            This function returns the current version of flash from the Adobe website using a combination of Inokve-WebRequest and working with the xml data returned from the website.
        .PARAMETER Uri
            The url of the webpage to gather the flash information from. Flash version information is stored in an xml file on adobe's website at this time.
        .EXAMPLE
            Get-FlashVersionOnline
            Returns the current version of Flash ActiveX and Flash Plugin.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$False, ValueFromPipelinebyPropertyName=$true)]
        [alias("Url","Website")]
        [string]$Uri = "http://fpdownload2.macromedia.com/pub/flashplayer/update/current/sau"   
    )
    Begin
    {}
    Process 
    {
            Write-Verbose "Connecting to flash website to find current Major version"
            [xml]$FlashMajorVersion = Invoke-WebRequest -Uri "$($Uri)/currentmajor.xml"
            $Version = $FlashMajorVersion.version.player.major
            [xml]$CurrentFlashVersion = Invoke-WebRequest -Uri "$($Uri)/$($Version)/xml/version.xml"
            $ActiveXVersion = $CurrentFlashVersion.version.ActiveX.major + '.' + $CurrentFlashVersion.version.ActiveX.minor + '.' + $CurrentFlashVersion.version.ActiveX.buildMajor + '.' + $CurrentFlashVersion.version.ActiveX.buildMinor
            $PluginVersion = $CurrentFlashVersion.version.Plugin.major + '.' + $CurrentFlashVersion.version.Plugin.minor + '.' + $CurrentFlashVersion.version.Plugin.buildMajor + '.' + $CurrentFlashVersion.version.Plugin.buildMinor
            New-Object -TypeName PSObject -Property @{FlashActiveXVersion=$ActiveXVersion
                                                        FlashPluginVersion=$PluginVersion
            }
    }
    End{}
}