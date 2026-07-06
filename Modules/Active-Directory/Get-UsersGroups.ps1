# Purpose: Get-UsersGroups — Active Directory user, group, and domain administration.
function Get-UsersGroups {
	
	<#
	.SYNOPSIS
	Outputs a formatted list of the groups the specified user(s) belong to.
	.DESCRIPTION
	This command outputs a human readable list of the groups the specified user(s)
	belong to.

	.PARAMETER identity
	One or more user account names to get the AD group membership for.  This script
	will accept a SAM account name
	.PARAMETER noheader
	By default a header is added to the output to make it easier to see which users'
	groups are being displayed.  This is especially useful when more than one user
	is being displayed. This flag will omit that header.

	.EXAMPLE
	Format-UserGroups -identity dneal
	Display the groups dneal is a member of to the console.
	.EXAMPLE
	Format-UserGroups -identity dneal, jsmith
	Usage to display more than one user with a single call
	.EXAMPLE
	Format-UserGroups -identity dneal | Out-File k:\userinfo\dneal-groups.txt
	Example using Out-File to save the information to a file
	.EXAMPLE
	Get-ADUser jsmith | Format-UserGroups
	Example usage for pipeline input
	.EXAMPLE
	Format-UserGroups -identity dneal -noheader
	Display the groups dneal is a member of without the header denoting the user
	account name.
	#>
	

	[cmdletbinding()]
	Param(
		[Parameter(ValueFromPipeline = $True, 
				   Mandatory = $True, 
				   Position = 0)]
		[string[]]$identity,
		[switch]$noheader
	)
	
	
	BEGIN {
		write-verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
		
		write-verbose "[BEGIN  ] Test to see if the Active Directory module is already loaded in the current session."
		if (Get-Module -Name "ActiveDirectory") {
			write-verbose "[BEGIN  ] The Active Directory module was already loaded in the current session."
		} else {
			write-verbose "[BEGIN  ] The Active Directory module is not currently loaded, attempting to load it now."
			Import-Module ActiveDirectory -verbose:$false -erroraction stop
		}
	} # BEGIN
	
	
    PROCESS {
		foreach($user in $identity){
			
			write-verbose "[PROCESS] Querying AD for the user account that matches $user"
			try {
				#Right now this will only work if supplied with a SAMaccount name
				$userAccount = get-aduser $user -properties memberof
				write-verbose "[PROCESS] Active Directory account found: $userAccount"
			} catch {
				write-warning "A user account for $user cannot be found.`n"
				continue
			}
			
			write-verbose "[PROCESS] Format the groups the user belongs to so they are easily readable."
			$groups = $userAccount.memberof | ForEach-Object {$_ -replace '^.*CN=|,.*$'}

			If ($PSBoundParameters.ContainsKey('noheader')) {
				write-output $groups
			} else {
				write-verbose "[PROCESS] Add a header to denote the user and output the group membership."
				$header = "`n$($userAccount.name) `($($userAccount.SAMaccountname)`) is a member of:`n"
				write-output $header $groups
			}
				
		}
	} # PROCESS
	
	
	END {
		write-verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
	} # END
}