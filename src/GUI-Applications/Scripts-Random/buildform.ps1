# Purpose: buildform — PowerShell automation.


        Function Get-CompInfo {
              <#
              .SYNOPSIS
              Gets information on the computer
              .DESCRIPTION
              Gets standard information on the computer and creates an .Net object that contains the output
              .EXAMPLE
              Get-Info
              .EXAMPLE
              Once the function is ran you can find the object of $compinfo
              .PARAMETER computername
              There are no parameters
              .PARAMETER logname
              There are no parameters
              #>
            [CmdletBinding(SupportsShouldProcess=$True)]
            param()
            BEGIN {}
            PROCESS { 
                    $VerbosePreference = "Continue"
                    $sysroot = gc env:systemroot
                    $machine_name = gc env:computername
                    $OperatingSystem = (get-wmiobject win32_operatingsystem).caption
                    $OSArchitecture = (get-wmiobject win32_operatingsystem).OSArchitecture
                    $manufacturer = (get-wmiobject win32_computersystem).manufacturer
                    $model = (get-wmiobject win32_computersystem).model
                    $serial = (get-wmiobject win32_bios).serialnumber 

                    #########################################
                    #  Express Service Code
                    if ($manufacturer -match "Dell")
                    {
                    $Base = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                    $Length = $Serial.Length
                    For ($CurrentChar = $Length; $CurrentChar -ge 0; $CurrentChar--) 
                        {
                        $ExpressServiceCode = $Out + [int64](([Math]::Pow(36, ($CurrentChar - 1)))*($Base.IndexOf($serial[($Length - $CurrentChar)])))
                        }
                    }
                    else
                    {
                    $ExpressServiceCode = "Computer is not a Dell"
                    }

                    #########################################
                    #  Determine if it is a Laptop or Desktop

                    $isLaptop = $false
                    if(Get-WmiObject -Class win32_systemenclosure |
                            Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
                        { 
                        $isLaptop = $true 
                        }

                    if(Get-WmiObject -Class win32_battery)
                        { 
                        $isLaptop = $true 
                        }

                    if ($isLaptop)
                        {
                        $chassis = "Laptop"
                        }
                    else
                        {
                        $chassis = "Desktop"
                        }

                    #########################################
                    #  Get Firewall and Device Status

                    if ($OperatingSystem -match "Windows XP") 
                        {
                        #########################################
                        #  XP Firewall Status

                        $xp_fwcheck = get-service | where-object {$_.displayname -match "Windows Firewall"} | select status
                
                        if ($xp_fwcheck.status)
                        {
                        $firewallStatus = "Enabled"
                        }
                        else
                        {
                        $firewallStatus = "Disabled"
                        }
        
                        #########################################
                        #  XP Device Status

                        $hw_check = gwmi -class Win32_PnPEntity | Where-Object {$_.status -match "Error"}
                        $devicecount = ($hw_check.count)
                        if ($devicecount -eq $null){$devicecount = "0"}
                        $DeviceStatus = "$devicecount devices need drivers"

                        }
                    else
                        {
                        #########################################
                        #  Windows 7 Firewall Status

                        $fw = New-Object -ComObject HNetCfg.FwPolicy2
                        # gets all current firewall rules.
                        $rules = $fw.rules
                        # Define all the groups to check for in followup loop.
                        $subgroups = ("Core Networking", "File and Printer Sharing", "Netlogon Service", "Network Discovery", "Remote Administration", "Remote Assistance", "Remote Desktop", "Remote Service Management", "Windows Firewall Remote Management", "Windows Management Instrumentation (WMI)", "Windows Remote Management")
                        # Define array for number of incorrectly set rules.
                        $fw_data = @()

                        foreach($item in $subgroups) {
                            # queries the rules for 
                            $query = $rules | Where-Object {$_.name -match $item} | select-object name, enabled
                            # now, checks the filtered query for any that are false, then notates those in a separate variable if false
                            $query | foreach-object {
                                $output = "" | Select-Object RuleName, Status
                                $output.RuleName = $_.Name
                                $output.Status = $_.Enabled
                                $ruleEnabled = $_.Enabled
                                # All of the above must be set to TRUE for the .Enabled property.
                                if($ruleEnabled -match "False") {
                                    # append $fw_data with a row of incorrect rule
                                    $fw_data += $output
                                }       
                            }
                        }

                        # check the amount of items in the set of rules.  If > 0 then output the list of rules in the HTML file.
                        $failcount = $fw_data.count
                        if ($failcount -eq 0) 
                            {
                            $firewallStatus = "Correct"
                            }
                        else
                            {
                            $firewallStatus = "Missing $failcount rules"
                            }
        
                        #########################################
                        #  Windows 7 Device Status

                        $hw_check = gwmi -class Win32_PnPEntity | Where-Object {$_.ConfigManagerErrorCode -ne 0}
                        $devicecount = ($hw_check.count)
                        if ($devicecount -eq $null){$devicecount = "0"}
                        $DeviceStatus = "$devicecount devices need drivers"

                        #########################################
                        #  Get UAC Status

                        $uac = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
                        $uacquery = Get-ItemProperty -path $uac -name EnableLUA
                        $uacval = $uacquery.EnableLUA
                        $uacstatus = ($uacval -eq 1)
            
                        }

                    #########################################
                    #  Return Computer Info Object

                    $compinfo = NEW-OBJECT PSOBJECT -property @{SystemRoot='';CompName='';OperatingSystem='';OSArchitecture='';Manufacturer='';Model='';Serial='';ExpressServiceCode='';DeviceStatus='';FirewallStatus='';UACStatus='';Chassis=''} 
      
                    $compinfo.SystemRoot = $sysroot
                    $compinfo.CompName = $machine_name
                    $compinfo.OperatingSystem = $OperatingSystem
                    $compinfo.OSArchitecture = $OSArchitecture
                    $compinfo.Manufacturer = $manufacturer
                    $compinfo.Model = $model
                    $compinfo.Serial = $serial
                    $compinfo.ExpressServiceCode = $ExpressServiceCode
                    $compinfo.DeviceStatus = $DeviceStatus
                    $compinfo.FirewallStatus = $firewallStatus
                    $compinfo.uacstatus = $uacstatus
                    $compinfo.chassis = $chassis

                    Return $compinfo
                    }
            END {}
        }

#########################################
    

$machine_name = gc env:computername
$ticket = "PR337572"
$user = 'Kevin Carpenter'
$username = 'kevin.carpenter'
$pass = 'kc34kc34$'
$client = 'Fiberlight'
$domain = 'fbl.titan.1sourcing.net'
$date = Get-Date -Format MM/dd/yyyy
$image = 'NONE'

$info = Get-CompInfo

#########################################



$webpage = @"

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1252">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 14">
<meta name=Originator content="Microsoft Word 14">
<link rel=File-List
href="Default-Build_Form_for_Windows_v3.0_files/filelist.xml">
<title>[Default Build Form for Windows</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>Alan Dean</o:Author>
  <o:LastAuthor>Carlos McCray</o:LastAuthor>
  <o:Revision>3</o:Revision>
  <o:TotalTime>219</o:TotalTime>
  <o:LastPrinted>2012-04-02T19:13:00Z</o:LastPrinted>
  <o:Created>2012-06-29T18:42:00Z</o:Created>
  <o:LastSaved>2012-06-29T18:42:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>552</o:Words>
  <o:Characters>3153</o:Characters>
  <o:Company>LFS</o:Company>
  <o:Lines>26</o:Lines>
  <o:Paragraphs>7</o:Paragraphs>
  <o:CharactersWithSpaces>3698</o:CharactersWithSpaces>
  <o:Version>14.00</o:Version>
 </o:DocumentProperties>
 <o:OfficeDocumentSettings>
  <o:RelyOnVML/>
  <o:AllowPNG/>
 </o:OfficeDocumentSettings>
</xml><![endif]-->
<link rel=dataStoreItem
href="Default-Build_Form_for_Windows_v3.0_files/item0008.xml"
target="Default-Build_Form_for_Windows_v3.0_files/props009.xml">
<link rel=themeData
href="Default-Build_Form_for_Windows_v3.0_files/themedata.thmx">
<link rel=colorSchemeMapping
href="Default-Build_Form_for_Windows_v3.0_files/colorschememapping.xml">
<!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:TrackMoves/>
  <w:TrackFormatting/>
  <w:PunctuationKerning/>
  <w:DrawingGridHorizontalSpacing>5.5 pt</w:DrawingGridHorizontalSpacing>
  <w:DisplayHorizontalDrawingGridEvery>2</w:DisplayHorizontalDrawingGridEvery>
  <w:DisplayVerticalDrawingGridEvery>2</w:DisplayVerticalDrawingGridEvery>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:DoNotPromoteQF/>
  <w:LidThemeOther>EN-US</w:LidThemeOther>
  <w:LidThemeAsian>JA</w:LidThemeAsian>
  <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
   <w:DontGrowAutofit/>
   <w:SplitPgBreakAndParaMark/>
   <w:EnableOpenTypeKerning/>
   <w:DontFlipMirrorIndents/>
   <w:OverrideTableStyleHps/>
  </w:Compatibility>
  <m:mathPr>
   <m:mathFont m:val="Cambria Math"/>
   <m:brkBin m:val="before"/>
   <m:brkBinSub m:val="&#45;-"/>
   <m:smallFrac m:val="off"/>
   <m:dispDef/>
   <m:lMargin m:val="0"/>
   <m:rMargin m:val="0"/>
   <m:defJc m:val="centerGroup"/>
   <m:wrapIndent m:val="1440"/>
   <m:intLim m:val="subSup"/>
   <m:naryLim m:val="undOvr"/>
  </m:mathPr></w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" DefUnhideWhenUsed="true"
  DefSemiHidden="true" DefQFormat="false" DefPriority="99"
  LatentStyleCount="267">
  <w:LsdException Locked="false" Priority="0" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Normal"/>
  <w:LsdException Locked="false" Priority="9" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="heading 1"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 2"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 3"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 4"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 5"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 6"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 7"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 8"/>
  <w:LsdException Locked="false" Priority="9" QFormat="true" Name="heading 9"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 1"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 2"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 3"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 4"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 5"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 6"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 7"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 8"/>
  <w:LsdException Locked="false" Priority="39" Name="toc 9"/>
  <w:LsdException Locked="false" Priority="35" QFormat="true" Name="caption"/>
  <w:LsdException Locked="false" Priority="10" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Title"/>
  <w:LsdException Locked="false" Priority="1" Name="Default Paragraph Font"/>
  <w:LsdException Locked="false" Priority="11" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Subtitle"/>
  <w:LsdException Locked="false" Priority="22" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Strong"/>
  <w:LsdException Locked="false" Priority="20" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Emphasis"/>
  <w:LsdException Locked="false" Priority="59" SemiHidden="false"
   UnhideWhenUsed="false" Name="Table Grid"/>
  <w:LsdException Locked="false" UnhideWhenUsed="false" Name="Placeholder Text"/>
  <w:LsdException Locked="false" Priority="1" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="No Spacing"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 1"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 1"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 1"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 1"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 1"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 1"/>
  <w:LsdException Locked="false" UnhideWhenUsed="false" Name="Revision"/>
  <w:LsdException Locked="false" Priority="34" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="List Paragraph"/>
  <w:LsdException Locked="false" Priority="29" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Quote"/>
  <w:LsdException Locked="false" Priority="30" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Intense Quote"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 1"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 1"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 1"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 1"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 1"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 1"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 1"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 1"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 2"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 2"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 2"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 2"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 2"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 2"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 2"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 2"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 2"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 2"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 2"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 2"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 2"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 2"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 3"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 3"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 3"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 3"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 3"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 3"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 3"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 3"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 3"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 3"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 3"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 3"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 3"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 3"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 4"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 4"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 4"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 4"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 4"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 4"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 4"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 4"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 4"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 4"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 4"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 4"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 4"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 4"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 5"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 5"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 5"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 5"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 5"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 5"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 5"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 5"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 5"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 5"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 5"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 5"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 5"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 5"/>
  <w:LsdException Locked="false" Priority="60" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Shading Accent 6"/>
  <w:LsdException Locked="false" Priority="61" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light List Accent 6"/>
  <w:LsdException Locked="false" Priority="62" SemiHidden="false"
   UnhideWhenUsed="false" Name="Light Grid Accent 6"/>
  <w:LsdException Locked="false" Priority="63" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 1 Accent 6"/>
  <w:LsdException Locked="false" Priority="64" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Shading 2 Accent 6"/>
  <w:LsdException Locked="false" Priority="65" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 1 Accent 6"/>
  <w:LsdException Locked="false" Priority="66" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium List 2 Accent 6"/>
  <w:LsdException Locked="false" Priority="67" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 1 Accent 6"/>
  <w:LsdException Locked="false" Priority="68" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 2 Accent 6"/>
  <w:LsdException Locked="false" Priority="69" SemiHidden="false"
   UnhideWhenUsed="false" Name="Medium Grid 3 Accent 6"/>
  <w:LsdException Locked="false" Priority="70" SemiHidden="false"
   UnhideWhenUsed="false" Name="Dark List Accent 6"/>
  <w:LsdException Locked="false" Priority="71" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Shading Accent 6"/>
  <w:LsdException Locked="false" Priority="72" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful List Accent 6"/>
  <w:LsdException Locked="false" Priority="73" SemiHidden="false"
   UnhideWhenUsed="false" Name="Colorful Grid Accent 6"/>
  <w:LsdException Locked="false" Priority="19" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Subtle Emphasis"/>
  <w:LsdException Locked="false" Priority="21" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Intense Emphasis"/>
  <w:LsdException Locked="false" Priority="31" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Subtle Reference"/>
  <w:LsdException Locked="false" Priority="32" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Intense Reference"/>
  <w:LsdException Locked="false" Priority="33" SemiHidden="false"
   UnhideWhenUsed="false" QFormat="true" Name="Book Title"/>
  <w:LsdException Locked="false" Priority="37" Name="Bibliography"/>
  <w:LsdException Locked="false" Priority="39" QFormat="true" Name="TOC Heading"/>
 </w:LatentStyles>
</xml><![endif]-->
<link rel=plchdr href="Default-Build_Form_for_Windows_v3.0_files/plchdr.htm">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"MS Gothic";
	panose-1:2 11 6 9 7 2 5 8 2 4;
	mso-font-alt:"\FF2D\FF33 \30B4\30B7\30C3\30AF";
	mso-font-charset:128;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:-536870145 1791491579 134217746 0 131231 0;}
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;
	mso-font-charset:1;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Cambria;
	panose-1:2 4 5 3 5 4 6 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:-536870145 1073743103 0 0 415 0;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-536870145 1073786111 1 0 415 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-520081665 -1073717157 41 0 66047 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1593833729 1073750107 16 0 415 0;}
