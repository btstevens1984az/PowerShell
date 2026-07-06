# Purpose: New-FIMOU — General-purpose PowerShell utilities.
function New-FIMOU
{
    <#
		.SYNOPSIS
			Creates OUs for use in a FIM install.
		.DESCRIPTION
			Creates OUs for use in a FIM install but can be used for generally for OU creation.
		.PARAMETER  Name
			The name of the new OU.      
        .PARAMETER  ParentDN
			The DistinguishedName of the parent container for the OU		
        .EXAMPLE
			PS C:\> New-FIMOU -name Testing -parentDN "Dc=contoso,Dc=Com"
			Creates a new OU named testing at the root of the contoso.com domain.
		.EXAMPLE
			PS C:\> Import-Csv | New-FIMOU
			Creates OUs from CSV input. Assumes CSV has a name column and a parentDN column.
		.EXAMPLE
			PS C:\> $computers = Get-Content .\computers.txt
			PS C:\>	$computers | Get-OS
			These commands retrieve operating system information from the list of computer names in computers.txt.
		.EXAMPLE
			PS C:\> $computers = Get-ADcomputer -filter * | select-object -expandproperty name
			PS C:\>	$computers | Get-OS
			These commands retrieve operating system information from all computers in the current domain that are available.
		.OUTPUTS
			Microsoft.ActiveDirectory.Management.ADOrganizationalUnit
    #>

    #Requires -modules ActiveDirectory
    [cmdletbinding(
                    SupportsShouldProcess=$true,
                    ConfirmImpact='Medium')]
    [OutputType([Microsoft.ActiveDirectory.Management.ADOrganizationalUnit])]
    param(
    #Name of the new OU
    [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$name,
    #Parent Distinguished Name of where to create the new OU.
    [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [validateScript({activedirectory\Get-ADObject -Identity $_ })]
    [string]$ParentDN)

    Process
    {
        if($PSCmdlet.ShouldProcess("ou=$name,$parentDN", "Creating OU"))
        {
            try
            {
            #passthru added so new OU object is returned
            New-ADOrganizationalUnit -Name $name -Path $ParentDN -ErrorAction stop -PassThru
            }
            catch [Microsoft.ActiveDirectory.Management.ADException]
            {
                if ($_.exception.Message -like "An attempt was made to add an object to the directory with a name that is already in use*")
                {
                    Write-Verbose "ou=$name,$parentDN already exists, skipping ou creation."
                    #will will throw terminating error if OU cannot be found as this would be unexpected at this point.
                    Get-ADOrganizationalUnit -Identity "ou=$name,$parentDN" -ErrorAction Stop
                }
            }
            catch
            {
                "Unexpected Error, throwing exception"
                throw $_
            }
        } #End if
    }#End Process
}


