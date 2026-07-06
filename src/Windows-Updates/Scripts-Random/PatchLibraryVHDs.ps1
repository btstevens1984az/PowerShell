# Purpose: PatchLibraryVHDs — Windows Update and patch management.
#TODO
#Create filtering criteria to only attempt to apply patches that match the OS on the vhd
#Consider companion WSUS cleanup script
#
 function Start-VMOfflinePatching   
{ 
[CmdletBinding( 
                  SupportsShouldProcess=$true, 
                  ConfirmImpact='High')] 
  param(  
        [string]$VmmServerName = "Scvmm2012.kaylos.lab",
        [string]$WSUS = "31.39.1.252",
        [string]$VHDmountPath = "c:\ovp",
        [string]$Updates = (Get-WsusUpdate -Approval Approved -UpdateServer $WSUS)
 )
# Import VMM module.  
Import-Module virtualmachinemanager   
          
# Connect to VMM server.  
$vmmServer = Get-SCVMMServer -ComputerName $VmmServerName   


#Get all Virtual HardDisks stored in the library, check if virtualization platform is Hyper-V, Check for Operating System  
$VHDList = Get-SCVirtualHardDisk | where-object {$_.VirtualizationPlatform -eq "HyperV"}|where-object {$_.OperatingSystem -ne "none"}   


#Get all available Update at 31.39.1.252  
$Updatelistcab = get-childitem -Path "c" -include *.cab -recurse -File
$updates = Get-WsusUpdate -Approval Approved -UpdateServer $WSUS   
#$Updatelistmsu = get-childitem -Path "\\$WSUS\wsuscontent" -include *.msu –recurse -File   


#Mount and Patch each Virtual HardDisk, check Update if applicable before applying  
$counter = 0
Foreach ($VHD in $VHDList)   
{
    $counter += 1
    [int]$VHDpercentProgress = ($counter/$VHDList.Count) * 100
    Write-Progress -Activity "Patching VHD $counter of $($VHDlist.count)" -CurrentOperation "Applying patches to $($vhd.sharepath)" -PercentComplete $VHDpercentProgress -Id 0
    if ($PSCmdlet.ShouldProcess($vhd.sharepath,"Patching VHD") )
    {
    try{  
    $VHDPath=$VHD.SharePath  
    $MountedImage = Mount-WindowsImage -ImagePath "$VHDPath" -Path $vhdMountPath -Index 1   
        $i=0
        Foreach ($Updatecab in $Updatelistcab)   
        {
            $i += 1
            [int]$percentProgress = ($i/$Updatelistcab.Count) * 100
            Write-Progress -Activity "Applying patches to $($VHDPath)" -PercentComplete $percentProgress -Id 1 -CurrentOperation "Applying $($Updatecab.FullName). Update $I of $($Updatelistcab.Count) "
        try{  
         $UpdateReady=get-windowspackage -PackagePath $Updatecab.FullName -Path $vhdMountPath -Verbose
         If ($UpdateReady.PackageState -eq "installed")   
           {Write-Output $UpdateReady.PackageName "is already installed"}   
            elseif ($updateReady.Applicable -eq "true") 
             {
                   Try{
                         
                         Add-WindowsPackage -PackagePath $Updatecab.FullName -Path $vhdMountPath -Verbose
                       }
                    Catch
                    {
                        Write-Verbose "Error encountered on Add-windowsPackage"
                        Write-verbose "$($_.exception.gettype().fullname)"
                        Write-verbose "$($_.exception.message)"

                    }
            } 
           }
           catch
           {
                Write-Verbose "Error on get-windowspackage"
                Write-verbose "$($_.exception.gettype().fullname)"
                Write-verbose "$($_.exception.message)"
            
           }
        }   
      #Foreach ($Updatemsu in $Updatelistmsu)    
      #{   
      #   add-windowspackage -PackagePath $Updatemsu.Directory -Path $vhdMountPath   
      #}   
           
     
     catch
     {
        $_
     }   
    }
    catch
    { 

        $_
    }
    finally
    {
            Write-Verbose "Attempting to save and dismount $($MountedImage.path). This process can take a few minutes."
            $MountedImage | Dismount-WindowsImage  -save  -Verbose

    }

}    
  
}   
}

Function Convert-WSUSHTTPPathtoSMB
{
    param ([string]$fileuri="http://31.39.1.252:8530/Content/36/721D140CB51C2120C7F016CEC18B660FFD3E9B36.cab",
            [string]$wsusContentPath = "\\31.39.1.252\wsuscontent")
 
        "$wsusContentPath\" +($fileuri -split "content/")[1] -replace "/","\"
   
}

#$WSUS = Get-WsusServer -Name 31.39.1.252 -PortNumber 8530
$updates = Get-WsusUpdate -Approval Approved -UpdateServer $WSUS -ErrorAction stop 

$cabUpdates =  $updates | Foreach-object {
     $cab = $_.update.GetInstallableItems().files | Where-Object {$_.name -notlike "*express*" -and $_.name -like "*.cab"} 
     if ($cab.count -gt 1)
     {
        Write-Error "more than one cab"
        $cab
     
     }
     Else
     {
        If ($cab)
       {$cabPath = Convert-WSUSHTTPPathtoSMB -fileuri $cab.fileuri -wsusContentPath "\\31.39.1.252\wsuscontent"
     $_ |  Add-Member -MemberType NoteProperty -Name WSUSCabPath -Value $cabPath -PassThru}
     #else
     #{
     #   $_ |  Add-Member -MemberType NoteProperty -Name WSUSCabPath -Value $null
     #}

     }
}


Start-VMOfflinePatching -Updates $updates -Confirm:$false -Verbose