@font-face
	{font-family:"\@MS Gothic";
	panose-1:2 11 6 9 7 2 5 8 2 4;
	mso-font-charset:128;
	mso-generic-font-family:modern;
	mso-font-pitch:fixed;
	mso-font-signature:-536870145 1791491579 134217746 0 131231 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:10.0pt;
	margin-left:0in;
	line-height:115%;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-link:"Comment Text Char";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:10.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{mso-style-priority:99;
	mso-style-link:"Header Char";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 3.25in right 6.5in;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{mso-style-priority:99;
	mso-style-link:"Footer Char";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 3.25in right 6.5in;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
span.MsoCommentReference
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-noshow:yes;
	mso-style-priority:99;
	color:purple;
	mso-themecolor:followedhyperlink;
	text-decoration:underline;
	text-underline:single;}
p.MsoCommentSubject, li.MsoCommentSubject, div.MsoCommentSubject
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-parent:"Comment Text";
	mso-style-link:"Comment Subject Char";
	mso-style-next:"Comment Text";
	margin-top:0in;
	margin-right:0in;
	margin-bottom:10.0pt;
	margin-left:0in;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;
	font-weight:bold;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-link:"Balloon Text Char";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;}
span.HeaderChar
	{mso-style-name:"Header Char";
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:Header;}
span.FooterChar
	{mso-style-name:"Footer Char";
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:Footer;}
span.BalloonTextChar
	{mso-style-name:"Balloon Text Char";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Balloon Text";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-ascii-font-family:Tahoma;
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;}
span.CommentTextChar
	{mso-style-name:"Comment Text Char";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Comment Text";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;}
span.CommentSubjectChar
	{mso-style-name:"Comment Subject Char";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-parent:"Comment Text Char";
	mso-style-link:"Comment Subject";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-weight:bold;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
.MsoChpDefault
	{mso-style-type:export-only;
	mso-default-props:yes;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;}
.MsoPapDefault
	{mso-style-type:export-only;
	margin-bottom:10.0pt;
	line-height:115%;}
 /* Page Definitions */
 @page
	{mso-footnote-separator:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") fs;
	mso-footnote-continuation-separator:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") fcs;
	mso-endnote-separator:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") es;
	mso-endnote-continuation-separator:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") ecs;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:.5in .5in .5in .5in;
	mso-header-margin:.5in;
	mso-footer-margin:.5in;
	mso-header:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") h1;
	mso-footer:url("Default-Build_Form_for_Windows_v3.0_files/header.htm") f1;
	mso-paper-source:0;}
div.WordSection1
	{page:WordSection1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-parent:"";
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-para-margin-top:0in;
	mso-para-margin-right:0in;
	mso-para-margin-bottom:10.0pt;
	mso-para-margin-left:0in;
	line-height:115%;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;}
table.MsoTableGrid
	{mso-style-name:"Table Grid";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-priority:59;
	mso-style-unhide:no;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
	mso-para-margin:0in;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="40961"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'>

<div class=WordSection1>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=732
 style='width:549.0pt;margin-left:.9pt;border-collapse:collapse;border:none;
 mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
 mso-border-themeshade:191;mso-yfti-tbllook:1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid #BFBFBF;mso-border-insideh-themecolor:background1;
 mso-border-insideh-themeshade:191;mso-border-insidev:.5pt solid #BFBFBF;
 mso-border-insidev-themecolor:background1;mso-border-insidev-themeshade:191'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:19.3pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;
  mso-border-themecolor:background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;
  height:19.3pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><b><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><span
  style='mso-spacerun:yes'> </span>Ticket Number:<o:p></o:p></span></b></p>
  </td>
  <td width=216 style='width:2.25in;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-left:none;mso-border-left-alt:
  solid #BFBFBF .5pt;mso-border-left-themecolor:background1;mso-border-left-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:19.3pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$ticket<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-left:none;mso-border-left-alt:
  solid #BFBFBF .5pt;mso-border-left-themecolor:background1;mso-border-left-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:19.3pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><b><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'>Make/Model:<o:p></o:p></span></b></p>
  </td>
  <td width=234 style='width:175.5pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-left:none;mso-border-left-alt:
  solid #BFBFBF .5pt;mso-border-left-themecolor:background1;mso-border-left-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:19.3pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$($info.Manufacturer + "/" + $info.model)<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>User's Name:<o:p></o:p></span></p>
  </td>
  <td width=216 style='width:2.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;text-align:center;line-height:
  normal'><span style='font-size:10.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif";text-align:center;mso-bidi-font-weight:bold'>$user<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Service Tag:<o:p></o:p></span></p>
  </td>
  <td width=234 style='width:175.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal style='text-align:center;margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:10.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif";mso-bidi-font-weight:bold'>$($info.serial)<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Company:<o:p></o:p></span></p>
  </td>
  <td width=216 style='width:2.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal style='text-align:center;margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:10.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif";mso-bidi-font-weight:bold'>$client<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Express Service Code:<o:p></o:p></span></p>
  </td>
  <td width=234 style='width:175.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal style='text-align:center;margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:10.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif";mso-bidi-font-weight:bold'>$($info.expressservicecode)<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Login:<o:p></o:p></span></p>
  </td>
  <td width=216 style='width:2.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$username<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Computer Name:<o:p></o:p></span></p>
  </td>
  <td width=234 style='width:175.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$($info.compname)<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Password:<o:p></o:p></span></p>
  </td>
  <td width=216 style='width:2.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$pass<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Domain/Workgroup:<o:p></o:p></span></p>
  </td>
  <td width=234 style='width:175.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$domain<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Date Started:<o:p></o:p></span></p>
  </td>
  <td width=216 style='width:2.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$date<o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=150 style='width:112.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Image Name (if used):<o:p></o:p></span></p>
  </td>
  <td width=234 style='width:175.5pt;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>$image<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;mso-yfti-lastrow:yes;height:17.5pt'>
  <td width=132 style='width:99.0pt;border:solid #BFBFBF 1.0pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;border-top:none;mso-border-top-alt:
  solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
  191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:background1;
  mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:17.5pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:10.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif";mso-bidi-font-weight:
  bold'>Shipping Address:<o:p></o:p></span></p>
  </td>
  <td width=600 colspan=3 style='width:6.25in;border-top:none;border-left:none;
  border-bottom:solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:191;border-right:solid #BFBFBF 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
  mso-border-left-alt:solid #BFBFBF .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:191;mso-border-alt:solid #BFBFBF .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:191;padding:0in 5.4pt 0in 5.4pt;height:
  17.5pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:10.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif";mso-bidi-font-weight:bold'>$shipping<o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Pre-Configuration <o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
 mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:background1;
 mso-border-themeshade:166;mso-yfti-tbllook:1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid #A6A6A6;mso-border-insideh-themecolor:background1;
 mso-border-insideh-themeshade:166;mso-border-insidev:.5pt solid #A6A6A6;
 mso-border-insidev-themecolor:background1;mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;mso-border-alt:
  solid #A6A6A6 .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Tech</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;mso-bidi-font-size:
  11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></b></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Checklist
  Item<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Review customer
  default build form (K.B<span class=GramE>.:</span>&gt; Build Room
  Documentation)</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Speak to
  Customer and ask about additional software<span style='background:darkred;
  mso-highlight:darkred'><o:p></o:p></span></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>If prior machine exists review the Add/Remove list.<span
  style='background:darkred;mso-highlight:darkred'><o:p></o:p></span></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Remove all antivirus software and any additional
  unwanted hardware vendor software or links. (Doc ID: 405100)</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=686 valign=top style='width:514.3pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Remove Business Contact Manager</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Initial Hardware <o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='width:551.5pt;border-collapse:collapse;border:none;mso-border-alt:solid #A6A6A6 .5pt;
 mso-border-themecolor:background1;mso-border-themeshade:166;mso-yfti-tbllook:
 1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #A6A6A6;
 mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:166;
 mso-border-insidev:.5pt solid #A6A6A6;mso-border-insidev-themecolor:background1;
 mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;mso-border-alt:
  solid #A6A6A6 .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  166;padding:0in 5.4pt 0in 5.4pt;height:.1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=684 valign=top style='width:513.0pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Verify that the Operating System is on the C drive and
  is activated</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=684 valign=top style='width:513.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Verify that all hardware drivers have been installed
  (no errors/warnings in Device Manager)</span><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=684 valign=top style='width:513.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Disable power management on all Network Adapters (in
  the drivers).<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=684 valign=top style='width:513.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Rename the computer with correct machine name (Doc ID:
  405583)</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=684 valign=top style='width:513.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Install the latest BIOS update<o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Initial Software <o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='width:551.5pt;border-collapse:collapse;border:none;mso-border-alt:solid #A6A6A6 .5pt;
 mso-border-themecolor:background1;mso-border-themeshade:166;mso-yfti-tbllook:
 1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #A6A6A6;
 mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:166;
 mso-border-insidev:.5pt solid #A6A6A6;mso-border-insidev-themecolor:background1;
 mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;mso-border-alt:
  solid #A6A6A6 .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  166;padding:0in 5.4pt 0in 5.4pt;height:.1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=685 valign=top style='width:513.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Copy the user’s data back to the root of C: from the
  backup location (Do not move to original location yet)<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=685 valign=top style='width:513.9pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Install <span class=SpellE>Kaseya</span> Agent from
  custom link in KB Doc ID: 405646</span><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=685 valign=top style='width:513.9pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Install/Activate Microsoft Office using customer key (packaging/VLK/Client
  Services)</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;height:.1in'>
  <td width=49 valign=top style='width:36.9pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=685 valign=top style='width:513.9pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Apply all available patches for Operating System and
  Office (enable Microsoft Update)<o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:16.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif";color:red'>STOP: </span></b><b
style='mso-bidi-font-weight:normal'><span style='mso-bidi-font-size:10.5pt;
font-family:"Tahoma","sans-serif"'>If this is a machine for inventory to be
stored at MSP then stop here.<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
font-family:"Tahoma","sans-serif"'>Network Configuration<o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=735
 style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
 mso-border-alt:solid #A6A6A6 .5pt;mso-yfti-tbllook:1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid #A6A6A6;mso-border-insidev:.5pt solid #A6A6A6'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=43 valign=top style='width:.45in;border:solid #A6A6A6 1.0pt;
  mso-border-alt:solid #A6A6A6 .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=72 valign=top style='width:.75in;border:solid #A6A6A6 1.0pt;
  border-left:none;mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-alt:solid #A6A6A6 .5pt;
  background:#D9D9D9;mso-background-themecolor:background1;mso-background-themeshade:
  217;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=619 valign=top style='width:6.45in;border:solid #A6A6A6 1.0pt;
  border-left:none;mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-alt:solid #A6A6A6 .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Install
  Kaspersky <span class=SpellE>NetAgent</span> and Antivirus via <span
  class=SpellE>Kaseya</span> and update it<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=43 valign=top style='width:.45in;border:solid #A6A6A6 1.0pt;
  border-top:none;mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-alt:solid #A6A6A6 .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=72 valign=top style='width:.75in;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;background:#D9D9D9;mso-background-themecolor:
  background1;mso-background-themeshade:217;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>Domain<o:p></o:p></span></p>
  </td>
  <td width=619 valign=top style='width:6.45in;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Join
  the computer to the Domain (configure to the customers DNS)<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=43 valign=top style='width:.45in;border:solid #A6A6A6 1.0pt;
  border-top:none;mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-alt:solid #A6A6A6 .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=72 valign=top style='width:.75in;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;background:#D9D9D9;mso-background-themecolor:
  background1;mso-background-themeshade:217;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>Domain<o:p></o:p></span></p>
  </td>
  <td width=619 valign=top style='width:6.45in;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Add
  user as a local administrator BEFORE reboot.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
  <td width=43 valign=top style='width:.45in;border:solid #A6A6A6 1.0pt;
  border-top:none;mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-alt:solid #A6A6A6 .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=72 valign=top style='width:.75in;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;background:#D9D9D9;mso-background-themecolor:
  background1;mso-background-themeshade:217;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>Domain<o:p></o:p></span></p>
  </td>
  <td width=619 valign=top style='width:6.45in;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;border-right:solid #A6A6A6 1.0pt;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-left-alt:solid #A6A6A6 .5pt;
  mso-border-alt:solid #A6A6A6 .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Move
  the machine to the appropriate Managed Organizational Unit and Perform a <span
  class=SpellE>gpupdate</span> /force<o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>User Profile
Configuration<o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=736
 style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
 mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:background1;
 mso-border-themeshade:166;mso-yfti-tbllook:1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;
 mso-border-insideh:.5pt solid #A6A6A6;mso-border-insideh-themecolor:background1;
 mso-border-insideh-themeshade:166;mso-border-insidev:.5pt solid #A6A6A6;
 mso-border-insidev-themecolor:background1;mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;mso-border-alt:
  solid #A6A6A6 .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  166;padding:0in 5.4pt 0in 5.4pt;height:.1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Log in as the user</span><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Configure Outlook and synchronize (use RPC
  configuration if available).</span><span style='font-size:9.0pt;mso-bidi-font-size:
  11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Rebuild<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Attach any previously backed up PST files to Outlook.</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Rebuild<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Restore user data to appropriate locations<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;background:#D9D9D9;mso-background-themecolor:
  background1;mso-background-themeshade:217;padding:0in 5.4pt 0in 5.4pt;
  height:.1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Domain<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Setup Network and/or local Printers (if x64 configure
  via direct IP).</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Laptop<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>If wireless enabled configure customer facility <span
  class=SpellE>WiFi</span>. (<span class=GramE>if</span> not in KB disregard).</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Laptop/Remote<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Test login to Virtual Office to a generic Desktop.</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Laptop<o:p></o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Test login to customers additional Remote Access
  Solution.</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Install all proprietary customer software. (copy media
  to LFS/Customer Utility if applicable)</span><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Copy install media to C:\Installation_Files</span><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Pin Outlook to Start Menu, Taskbar (Quick Launch) and
  Desktop.</span><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
  font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Add custom software links to Desktop<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Verify hibernation, verify hard disk do not turn
  off,<span style='mso-spacerun:yes'>  </span>and sleep are off (<span
  class=SpellE>WinXP</span>) or set to 0 minutes (Win7)<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;mso-yfti-lastrow:yes;height:.1in'>
  <td width=45 valign=top style='width:34.1pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=70 valign=top style='width:52.3pt;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=621 valign=top style='width:465.7pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt;height:
  .1in'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Run QC Script</span><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Pre-Release to
