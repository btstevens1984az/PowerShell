# Purpose: Install — General-purpose PowerShell utilities.
<#
Now Micro Right Click Tools
#>

$Version = "2.1"
$StringToReplace = "C:\Program Files (x86)\Now Micro\Right Click Tools","C:\Program Files (x86)\Now Micro\Recast RCT"

$ScriptName = $MyInvocation.MyCommand.path
$Directory = Split-Path $ScriptName
$LicensePath = "C:\ProgramData\Now Micro\Licenses"

if ([string]::IsNullOrEmpty($Directory))
{
	$Directory = "C:\Program Files (x86)\Now Micro\Recast RCT"
	$ScriptName = "$Directory\install.ps1"
}

If(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]"Administrator")){
	Start-Process Powershell.exe -ArgumentList "-STA -noprofile -file `"$ScriptName`"" -Verb RunAs
	Exit
}

$Tools = New-Object System.Collections.ArrayList

$DeviceObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Device\_Recast Enterprise Device Tools.xml"
    GUIDS = "3fd01cd1-9e01-461e-92cd-94866b8d1f39,ed9dee86-eadd-4ac8-82a1-7234a4646e62,0770186d-ea57-4276-a46b-7344ae081b58,64db983c-10bc-4b47-8f2d-cfff48f34faf,2b646eff-442b-410e-adf3-d4ec699e0ab4,cbe3631f-901e-49ea-b3c2-4e32996720cd,fb04b7a5-bc4c-4468-8eb8-937d8eb90efb,9b73a906-6908-4316-b61e-cbab300c9791"
}
$Tools.Add($DeviceObject)

$DeviceCollectionObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Collection\_Recast Enterprise Collection Tools.xml"
    GUIDS = "3785759b-db2c-414e-a540-e879497c6f97,a92615d6-9df3-49ba-a8c9-6ecb0e8b956b"
}
$Tools.Add($DeviceCollectionObject)

$DeploymentObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Deployment\_Recast Enterprise Deployment Tools.xml"
    GUIDS = "172d85e7-bb7a-4479-a6a2-768f175b75cb,4f89279a-6f64-467a-8e04-f35cda1f50a4,8d4785b2-b055-43e2-afb1-a9347c95d971,93218e21-485a-4e2b-9f23-77c76145e214,20313308-298b-4c29-9830-292c57dc83d3,21581552-82c3-42f7-b0bd-c48f04f2d148,d1621955-48ad-4bba-9c85-95f74c0c6538,f4739863-3c18-42c0-84cc-f214fe1be509,9a0e2197-51a4-439d-99ea-67edc451a51e,adab1364-cf7d-4b07-8863-e9252e506e62"
}
$Tools.Add($DeploymentObject)

$UserObject = New-Object PSObject @{
    File = "$Directory\Default Menus\User\_Recast Enterprise User Tools.xml"
    GUIDS = "baaa6910-892f-4d20-9082-b392e5a28a53,a2560e1f-dd80-4280-8e8e-cbd9c6794ba7"
}
$Tools.Add($UserObject)

<#
$AdministrativeUserObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Administrative User\_Recast Enterprise Administrative User Tools.xml"
    GUIDS = "9bc0969e-8f55-4e4b-89a9-6f92bab96882"
}
$Tools.Add($AdministrativeUserObject)
#>

$ApplicationOjbect = New-Object PSObject @{
    File = "$Directory\Default Menus\Application\_Recast Enterprise Application Tools.xml"
    GUIDS = "968164ab-af86-459c-b89e-d3a49c05d367"
}
$Tools.Add($ApplicationOjbect)

$PackageObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Package\_Recast Enterprise Package Tools.xml"
    GUIDS = "9c69b0aa-a27c-43c9-8c26-5f964106a881"
}
$Tools.Add($PackageObject)

$BootImageObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Boot Image\_Recast Enterprise Boot Image Tools.xml"
    GUIDS = "7a5f089c-ea90-4da2-aee9-d6d2673a861f"
}
$Tools.Add($BootImageObject)

$DriverPackageObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Driver Package\_Recast Enterprise Driver Tools.xml"
    GUIDS = "4b05362e-3ea4-4931-aa2d-3d889b1d75e4"
}
$Tools.Add($DriverPackageObject)

$OSPackageObject = New-Object PSObject @{
    File = "$Directory\Default Menus\OS Install Package\_Recast Enterprise OS Package Tools.xml"
    GUIDS = "7d0f75ec-3502-4b9d-b3ce-7b18b29942e8"
}
$Tools.Add($OSPackageObject)

$SoftwareUpdateObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Software Update Package\_Recast Enterprise Software Update Tools.xml"
    GUIDS = "606d3a81-6817-423c-bbe0-0c5c3e79c4ec"
}
$Tools.Add($SoftwareUpdateObject)

$ImageObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Image Package\_Recast Enterprise Image Tools.xml"
    GUIDS = "828a154e-4c7d-4d7f-ba6c-268443cdb4e8"
}
$Tools.Add($ImageObject)

$ClientHealthObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Client Health\_Recast Enterprise Client Health Tools.xml"
    GUIDS = "0eb25366-3f67-4c5f-8246-76223bdfcd89,8c0ae624-8d87-4eaa-bc2b-5e2e04be925e,1edea6be-03eb-410c-be3a-0dcde81d92dd"
}
$Tools.Add($ClientHealthObject)

$MalwareDetectedObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Malware Detected\_Recast Enterprise Malware Detected Tools.xml"
    GUIDS = "14f64c21-2b83-4949-9751-1453676f52e9"
}
$Tools.Add($MalwareDetectedObject)

$AppDeploymentTypeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Application Deployment Type\_Recast Enterprise Application Deployment Type Tools.xml"
    GUIDS = "09950ae2-000e-45b2-bfd6-6c7d66b8c34a"
}
$Tools.Add($AppDeploymentTypeObject)

$ContentObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Content\_Recast Enterprise Content Tools.xml"
    GUIDS = "d1cf0cc0-be8b-4dff-9333-05b53d067295,14214306-59f0-46cf-b453-a649f2a249e1"
}
$Tools.Add($ContentObject)

$DistributionPointObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Distribution Point\_Recast Enterprise Distribution Point Tools.xml"
    GUIDS = "aaf6fdee-9cf8-419c-8a5d-b4c4ab66dd55,d8718784-99d5-4449-bc28-a26631fafc07"
}
$Tools.Add($DistributionPointObject)

$PackageNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Package Node\_Recast Enterprise Package Node Tools.xml"
    GUIDS = "3ad39fd0-efd6-11d0-bdcf-00a0c909fdd7"
}
$Tools.Add($PackageNodeObject)

$ApplicationNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Application Node\_Recast Enterprise Application Node Tools.xml"
    GUIDS = "d2e2cba7-98f5-4d3b-bc2f-b670f0621207"
}
$Tools.Add($ApplicationNodeObject)

$UsersNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Users Node\_Recast Enterprise Users Node Tools.xml"
    GUIDS = "80ea5cfa-5d28-47aa-a134-f455e2df2cd1"
}
$Tools.Add($UsersNodeObject)

$DevicesNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Devices Node\_Recast Enterprise Devices Node Tools.xml"
    GUIDS = "221219d3-b871-48e8-b85a-ee06bfec7740"
}
$Tools.Add($DevicesNodeObject)

$UserCollectionObject = New-Object PSObject @{
    File = "$Directory\Default Menus\User Collection\_Recast Enterprise User Collection Tools.xml"
    GUIDS = "34446c89-5a0d-4287-88e5-9c87d832a946,9270f88a-b739-4e3a-9fea-5a2af31154b2"
}
$Tools.Add($UserCollectionObject)

$ClientSettingsObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Client Settings\_Recast Enterprise Client Settings Tools.xml"
    GUIDS = "160637c3-955f-4643-a8e7-0e75ed4e7c6f,ac5cbf00-ea7e-4a69-b378-a20310b88583"
}
$Tools.Add($ClientSettingsObject)

$OSImagesNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\OS Images Node\_Recast Enterprise OS Images Node Tools.xml"
    GUIDS = "ac16f420-2d72-4056-a8f6-aef90e66a10c"
}
$Tools.Add($OSImagesNodeObject)

$SoftwareUpdatesNodeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Software Updates Node\_Recast Enterprise Software Updates Node Tools.xml"
    GUIDS = "84703961-b1a7-4185-bc9c-d1a428050a46"
}
$Tools.Add($SoftwareUpdatesNodeObject)

$SoftwareUpdateGroupObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Software Update Group\_Recast Enterprise Software Update Group Tools.xml"
    GUIDS = "2853886b-cce5-4ed4-af43-df69efb2e7d8,bb1a22d4-816f-438c-b6e7-51cbc210112f"
}
$Tools.Add($SoftwareUpdateGroupObject)

<#$UserDiscoveryObject = New-Object PSObject @{
    File = "$Directory\Default Menus\User Discovery\_Recast Enterprise User Discovery Tools.xml"
    GUIDS = "5dd919f0-9888-497c-aedb-c9eee690f8f9"
}
$Tools.Add($UserDiscoveryObject)#>

$DiscoveryObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Discovery\_Recast Enterprise Discovery Tools.xml"
    GUIDS = "5dd919f0-9888-497c-aedb-c9eee690f8f9,69eb4eae-1aae-45ed-bacc-36cde2b4db3f"
}
$Tools.Add($DiscoveryObject)

$QueryObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Queries\_Recast Enterprise Query Tools.xml"
    GUIDS = "186eaf52-8767-4522-aa34-584d0615961f,c8137990-aa6b-4e1f-867a-4971fb2a08ef"
}
$Tools.Add($QueryObject)

<#$DPGroupObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Distribution Point Group\_Recast Enterprise Distribution Point Group Tools.xml"
    GUIDS = "be05fb70-0608-4856-986d-5ab5d7b482e4,b8b1ca70-e72a-464c-befe-e956a8d2daf6,1c0a6da6-d3f6-4d9d-9d17-6916951d9a1b"
}
$Tools.Add($DPGroupObject)#>

$TSObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Task Sequence\_Recast Enterprise Task Sequence Tools.xml"
    GUIDS = "f2c07bfb-d83d-4e0b-969b-5da6321c28c2"
}
$Tools.Add($TSObject)

$ScopeObject = New-Object PSObject @{
    File = "$Directory\Default Menus\Security Scopes\_Recast Enterprise Security Scope Tools.xml"
    GUIDS = "254a0fc6-397e-43c5-9b87-aea752c99525,bfd32664-b4b7-4926-91a9-1ebbedddd453"
}
$Tools.Add($ScopeObject)

$ConfigInstallPath = $env:SMS_ADMIN_UI_PATH | Out-String
$ConfigInstallPath = $ConfigInstallPath -replace "\\29.182.148.253\\i386", ""
If ($ConfigInstallPath.Length -lt 2) {
	$ConfigInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\Setup").'UI Installation Directory'
	If ($ConfigInstallPath.Length -lt 2) {
		$ConfigInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ConfigMgr10\Setup").'UI Installation Directory'
		If ($ConfigInstallPath.Length -lt 2) {
			$ConfigInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\SMS\Setup").'UI Installation Directory'
			If ($ConfigInstallPath.Length -lt 2) {
				(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\SMS\Setup").'UI Installation Directory'
			}
		}
	}
}

if ($ConfigInstallPath.Endswith("\")) {$ConfigInstallPath = $ConfigInstallPath.Substring(0,$ConfigInstallPath.Length -1)}

$ConfigInstallPath = $ConfigInstallPath.Replace("`n","").Replace("`r","")
$ConsoleRootPath = "$ConfigInstallPath\XMLStorage\ConsoleRoot"
$XMLInstallPath = "$ConfigInstallPath\XMLStorage\Extensions\Actions"

New-Item "$Directory\Actions" -Type Directory -ErrorAction SilentlyContinue
Copy-Item "$Directory\Default Menus" "$Directory\Actions" -Force -Recurse

#Remove old default menus
Get-ChildItem "$Directory\Actions" -Filter "*.xml" -Recurse | ForEach-Object {
	Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
}

#Remove Previous Powershell RCT Menus
Get-ChildItem $XMLInstallPath -Recurse -Filter ("*.xml") | ForEach-Object {
	$Filename = $_.Name
	$FullName = $_.FullName
		$Popup = new-object -comobject wscript.shell
		#$Popup.Popup($Filename,0,"",1)
	Switch -wildcard ($Filename.ToLower()) {
		"client actions on device.xml" {
			Remove-Item $FullName
		}
		"client tools on device.xml" {
			Remove-Item $FullName -Force
		}
		"console tools on device.xml" {
			Remove-Item $FullName -Force
		}
		"client actions on deployment.xml" {
			Remove-Item $FullName -Force
		}
		"client tools on deployment.xml" {
			Remove-Item $FullName -Force
		}
		"console tools on deployment.xml" {
			Remove-Item $FullName -Force
		}
		"client actions on collection.xml" {
			Remove-Item $FullName -Force
		}
		"client tools on collection.xml" {
			Remove-Item $FullName -Force
		}
		"console tools on collection.xml" {
			Remove-Item $FullName -Force
		}
		"driver package extensions.xml" {
			Remove-Item $FullName -Force
		}
		"boot image extensions.xml" {
			Remove-Item $FullName -Force
		}
		"os install package extensions.xml" {
			Remove-Item $FullName -Force
		}
		"package extensions.xml" {
			Remove-Item $FullName -Force
		}
		"software update package extensions.xml" {
			Remove-Item $FullName -Force
		}
		"image package extensions.xml" {
			Remove-Item $FullName -Force
		}
		"application extensions.xml" {
			Remove-Item $FullName -Force
		}
		"user extensions.xml" {
			Remove-Item $FullName -Force
		}
		"_Recast Enterprise*" {
			Remove-Item $FullName -Force
		}
	}
}

Function Copy-XMLFiles {
    Param ($GUID, $FileName)
    $FileName = $FileName.Trim()
    Copy-Item -Force "$FileName" "$XMLInstallPath\$GUID"
    Copy-Item -Force "$FileName" "$Directory\Actions\$GUID"
}

Function ReplaceDefaultText {
    Param ($FullFileName)
    $FileName = $FullFileName.Split("\")
    $FileName = $FileName[$FileName.Length - 1]
    Get-Content "$FullFileName" | ForEach-Object {
	    $Line = $_
		foreach ($instance in $StringToReplace) {
			$Line = $Line.Replace("$instance","$Directory")
		}
    	
	    $Line >> "$Directory\Actions\Default Menus\$FileName"
    }
    return "$Directory\Actions\Default Menus\$FileName"
    
}

$builderText = "  <ActionDescription Class=`"AssemblyType`" DisplayName=`"RCT Builder`" MnemonicDisplayName=`"RCT Builder`" Description=`"REPLACEME,cd1f3a92-72f0-41d3-8fed-4f2c4ea980d5`" SelectionMode=`"Both`">
    <ShowOn>
      <string>ContextMenu</string>
    </ShowOn>
	<ActionStateAssembly>
		<Assembly>$Directory\RCT.Plugin.Base.dll</Assembly>
		<Type>RCT.Plugin.Base.BasePlugin</Type>
		<Method>UserHasPermission</Method>
	</ActionStateAssembly>
    <ActionAssembly>
      <Assembly>$Directory\RCT.Plugin.RCTBuilder.dll</Assembly>
      <Type>RCT.Plugin.RCTBuilder.RCTBuilderPlugin</Type>
      <Method>Execute</Method>
    </ActionAssembly>
  </ActionDescription>
  <ActionDescription Class=`"AssemblyType`" DisplayName=`"RCT Runner`" MnemonicDisplayName=`"RCT Runner`" Description=`"REPLACEME,f088576f-cbc5-46e8-a15b-50f166ac6c9a`" SelectionMode=`"Both`">
    <ShowOn>
      <string>ContextMenu</string>
    </ShowOn>
	<ActionStateAssembly>
		<Assembly>$Directory\RCT.Plugin.Base.dll</Assembly>
		<Type>RCT.Plugin.Base.BasePlugin</Type>
		<Method>UserHasPermission</Method>
	</ActionStateAssembly>
    <ActionAssembly>
      <Assembly>$Directory\RCT.Plugin.RCTRunner.dll</Assembly>
      <Type>RCT.Plugin.RCTRunner.RCTRunnerPlugin</Type>
      <Method>Execute</Method>
    </ActionAssembly>
  </ActionDescription>
</ActionGroups>
</ActionDescription>"

#Get-ChildItem -Path "$Directory\Default Menus" -Filter "*.xml" -Recurse | ForEach-Object { ReplaceDefaultText -FullFileName $_.FullName }

$hashGuids = @{}

Foreach ($Tool in $Tools) {
    $SplitGUIDS = $Tool.GUIDS
    If ($SplitGUIDS.Contains(",")) {
        $SplitGUIDS = $SplitGUIDS.Split(",")
        $File = $Tool.File
        Foreach ($GUID in $SplitGUIDS) {
            $null = New-Item "$XMLInstallPath\$GUID" -ItemType Directory -ErrorAction SilentlyContinue
            $null = New-Item "$Directory\Actions\$GUID" -ItemType Directory -ErrorAction SilentlyContinue
			if(-not $hashGuids.ContainsKey($GUID))
			{
				$hashGuids.Add($GUID, "")
			}
        }
        $FileName = ReplaceDefaultText -FullFileName $Tool.File
		$text = [System.IO.File]::ReadAllText($FileName)
		$text = $text.Substring(0, $text.LastIndexOf("</ActionGroups>"))
		$text += $builderText
        Foreach ($GUID in $SplitGUIDS) {
			$replaceText = $text.Replace("REPLACEME", $GUID)
			[System.IO.File]::WriteAllText($FileName, $replaceText)
            Copy-XMLFiles -GUID $GUID -FileName $FileName
        }
    }
    else {
        $File = $Tool.File
        $GUID = $SplitGUIDS
		$FileName = ReplaceDefaultText -FullFileName $Tool.File
		$text = [System.IO.File]::ReadAllText($FileName)
		$text = $text.Substring(0, $text.LastIndexOf("</ActionGroups>"))
		$text += $builderText
		$text = $text.Replace("REPLACEME", $GUID)
		[System.IO.File]::WriteAllText($FileName, $text)
		if(-not $hashGuids.ContainsKey($GUID))
		{
			$hashGuids.Add($GUID, "")
		}
        $null = New-Item "$XMLInstallPath\$GUID" -ItemType Directory -ErrorAction SilentlyContinue
        $null = New-Item "$Directory\Actions\$GUID" -ItemType Directory -ErrorAction SilentlyContinue
        Copy-XMLFiles -GUID $GUID -FileName $FileName
    }
}

$file = "$Directory\Default Menus\Builder\_Recast Enterprise Builder.xml"
$tempFile = "$Directory\Default Menus\Builder\_Recast Enterprise Builder Tools.xml"
Write-Output "AllNodes: $((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Now Micro\Right Click Tools Enterprise Desktop").AllNodes)" | Out-File "C:\ProgramData\Now Micro\Logs\recastdesktop.log"
if((Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Now Micro\Right Click Tools Enterprise Desktop").AllNodes -eq 1)
{
	foreach($xmlfile in Get-ChildItem "$ConsoleRootPath" -Filter "*.xml" -Recurse)
	{
		foreach($line in Get-Content $xmlfile.FullName)
		{
			if($line.ToLower().Contains("namespaceguid="))
			{
				$guid = $line.Split("`"")[1]
				Write-Output "Guid: $guid"
				if($hashGuids.ContainsKey($guid))
				{
					Write-Output "Already processed $guid, skipping"
					continue
				}
				$null = New-Item -ItemType Directory -Path "$XMLInstallPath\$guid" -ErrorAction SilentlyContinue
				$null = New-Item -ItemType Directory -Path "$Directory\Actions\$guid" -ErrorAction SilentlyContinue
				$text = [System.IO.File]::ReadAllText($file)
				$text = $text.Replace("REPLACEME", $guid)
				foreach ($instance in $StringToReplace)
				{
					$text = $text.Replace("$instance","$Directory")
				}
				[System.IO.File]::WriteAllText($tempFile, $text)
				Copy-XMLFiles -GUID $guid -FileName $tempFile
			}
		}
	}
}
Remove-Item -Path $File -Force

if(!(Test-Path "$LicensePath"))
{
	New-Item "$LicensePath" -ItemType Directory
}
Copy-Item "$Directory\*.bin" "$LicensePath\"

"Version=$Version" > "$Directory\Install Properties.ini"
"XMLPath=$XMLInstallPath" >> "$Directory\Install Properties.ini"
"ToolPath=$Directory" >> "$Directory\Install Properties.ini"