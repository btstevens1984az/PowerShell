# Purpose: SetWallPaper — General-purpose PowerShell utilities.
Add-Type @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32;
namespace Wallpaper
{
   public enum Style : int
   {
       Fit, Tile, Center, Stretch, NoChange
   }
   public class Setter {
      public const int SetDesktopWallpaper = 20;
      public const int UpdateIniFile = 0x01;
      public const int SendWinIniChange = 0x02;
      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
         switch( style )
         {
            case Style.Fit :
                key.SetValue(@"WallpaperStyle", "0") ; 
               key.SetValue(@"TileWallpaper", "0") ;
                break;
            case Style.Stretch :
               key.SetValue(@"WallpaperStyle", "2") ; 
               key.SetValue(@"TileWallpaper", "0") ;
               break;
            case Style.Center :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "0") ; 
               break;
            case Style.Tile :
               key.SetValue(@"WallpaperStyle", "1") ; 
               key.SetValue(@"TileWallpaper", "1") ;
               break;
            case Style.NoChange :
               break;
         }
         key.Close();
      }
   }
}
"@



function New-Match($FullName, $resolution, $hres, $vres)
{
    $MatchedBG= New-Object PSObject
    $MatchedBG | Add-Member -type NoteProperty -Name FullName -Value $FullName
    $MatchedBG | Add-Member -type NoteProperty -Name RES -Value $Resolution
    $MatchedBG | Add-Member -type NoteProperty -Name HRES -Value $hres
    $MatchedBG | Add-Member -type NoteProperty -Name VRES -Value $vres
    return $MatchedBG
}

function FindWallpaper($Searchpath)
{
    $wmi = Get-WmiObject Win32_VideoController | where CurrentVerticalResolution -ne $null
    $iHres = $wmi.CurrentHorizontalResolution
    $iVres = $wmi.CurrentVerticalResolution

    foreach( $file in GCI $Searchpath )
    {
        #write-host $file.name
        if($file.Name -match "$($iHres)x$($iVRes)")
        {
            write-host "match found in $($file.Name)"
            return $file.FullName
        }
    }

    #no match found yet

    #get the aspect ratio
    $phyRatio = [MATH]::Round($iHres / $iVres,2 )

    Write-Host "Monitor Aspect Ratio: $phyRatio"

    $match1 = ""
    $match2 = ""
    $defBackground = ""

    foreach ($file in GCI $Searchpath)
    {
        if($file.name -match "([0-9]*)x([0-9]*)")
        {
            
            $discard = $($file.name) -match '([0-9]*)x([0-9]*)'
            $sWallresolution = $matches[0]
            #write-host "$($file.Name) has a resolution in filename: $sWallresolution"
            #get the aspect ratio of this file
            

            
            $iWallH = [int]$sWallresolution.Substring(0, $sWallresolution.IndexOf('x'))
            $iWallV = [int]$sWallresolution.Substring($sWallresolution.IndexOf('x') + 1)
            $fWallAspect = [MATH]::Round($iwallH/$iWallV, 2)

            Write-Host "Wallpaper H: $iWallH, V: $iWallV, A: $FWallAspect"


            #note match 1 is preferred match if set
            if($phyRatio -eq $fWallAspect)
            {
                write-host "$($file.Name) has a matching aspect ratio: $fWallAspect"
                $newMatch = New-Match -FullName $file.FullName -resolution $sWallresolution -hres $iWallH -vres $iWallV
                #found match
                if($match1 -eq "")
                {
                    if($newMatch.vRes -gt $iVres)
                    {
                        write-host "match2 set" 
                        $match2 = $newMatch
                    }
                    else
                    {
                        write-host "$match1 set"
                        $match1 = $newMatch
                    }
                }
                elseif($match1.vRES -le $newMatch.vres -and $newMatch.VRES -le $iVres)
                {
                    $match1 = $newMatch
                }
                

            }
            elseif( ($iWallV -eq $iVres) -and ($iwallh -le $iHres) ) 
            #try to find a wallpaper that may be close in resolution in case no matches are found
            {
                $defBackground = new-match -FullName $file.FullName -resolution $sWallresolution -hres $iWallH -vres $iWallV
            }

        }
        elseif($file.name -match "default")
        {
            if($defBackground -eq "")
            {
                $defBackground = new-match -FullName $file.FullName -resolution $sWallresolution -hres $iWallH -vres $iWallV
            }
        }

    }
    

    write-host "Match1: $($match1.FullName)"
    write-host "Match2: $($match2.FullName)"
    write-host "Default: $($DefBackground.FullName)"


    if($match1 -ne "")
    {
        return $match1.FullName
    }
    if($match2 -ne "")
    {
        return $match2.FullName
    }
    else
    {
        return $defBackground.FullName
    }
}

FindWallPaper("C:\Windows\Web\Wallpaper\HHK")


[Wallpaper.Setter]::SetWallpaper( $( FindWallPaper("C:\Windows\Web\Wallpaper\HHK")), 0  )