Customer<o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid #A6A6A6 .5pt;
 mso-border-themecolor:background1;mso-border-themeshade:166;mso-yfti-tbllook:
 1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #A6A6A6;
 mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:166;
 mso-border-insidev:.5pt solid #A6A6A6;mso-border-insidev-themecolor:background1;
 mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=734 valign=top style='width:7.65in;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;mso-border-alt:
  solid #A6A6A6 .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'>Record<b style='mso-bidi-font-weight:normal'> </b>the
  application name and applicable activation keys for all installed software.<o:p></o:p></span></p>
  <table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=735
   style='width:551.5pt;border-collapse:collapse;border:none;mso-yfti-tbllook:
   1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #BFBFBF;
   mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:
   191'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=719 valign=top style='width:539.25pt;border:none;border-bottom:
    solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:
    191;mso-border-bottom-alt:solid #BFBFBF .5pt;mso-border-bottom-themecolor:
    background1;mso-border-bottom-themeshade:191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1'>
    <td width=719 valign=top style='width:539.25pt;border:none;border-bottom:
    solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:
    191;mso-border-top-alt:solid #BFBFBF .5pt;mso-border-top-themecolor:background1;
    mso-border-top-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
    mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
    mso-border-bottom-alt:solid #BFBFBF .5pt;mso-border-bottom-themecolor:background1;
    mso-border-bottom-themeshade:191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2'>
    <td width=719 valign=top style='width:539.25pt;border:none;border-bottom:
    solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:
    191;mso-border-top-alt:solid #BFBFBF .5pt;mso-border-top-themecolor:background1;
    mso-border-top-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
    mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
    mso-border-bottom-alt:solid #BFBFBF .5pt;mso-border-bottom-themecolor:background1;
    mso-border-bottom-themeshade:191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3'>
    <td width=719 valign=top style='width:539.25pt;border:none;border-bottom:
    solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:
    191;mso-border-top-alt:solid #BFBFBF .5pt;mso-border-top-themecolor:background1;
    mso-border-top-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
    mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
    mso-border-bottom-alt:solid #BFBFBF .5pt;mso-border-bottom-themecolor:background1;
    mso-border-bottom-themeshade:191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:4'>
    <td width=719 valign=top style='width:539.25pt;border:none;border-bottom:
    solid #BFBFBF 1.0pt;mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:
    191;mso-border-top-alt:solid #BFBFBF .5pt;mso-border-top-themecolor:background1;
    mso-border-top-themeshade:191;mso-border-top-alt:solid #BFBFBF .5pt;
    mso-border-top-themecolor:background1;mso-border-top-themeshade:191;
    mso-border-bottom-alt:solid #BFBFBF .5pt;mso-border-bottom-themecolor:background1;
    mso-border-bottom-themeshade:191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes'>
    <td width=719 valign=top style='width:539.25pt;border:none;mso-border-top-alt:
    solid #BFBFBF .5pt;mso-border-top-themecolor:background1;mso-border-top-themeshade:
    191;padding:0in 5.4pt 0in 5.4pt'>
    <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;
    line-height:200%'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;
    line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;font-family:
  "Tahoma","sans-serif"'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Additional
