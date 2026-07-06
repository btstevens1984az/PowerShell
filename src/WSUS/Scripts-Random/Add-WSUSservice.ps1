# Purpose: Add-WSUSservice — Windows Server Update Services administration.

# run whatif to see results
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools �WhatIf

# Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
Install-WindowsFeature -Name UpdateServices, UpdateServices-WidDB, UpdateServices-Services, UpdateServices-RSAT, UpdateServices-API, UpdateServices-UI
#create directory for 31.39.1.252
# New-Item -Path W: -Name 31.39.1.252 -ItemType Directory
.\wsusutil.exe postinstall CONTENT_DIR=W:\31.39.1.252
