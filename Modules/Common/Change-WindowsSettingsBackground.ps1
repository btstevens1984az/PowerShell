Function Change-WindowsSettingsBackground {
Function Set-DarkTheme {
<#
.CREATED BY:
    Matthew A. Kerfoot

.CREATED ON:
    8\2\2015

.SYNOPSIS  
   Creates two registry keys that disable the "light theme" changing it to the dark theme!
   (which is way cool in my opinion)
   Automating the world one line of code at a time.
 
.DESCRIPTION
   There is not too much to it, this simply creates two new registry keys, one in HKEY_LOCAL_MACHINE directory `
   and one in HKEY_CURRENT_USER directory. Both of the registry keys are called "AppsUseLightTheme" and get assigned `
   a dword value of 0 which in turn after logging out and back in the light theme will be turned off leaving you with `
   the cool hidden black theme!

.EXAMPLE
   PS C:\> Set-DarkTheme
   After Running the script you simply have to type Set-DarkTheme and hit enter and the changes will be made, `
   this shouldn't take more than a srecound to complete. there is a prompt at the end however asking you to hit `
   enter to log out, this is for the registry changes to take effect

   Just though I'd turn this into a script quick so others can use it and share it. Spread the word y'all!
 
    
    
    Author/Copyright    : © Matthew Kerfoot - All Rights Reserved -    Automating the world one line of code at a time.
    
    Email/Blog/Twitter  : mkkerfoot@gmail.com  www.TheOvernightAdmin.com  @mkkerfoot
    
    Disclaimer          : THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
                          OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
                          While these scripts are tested and working in my environment, it is recommended 
                          that you test these scripts in a test environment before using in your production environment
                          Matthew Kerfoot further disclaims all implied warranties including, without limitation, any 
                          implied warranties of merchantability or of fitness for a particular purpose. The entire risk 
                          arising out of the use or performance of this script and documentation remains with you. 
                          In no event shall Matthew Kerfoot, its authors, or anyone else involved in the creation, production, 
                          or delivery of this script/tool be liable for any damages whatsoever (including, without limitation, 
                          damages for loss of business profits, business interruption, loss of business information, or other 
                          pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, 
                          even if Matthew Kerfoot has been advised of the possibility of such damages
    
    
    Assumptions         : ExecutionPolicy of AllSigned (recommended), RemoteSigned or Unrestricted (not recommended)
    
    Limitations         : Strickly designed for the full general public release of Windows 10 on 7/29/2015.
    
    Ideas/Wish list     : Make a Set-LightTheme so people can revert the changes. **DONE**                              
    
    Known issues        : None

    Authors notes       : Just though I'd turn this into a script quick so others can use it and share it. Spread the word y'all!
 
#>
[CmdletBinding()]
          Param ( [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true, Position=0)]
                   $DwordName = "AppsUseLightTheme",
                   $Value = "0",
                   $VerbosePreference = "Continue"
          )
    
Begin{ 
}
Process{ 

    # creates HKLM key
    # New-ItemProperty "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name $DwordName -Value $Value -PropertyType "DWord"
    # creates HKCU key
    New-ItemProperty "HKCU:\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name $DwordName -Value $Value -PropertyType "DWord"

}

End { Write-Verbose "Please Press Enter to sign out of windows, once logged back in the changes will be in place!" ; Pause ; shutdown /l }

}
Set-DarkTheme

Function Set-LightTheme {
<#
.CREATED BY:
    Matthew A. Kerfoot

.CREATED ON:
    8\2\2015

.SYNOPSIS  
   Creates two registry keys that enable the "light theme"!
   Automating the world one line of code at a time.
 
.DESCRIPTION
   There is not too much to it, this simply creates two new registry keys, one in HKEY_LOCAL_MACHINE directory `
   and one in HKEY_CURRENT_USER directory. Both of the registry keys are called "AppsUseLightTheme" and get assigned `
   a dword value of 1 which in turn after logging out and back in the light theme will be turned on!

.EXAMPLE
   PS C:\> Set-LightTheme
   After Running the script you simply have to type Set-LightTheme and hit enter and the changes will be made, `
   this shouldn't take more than a srecound to complete. there is a prompt at the end however asking you to hit `
   enter to log out, this is for the registry changes to take effect

   Just though I'd turn this into a script quick so others can use it and share it. Spread the word y'all!
 
    
    
    Author/Copyright    : © Matthew Kerfoot - All Rights Reserved -    Automating the world one line of code at a time.
    
    Email/Blog/Twitter  : mkkerfoot@gmail.com  www.TheOvernightAdmin.com  @mkkerfoot
    
    Disclaimer          : THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
                          OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
                          While these scripts are tested and working in my environment, it is recommended 
                          that you test these scripts in a test environment before using in your production environment
                          Matthew Kerfoot further disclaims all implied warranties including, without limitation, any 
                          implied warranties of merchantability or of fitness for a particular purpose. The entire risk 
                          arising out of the use or performance of this script and documentation remains with you. 
                          In no event shall Matthew Kerfoot, its authors, or anyone else involved in the creation, production, 
                          or delivery of this script/tool be liable for any damages whatsoever (including, without limitation, 
                          damages for loss of business profits, business interruption, loss of business information, or other 
                          pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, 
                          even if Matthew Kerfoot has been advised of the possibility of such damages
    
    
    Assumptions         : ExecutionPolicy of AllSigned (recommended), RemoteSigned or Unrestricted (not recommended)
    
    Limitations         : Strickly designed for the full general public release of Windows 10 on 7/29/2015.
    
    Ideas/Wish list     : Make a Set-LightTheme so people can revert the changes. **DONE**         
    
    Known issues        : None

    Authors notes       : Just though I'd turn this into a script quick so others can use it and share it. Spread the word y'all!
 
#>
[CmdletBinding()]
          Param ( [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true, Position=0)]
                   $DwordName = "AppsUseLightTheme",
                   $Value = "1",
                   $VerbosePreference = "Continue"
          )
    
Begin{ 
}
Process{ 

    # creates HKLM key
    # New-ItemProperty "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name $DwordName -Value $Value -PropertyType "DWord"
    # creates HKCU key
    New-ItemProperty "HKCU:\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name $DwordName -Value $Value -PropertyType "DWord"

}

End { Write-Verbose "Please Press Enter to sign out of windows, once logged back in the changes will be in place!" ; Pause ; shutdown /l }

}
}