Notes/Comments<o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='width:551.5pt;border-collapse:collapse;border:none;mso-border-alt:solid #BFBFBF .5pt;
 mso-border-themecolor:background1;mso-border-themeshade:191;mso-yfti-tbllook:
 1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #BFBFBF;
 mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:191;
 mso-border-insidev:.5pt solid #BFBFBF;mso-border-insidev-themecolor:background1;
 mso-border-insidev-themeshade:191'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=734 valign=top style='width:7.65in;border:solid #BFBFBF 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:191;mso-border-alt:
  solid #BFBFBF .5pt;mso-border-themecolor:background1;mso-border-themeshade:
  191;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
  "Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>QC Testing<o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='width:551.5pt;background:#D9D9D9;mso-background-themecolor:background1;
 mso-background-themeshade:217;border-collapse:collapse;border:none;mso-border-alt:
 solid white .5pt;mso-border-themecolor:background1;mso-yfti-tbllook:1184;
 mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid white;
 mso-border-insideh-themecolor:background1;mso-border-insidev:.5pt solid white;
 mso-border-insidev-themecolor:background1'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=97 valign=top style='width:72.9pt;border:solid white 1.0pt;
  mso-border-themecolor:background1;mso-border-alt:solid white .5pt;mso-border-themecolor:
  background1;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>Laptop ONLY<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  font-family:"Tahoma","sans-serif"'>All<o:p></o:p></span></p>
  </td>
  <td width=570 valign=top style='width:427.5pt;border:solid white 1.0pt;
  mso-border-themecolor:background1;border-left:none;mso-border-left-alt:solid white .5pt;
  mso-border-left-themecolor:background1;mso-border-alt:solid white .5pt;
  mso-border-themecolor:background1;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Review
  output for QC script.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Disconnect
  from LAN &amp; Power<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Log
  in as user.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Verify
  My Documents folder contains data.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Verify
  Mapped Drives<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Verify
  Outlook connects and email is there.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Verify
  Printers exist.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Verify
  Antivirus is installed and the definition date is within 5 days.<o:p></o:p></span></p>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><span style='font-size:9.0pt;font-family:"Tahoma","sans-serif"'>Enable
  DHCP.<o:p></o:p></span></p>
  </td>
  <td width=67 valign=top style='width:.7in;border:solid white 1.0pt;
  mso-border-themecolor:background1;border-left:none;mso-border-left-alt:solid white .5pt;
  mso-border-left-themecolor:background1;mso-border-alt:solid white .5pt;
  mso-border-themecolor:background1;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=97 valign=top style='width:72.9pt;border:solid white 1.0pt;
  mso-border-themecolor:background1;border-top:none;mso-border-top-alt:solid white .5pt;
  mso-border-top-themecolor:background1;mso-border-alt:solid white .5pt;
  mso-border-themecolor:background1;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=570 valign=top style='width:427.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.0pt;mso-border-bottom-themecolor:background1;
  border-right:solid white 1.0pt;mso-border-right-themecolor:background1;
  mso-border-top-alt:solid white .5pt;mso-border-top-themecolor:background1;
  mso-border-left-alt:solid white .5pt;mso-border-left-themecolor:background1;
  mso-border-alt:solid white .5pt;mso-border-themecolor:background1;padding:
  0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Attach a copy of
  this completed document to the ticket.<o:p></o:p></span></b></p>
  </td>
  <td width=67 valign=top style='width:.7in;border-top:none;border-left:none;
  border-bottom:solid white 1.0pt;mso-border-bottom-themecolor:background1;
  border-right:solid white 1.0pt;mso-border-right-themecolor:background1;
  mso-border-top-alt:solid white .5pt;mso-border-top-themecolor:background1;
  mso-border-left-alt:solid white .5pt;mso-border-left-themecolor:background1;
  mso-border-alt:solid white .5pt;mso-border-themecolor:background1;padding:
  0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>
  <td width=97 valign=top style='width:72.9pt;border:solid white 1.0pt;
  mso-border-themecolor:background1;border-top:none;mso-border-top-alt:solid white .5pt;
  mso-border-top-themecolor:background1;mso-border-alt:solid white .5pt;
  mso-border-themecolor:background1;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=570 valign=top style='width:427.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.0pt;mso-border-bottom-themecolor:background1;
  border-right:solid white 1.0pt;mso-border-right-themecolor:background1;
  mso-border-top-alt:solid white .5pt;mso-border-top-themecolor:background1;
  mso-border-left-alt:solid white .5pt;mso-border-left-themecolor:background1;
  mso-border-alt:solid white .5pt;mso-border-themecolor:background1;padding:
  0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  normal'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:10.5pt;font-family:"Tahoma","sans-serif"'>Update ticket
  and if Field Services required transfer for Dispatch.<o:p></o:p></span></b></p>
  </td>
  <td width=67 valign=top style='width:.7in;border-top:none;border-left:none;
  border-bottom:solid white 1.0pt;mso-border-bottom-themecolor:background1;
  border-right:solid white 1.0pt;mso-border-right-themecolor:background1;
  mso-border-top-alt:solid white .5pt;mso-border-top-themecolor:background1;
  mso-border-left-alt:solid white .5pt;mso-border-left-themecolor:background1;
  mso-border-alt:solid white .5pt;mso-border-themecolor:background1;padding:
  0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
