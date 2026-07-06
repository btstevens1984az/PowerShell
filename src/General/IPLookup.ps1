# Purpose: IPLookup — General-purpose PowerShell utilities.
﻿#Function to lookup ip information using WMI and will prompt for a computer name if not specified.
Function IPLookup
{
	param($computerName = (Read-host "please enter a computer name"))
	gwmi Win32_networkadapterconfiguration -Filter "ipenabled=true" -ComputerName $computerName | FL *
}
