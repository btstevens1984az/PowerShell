# Purpose: Profiles — Storage management and disk operations.
#profiles.ps1

# customisations for your PowerShell environment can be set within a PROFILE.
# You might define convenient Functions and Aliases for your session.
# As you saw in "scopes" these settings will only exist within a given "scope" or lifetime.
# So we will reload them each time we launch PowerShell.
# 

# this "profile" script will run when PowerShell starts. There are several profile files!
# cut/paste the below into the ISE and also into a PowerShell console and review.

$PROFILE
$PROFILE.CurrentUserCurrentHost
$PROFILE.CurrentUserAllHosts
$PROFILE.AllUsersCurrentHost
$PROFILE.AllUsersAllHosts

# you will see that the "AllHosts" locations only refer to profile.ps1
# whereas the "CurrentHost" will refer to PowerShellISE_profile.ps1 or PowerShell_profile.ps1
# In addition, you will recognise that the $HOME and $PSHOME global variables are leveraged
# to generate the appropriate paths.

 
# to create a profile, is as simple as creating any other file.
# it is simply a .PS1 (powershell script) file.
# 
if (-NOT (test-path $PROFILE)) {
  New-Item -Type file -Path $PROFILE -Force
}

# Note that to create an "AllUsers" profile, by referencing "$PROFILE.AllUsersCurrentHost",
# you MUST have PowerShell startd with Run As Administrator. 
#

# OK, so to edit your profile, let's just use NOTEPAD. (yes, it will prompt you if it doesn't exist)
 Notepad $PROFILE.CurrentUserAllHosts
# this is $Home\Documents\WindowsPowerShell\profile.ps1
# because we want to customise for either ISE or the plain console, I have selected 
# CurrentUserAllHosts. Yes, you can have different and multiple profiles being loaded.
 

# We shall add to our profile a simple ALIAS that shows the TIME.
# As an ALIAS is a straight lookup, to take parameters, we create a function
# and that function can then call the cmdlet with the appropriate parameters.
# So, we can set our alias to refer to that function.

function Get-Time {
  Get-Date -DisplayHint Time
}
New-Alias -Name TIME -Value Get-Time

# save your new profile and now whenever you load up PowerShell, that alias will be there for you.
# exit your PowerShell ISE or Console.
# launch PowerShell - this will load our new profile.
# give the command TIME  and... voila!

# OK, so now let's do an ISE specific profile
# I'd like to add a Menu item to let me launch Bing easily.
# if I am in the ISE, then I can just refer to
# $PROFILE.CurrentUserCurrentHost
# or if I was in the Console, I could be explicit and point at
# $HOME\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1
#
# So, let's jump into the ISE and launch Notepad
  Notepad $PROFILE.CurrentUserCurrentHost

# we can update the ISE environment through the object itself.
# so in our profile, we call the appropriate ADD method and 
# we are going to see a new item on the "Add-ons" Menu.

$psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add(
    "Bing It!", {
        Start "http://www.bing.com.au"
    },
    "Control+Alt+1"
)

# save that, relaunch ISE and... voila!

# by the way, you can go nuts in the ISE and alter anything and everything.
# to see just some of the things you can alter, look at the Options.
  $psISE.Options 

# try this
  $psISE.Options.ConsolePaneBackgroundColor="orange"

# it might be useful to know how to reset things!
  $psISE.Options.RestoreDefaults()

