#See alternative example in functions folder: cmdWrapper.ps1
Function New-MyUserGroupForm
{
<#
.Synopsis
   Example using Show-command to create an input form
.DESCRIPTION
   Example using Show-command to create an input form
.EXAMPLE
   Show-Command New-MyUserGroupForm
.PARAMETER Department
    Select a department for the new user or group object
   #>
    [cmdletbinding()]
    param(
    [parameter(Mandatory,
        ParameterSetName='New User')]
    [string]$Firstname,
    
    [parameter(Mandatory,
        ParameterSetName='New User')]
    [string]$LastName,

    [parameter(
        Mandatory,
        ParameterSetName='New User')]
    [parameter(
        Mandatory,
        ParameterSetName='New Group')]
    [validateSet("Contoso","Fourth Coffee","NwTraders")]
    [string]$DomainName,

    [parameter(
        Mandatory,
        HelpMessage="Enter a department name for the new user",
        ParameterSetName='New User')]
    [parameter(
        Mandatory=$false,
        HelpMessage="Enter a department name for the new group",
        ParameterSetName='New Group')]
    [validateSet("IT","HR","Finance")]
    [string]$Department,

    [parameter(
        Mandatory,
        ParameterSetName='New Group',
        Position =0)]
    [string]$GroupName,

    [validateSet("Local","Global","Universal")]
    [parameter(
        Mandatory,
        ParameterSetName='New Group')]
    [string]$GroupType,

    [parameter(
        ParameterSetName='New Group')]
        [switch]$SecurityGroup
    )

    $PSBoundParameters


}

Show-Command new-MyUserGroupForm 
