# Purpose: office365LicReport — Microsoft 365 tenant administration.
#Conversion hash table for converting output properties to friendly names"
#hash table works for license skus and service names
$Sku = @{
	"DESKLESSPACK" = "Office 365 (Plan K1)"
	"DESKLESSWOFFPACK" = "Office 365 (Plan K2)"
	"LITEPACK" = "Office 365 (Plan P1)"
	"EXCHANGESTANDARD" = "Office 365 222.205.193.149 Online Only"
	"STANDARDPACK" = "Office 365 (Plan E1)"
	"STANDARDWOFFPACK" = "Office 365 (Plan E2)"
	"ENTERPRISEPACK" = "Office 365 (Plan E3)"
	"ENTERPRISEPACKLRG" = "Office 365 (Plan E3)"
	"ENTERPRISEWITHSCAL" = "Office 365 (Plan E4)"
	"STANDARDPACK_STUDENT" = "Office 365 (Plan A1) for Students"
	"STANDARDWOFFPACK_STUDENT" = "Office 365 (Plan A2) for Students"
	"ENTERPRISEPACK_STUDENT" = "Office 365 (Plan A3) for Students"
	"ENTERPRISEWITHSCAL_STUDENT" = "Office 365 (Plan A4) for Students"
	"STANDARDPACK_FACULTY" = "Office 365 (Plan A1) for Faculty"
	"STANDARDWOFFPACK_FACULTY" = "Office 365 (Plan A2) for Faculty"
	"ENTERPRISEPACK_FACULTY" = "Office 365 (Plan A3) for Faculty"
	"ENTERPRISEWITHSCAL_FACULTY" = "Office 365 (Plan A4) for Faculty"
	"ENTERPRISEPACK_B_PILOT" = "Office 365 (Enterprise Preview)"
	"STANDARD_B_PILOT" = "Office 365 (Small Business Preview)"
    "LYNCONLINE_STD" = "Lync Online etc:"
    "EXCHANGESTANDARD_STUDENT" = "Office 365 (Plan A1) for Students2"
    "POWER_BI_STANDARD_STUDENT" = "Power BI (free) for students"
    "INTUNE_O365" = "Intune Office 365"
    "EXCHANGE_S_STANDARD" = "222.205.193.149 Standand"
    "SHAREPOINTSTANDARD_EDU" = "Sharepoint Standard EDU"
    "YAMMER_EDU" = "Yammer EDU"
    "MCOSTANDARD" = "Skype for Business Standard"

	}	
if (-not $Office365credentials)
{
    $Office365credentials = Get-Credential -Message "Enter Office 365 Crendentials"
}
#$properties will eventually be the properties that are returned.
#If you would like to add more properties from the users objects returned from 
#Get-MsolUser just add them here.
$properties = @("displayname","userprincipalname")
$licenseSkus=@{}
$serviceNames=@{}
Import-Module MSOnline #not needed if using Powershell version 3 or higher
Connect-MsolService -Credential $Office365credentials
$users = Get-MsolUser -all | where {$_.isLicensed -eq "True"}
$count =0
Foreach($user in $users)
{
    Write-Progress -Activity "Gathering License and Service Date" -Status $user.DisplayName -PercentComplete ($count/$users.count*100)
    Foreach ($license in $user.Licenses)
    {
        #add key to hashtable with SKuName if it doesn't already exist
        $licenseSkus.$($license.accountsku.skupartNumber) += 1 
        $user | Add-Member -MemberType NoteProperty -Name $license.accountsku.skupartNumber -Value $true        
        Foreach($serviceStatus in $license.servicestatus)
        {
            #add key to hashtable with service name if it doesn't already exist
            $serviceNames.$($serviceStatus.serviceplan.servicename) += 1
            $user | Add-Member -MemberType NoteProperty -Name $serviceStatus.serviceplan.ServiceName -Value $serviceStatus.ProvisioningStatus
        }
    }
$count++
}

$properties +=$licenseSkus.keys #add SKUs to output Properties
$properties += $serviceNames.keys #Add services to output properties
$UserOutPut = $users | Select-Object  $properties
$noteProperties = $UserOutPut | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty name
$count=0
ForEach($prop in $noteProperties)
{
    Write-Progress -Activity "Checking and Customizing Output" -Status $prop -PercentComplete ($count/$noteProperties.count*100)
    if ($sku.ContainsKey($prop))
    {
        $UserOutPut | Add-Member -MemberType AliasProperty -Name $sku.$($prop) -Value $prop
        $index = $properties.IndexOf($prop)
        #replace output property with the friendly name.
        $properties[$index]=$sku.$($prop)      
    }
    $count++
}

$UserOutPut | Select-Object  $properties