# Purpose: Bulk Pre-Register MFA For Users Without Force MFA — Microsoft Azure cloud resource management.

<#
Date:		29/02/2020
Script:  	Bulk Pre-Register MFA For Users Without Enable MFA On The Account V4.0.ps1
Version: 	4.0
Description: Bulk Pre-registration for Azure Active Directory MFA to provide users more Seamless Single Sign on and smooth for MFA rolling out. 
Blog: 	    https://blog.3tallah.com
#>

#region Parameters

$UsersCSV = "<Users CSV File Path>"  # Example C:\Temp\UsersMFA.csv

#endregion Parameters
#-------------------------------------------------------
#-------------------------------------------------------
#region Queries

#-------------------------------------------------------
#If User Mobile is exist (AD users with specific AD attribute NOT null)
Get-AzureADUser | select UserPrincipalName, Mobile | Where-Object { $_.Mobile -ne $null }
#-------------------------------------------------------

#If User Mobile is exist (AD users with specific AD attribute is null)
Get-AzureADUser | select UserPrincipalName, Mobile | Where-Object { $_.Mobile -eq $null }
#-------------------------------------------------------

#Get StrongAuthenticationMethods
Get-AzureADUser | select UserPrincipalName, OtherMails, Mobile, TelephoneNumber
Get-AzureADUser | select DisplayName, UserPrincipalName, otherMails, Mobile, TelephoneNumber | Format-Table

#-------------------------------------------------------
#List users "Authentication contact info" attributes from AzureAD
Get-MsolUser -All | select DisplayName -ExpandProperty StrongAuthenticationUserDetails | ft DisplayName, PhoneNumber, Email | Out-File c:\temp\StrongAuthenticationUserDetails.csv
#List users "Authentication contact info where Phone number is Null" attributes from AzureAD 
Get-MsolUser -All | select DisplayName -ExpandProperty StrongAuthenticationUserDetails | Where-Object { $_.PhoneNumber -eq $null } | ft DisplayName, PhoneNumber, Email | Out-File c:\temp\StrongAuthenticationUserPhoneNumberNull.csv

#-------------------------------------------------------
#List users "Authentication contact info where Phone number is exist" attributes from AzureAD 
$StrongAuthenticationUserDetailsPhoneNumber = Get-MsolUser -All | select DisplayName -ExpandProperty StrongAuthenticationUserDetails | Where-Object { $_.PhoneNumber -ne $null } | ft DisplayName, PhoneNumber, Email
$StrongAuthenticationUserDetailsPhoneNumber | Out-File c:\temp\StrongAuthenticationUserPhoneNumber.csv
#-------------------------------------------------------

#-------------------------------------------------------
#List users "Strong Authentication Methods" attributes from AzureAD
Get-MsolUser -All | select DisplayName, UserPrincipalName -ExpandProperty StrongAuthenticationMethods | select UserPrincipalName, IsDefault, MethodType
#-------------------------------------------------------

#-----------------------------------------------------
# All users who have signed up for SSPR.
Connect-MsolService
(get-msoluser -All | Where { $_.StrongAuthenticationUserDetails -ne $null })
# All users who have not signed up for SSPR 
(get-msoluser -All | Where { $_.StrongAuthenticationUserDetails -eq $null })
#-----------------------------------------------------

#-------------------------------------------------------
#endregion Queries
#-------------------------------------------------------
#-------------------------------------------------------
#region Update Mobile Number for List of users
Import-CSV -Path $UsersCSV | ForEach-Object {
	Set-AzureADUser -ObjectId $_.UserPrincipalName -Mobile $_.Mobile -ErrorAction SilentlyContinue }
#endregion Update Mobile Number for List of users
#-------------------------------------------------------
#-------------------------------------------------------
#region Microsoft StrongAuthenticationMethod Parameters
$OneWaySMS = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
$OneWaySMS.IsDefault = $false
$OneWaySMS.MethodType = "OneWaySMS"

$TwoWayVoiceMobile = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
$TwoWayVoiceMobile.IsDefault = $true
$TwoWayVoiceMobile.MethodType = "TwoWayVoiceMobile"

$PhoneAppNotification = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
$PhoneAppNotification.IsDefault = $false
$PhoneAppNotification.MethodType = "PhoneAppNotification"

$PhoneAppOTP = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
$PhoneAppOTP.IsDefault = $false
$PhoneAppOTP.MethodType = "PhoneAppOTP"

$methods = @($OneWaySMS, $TwoWayVoiceMobile, $PhoneAppNotification, $PhoneAppOTP)
#endregion Strong Authentication Methods Parameters
#-------------------------------------------------------
#-------------------------------------------------------
#region Set Default Strong Authentication Methods for List of users
Import-CSV -Path $UsersCSV | Foreach-Object {
	Set-MsolUser -UserPrincipalName $_.UserPrincipalName -StrongAuthenticationMethods $methods } -ErrorAction SilentlyContinue

#endregion Set Default Strong Authentication Methods for List of users#-------------------------------------------------------
#-------------------------------------------------------
#region Pre-register authentication Info for List of users.
Import-CSV -Path $UsersCSV | ForEach-Object {
	Set-AzureADUser -ObjectId $_.UserPrincipalName -OtherMails $_.OtherMails -Mobile $_.Mobile -TelephoneNumber $_.TelephoneNumber -ErrorAction SilentlyContinue
}
#endregion Pre-register authentication Info for List of users.
#-------------------------------------------------------
#-------------------------------------------------------