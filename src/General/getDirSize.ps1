# Purpose: getDirSize — General-purpose PowerShell utilities.
# ---------------------------------------------------------

Param(

 [string]$path = "c:\windows",

 [int]$first = 5

)# end param

# *** Function Here ***



function Get-DirSize ($path){



  BEGIN {}

 

  PROCESS{

    $size = 0

    $folders = @()

  

    foreach ($file in (Get-ChildItem $path -Force -ea SilentlyContinue)) {

      if ($file.PSIsContainer) {

        $subfolders = @(Get-DirSize $file.FullName)

        $size += $subfolders[-1].Size

        $folders += $subfolders

      } else {

        $size += $file.Length

      }

    }

  

    $object = New-Object -TypeName PSObject

    $object | Add-Member -MemberType NoteProperty -Name Folder `

                         -Value (Get-Item $path).FullName

    $object | Add-Member -MemberType NoteProperty -Name Size -Value $size

    $folders += $object

    Write-Output $folders

  }

  

  END {}

} # end function Get-DirSize



Function Get-FormattedNumber($size)

{

  IF($size -ge 1GB)

   {

      "{0:n2}" -f  ($size / 1GB) + " GigaBytes"

   }

 ELSEIF($size -ge 1MB)

    {

      "{0:n2}" -f  ($size / 1MB) + " MegaBytes"

    }

 ELSE

    {

      "{0:n2}" -f  ($size / 1KB) + " KiloBytes"

    }

} #end function Get-FormattedNumber



 # *** Entry Point to Script ***

 

 if(-not(Test-Path -Path $path)) 

   { 

     Write-Host -ForegroundColor red "Unable to locate $path" 

     Help $MyInvocation.InvocationName -full

     exit 

   }

 Get-DirSize -path $path | 

 Sort-Object -Property size -Descending | 

 Select-Object -Property folder, size -First $first |

 Format-Table -Property Folder, 

  @{ Label="Size of Folder" ; Expression = {Get-FormattedNumber($_.size)} }