normal'><span style='font-size:9.0pt;mso-bidi-font-size:10.5pt;font-family:
"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:9.0pt;mso-bidi-font-size:11.0pt;line-height:115%;font-family:
"Tahoma","sans-serif"'>This has been completed by:<o:p></o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=735
 style='width:551.5pt;border-collapse:collapse;border:none;mso-border-alt:solid #A6A6A6 .5pt;
 mso-border-themecolor:background1;mso-border-themeshade:166;mso-yfti-tbllook:
 1184;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:.5pt solid #A6A6A6;
 mso-border-insideh-themecolor:background1;mso-border-insideh-themeshade:166;
 mso-border-insidev:.5pt solid #A6A6A6;mso-border-insidev-themecolor:background1;
 mso-border-insidev-themeshade:166'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=67 valign=top style='width:.7in;border-top:none;border-left:none;
  border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-bottom-alt:solid #A6A6A6 .5pt;
  mso-border-bottom-themecolor:background1;mso-border-bottom-themeshade:166;
  mso-border-right-alt:solid #A6A6A6 .5pt;mso-border-right-themecolor:background1;
  mso-border-right-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=324 valign=top style='width:243.0pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:200%'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;line-height:200%;font-family:
  "Tahoma","sans-serif"'>TECHNICIAN<o:p></o:p></span></b></p>
  </td>
  <td width=343 valign=top style='width:257.4pt;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-left:none;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-bottom:0in;margin-bottom:.0001pt;
  text-align:center;line-height:200%'><b style='mso-bidi-font-weight:normal'><span
  style='font-size:9.0pt;mso-bidi-font-size:11.0pt;line-height:200%;font-family:
  "Tahoma","sans-serif"'>QUALITY CONTROL<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=67 valign=top style='width:.7in;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'>Name:<o:p></o:p></span></b></p>
  </td>
  <td width=324 valign=top style='width:243.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=343 valign=top style='width:257.4pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>
  <td width=67 valign=top style='width:.7in;border:solid #A6A6A6 1.0pt;
  mso-border-themecolor:background1;mso-border-themeshade:166;border-top:none;
  mso-border-top-alt:solid #A6A6A6 .5pt;mso-border-top-themecolor:background1;
  mso-border-top-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'>Date:<o:p></o:p></span></b></p>
  </td>
  <td width=324 valign=top style='width:243.0pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=343 valign=top style='width:257.4pt;border-top:none;border-left:
  none;border-bottom:solid #A6A6A6 1.0pt;mso-border-bottom-themecolor:background1;
  mso-border-bottom-themeshade:166;border-right:solid #A6A6A6 1.0pt;mso-border-right-themecolor:
  background1;mso-border-right-themeshade:166;mso-border-top-alt:solid #A6A6A6 .5pt;
  mso-border-top-themecolor:background1;mso-border-top-themeshade:166;
  mso-border-left-alt:solid #A6A6A6 .5pt;mso-border-left-themecolor:background1;
  mso-border-left-themeshade:166;mso-border-alt:solid #A6A6A6 .5pt;mso-border-themecolor:
  background1;mso-border-themeshade:166;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal style='margin-bottom:0in;margin-bottom:.0001pt;line-height:
  200%'><b style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
  mso-bidi-font-size:11.0pt;line-height:200%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
line-height:115%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><!--[if supportFields]><span style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Laptop__ <!--[if supportFields]><span
style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Power Supply_____ <!--[if supportFields]><span
style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Bag<span style='mso-tab-count:1'>     </span>________
<!--[if supportFields]><span style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Dock_________<span style='mso-spacerun:yes'> 
</span><!--[if supportFields]><span style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Reusable Shipping Box___________</p>

<p class=MsoNormal><!--[if supportFields]><span style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Desktop___<span style='mso-spacerun:yes'>  
</span><!--[if supportFields]><span style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Monitor_________<span
style='mso-spacerun:yes'>  </span><!--[if supportFields]><span
style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Software ____________________ <!--[if supportFields]><span
style='mso-element:field-begin'></span><span
style='mso-spacerun:yes'> </span>FORMCHECKBOX <![endif]--><!--[if gte mso 9]><xml>
 <w:data>FFFFFFFF650000001400060043006800650063006B003100000000000000000000000000000000000000000000000000</w:data>
</xml><![endif]--><!--[if supportFields]><span style='mso-element:field-end'></span><![endif]--><span
style='mso-spacerun:yes'> </span>Other ________________________</p>

<p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:11.0pt;
line-height:115%;font-family:"Tahoma","sans-serif"'><o:p>&nbsp;</o:p></span></p>

</div>

</body>

</html>

"@
$webpage | out-file "C:\reports.html"
