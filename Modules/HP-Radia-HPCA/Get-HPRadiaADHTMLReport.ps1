<#
.Synopsis 
    Runs a series of nmap scans against a list of IP addresses or subnets 
.Description 
    Ingests a list of host names, IP addresses and/or sub nets and launches an nmap scan
    against each one in sequence. Can be fed multiple text files either through
    FileInfo objects or on the pipeline. Output is sent to an XML file in the format of
    [Host or subnet].xml in the current working dir. 
    By default will use reasonable sane nmap arguments (-F -T3) but custom arguments
    can be specified using the parameter -Arguments [args]
    If the nmap executable is not accessible from the PATH variable an alternative
    location can be specified using the parameter -Location [nmap location]
    TO-DO
    Validate that host/subnet is valid before starting nmap
    Ability to feed in CSV with additional metadata?
.Parameter InputObject  
    Either 1) A string of host names/IP Addresses/Subnets OR
           2) One or more FileInfo objects representing text files
.Parameter Arguments
    Specifies the arguments that will be passed to nmap
    Default: -sT -T3
.Parameter OutDir
    Specifies the directory nmap should output XML files to
    Default: Current working directory
.Parameter Location
    The location of the nmap executable
    Default: nmap.exe (assumes nmap directory is in the PATH)
.Parameter CSV
    Specifies the name of the column in the CSV that contains the target
    Default: Not set, setting this parameter will cause #any text file# to
             be processed as a CSV file
.Inputs
    System.String
        You can pipe a string containing a host, or a coimma-separated
    System.IO.FileInfo
        You can pipe in System.IO.FileInfo object(s) provided by cmdlets
        like Get-ChildItem
    Microsoft.ActiveDirectory.Management.ADComputer
        You can pipe in object(s) returned from the Get-ADComputer Active
        Directory cmdlet
.Outputs
    System.Object[]
        This script returns a PSObject with the following properties:
            Target - The target of the nmap scan
            Arguments - The command line args passed to nmap
            StartTime - The start time of the scan
            FinishTime - The end time of the scan
            Duration - The duration of the scan
            OutFile - The location of the XML file output by nmap
            Hash - The SHA254 hash of the OutFile
.Example 
    dir *.txt | .\Perform-NMAPScan
    Get an object containing text files in working directory, read files
    and run nmap against each host specified in each file (one per line)
.Example
    dir *.csv | .\Perform-NMAPScan -CSV Target
    Get an object containing text files in working directory,
    uses the column "Target" to create list of hosts
        Target, HostName
        246.159.155.223, "Google DNS"
        scanme.nmap.org,"Scan Me"
        203.135.6.89, "My Router"
.Example
    .\Perform-NMAPScan 203.232.155.49/24 -Arguments "-T5 -A -sC -sS"
    Run nmap against a subnet with custom arguments
.Example
    .\Perform-NMAPScan 21.64.223.248 -Arguments "-p 445 --script smb-vuln-ms17-010" -OutDir "2017-11-26"
    Check host 203.135.6.89 for vulnerability to EternalBlue and output XML to dated directory
.Example
    .\Perform-NMAPScan "scanme.nmap.org,122.47.44.95"
    Run nmap against a set of hosts and/or subnets
.Example
    Get-ADComputer -Filter {Name -like "HostName"} | .\Perform-NMAPScan.PS1
    Run nmap against objects returned by Get-ADComputer
.Example
    "scanme.nmap.org,251.128.230.229" | .\Perform-NMAPScan -Location "C:\nmap\nmap.exe"
    Define the location of the nmap executable if it isn't available in PATH
Written by: Ethan Sterling
Find me on:
* Twitter  : https://twitter.com/esterling_
* Medium   : https://medium.com/@esterling_
License:
The MIT License (MIT)
Copyright (c) 2017 Ethan Sterling
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
Change Log:
V0.1 - 23/11/2017 - Initial version
V0.2 - 25/11/2017 - Added handler for ADComputer objects
v0.3 - 26/11/2017 - Change handling of input to make it more robust, support passing of 
                      arrays of different data types into script
                      -OutDir (ex. -OutDir "C:\NmapResults\2017-11-26")
#>
#Get-HPRadiaADHTMLReport
#cd $env:windir
#Install-Module -Name ActiveDirectory -Force
#Import-Module -Name ActiveDirectory -Force
Function Get-HPRadiaADHTMLReport {
$HPCATestTeam = Get-ADGroupMember "HPCA_Test_Team" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCATestTeam).count
$HPCATestTeamName = Get-AdGroup "HPCA_Test_Team" -Properties * | Select-Object -Property Name | ft -a -h

$HPCACRITICALTeam = Get-ADGroupMember "HPCA_CRITICAL_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCACRITICALTeam).count
$HPCACRITICALTeamName = Get-AdGroup "HPCA_CRITICAL_Patch" -Properties * | Select-Object -Property Name | ft -a -h

$HPCADEFAULTPatch = Get-ADGroupMember "HPCA_DEFAULT_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCADEFAULTPatch).count
$HPCADEFAULTPatchName = Get-AdGroup "HPCA_DEFAULT_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCADisabledComputers = Get-ADGroupMember "HPCA_Disabled_Computers" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCADisabledComputers).count
$HPCADisabledComputersName = Get-AdGroup "HPCA_Disabled_Computers" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAEnterprisePatch = Get-ADGroupMember "HPCA_Enterprise_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAEnterprisePatch).count
$HPCAEnterprisePatchName = Get-AdGroup "HPCA_Enterprise_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAFivePercentPatch = Get-ADGroupMember "HPCA_FivePercent_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAFivePercentPatch).count
$HPCAFivePercentPatchName = Get-AdGroup "HPCA_FivePercent_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAInDeploymentPatch = Get-ADGroupMember "HPCA_InDeployment_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAInDeploymentPatch).count
$HPCAInDeploymentPatchName = Get-AdGroup "HPCA_InDeployment_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAPhaseOnePatch = Get-ADGroupMember "HPCA_PhaseOne_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAPhaseOnePatch).count
$HPCAPhaseOnePatchName = Get-AdGroup "HPCA_PhaseOne_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeChrome = Get-ADGroupMember "HPCA_Exclude_Chrome" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeChrome).count
$HPCAExcludeChromeName = Get-AdGroup "HPCA_Exclude_Chrome" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeFirefox = Get-ADGroupMember "HPCA_Exclude_Firefox" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeFirefox).count
$HPCAExcludeFirefoxName = Get-AdGroup "HPCA_Exclude_Firefox" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeJava = Get-ADGroupMember "HPCA_Exclude_Java" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeJava).count
$HPCAExcludeJavaname = Get-AdGroup "HPCA_Exclude_Java" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeJavaClimatec = Get-ADGroupMember "HPCA_Exclude_Java_Climatec" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeJavaClimatec).count
$HPCAExcludeJavaClimatecName = Get-AdGroup "HPCA_Exclude_Java_Climatec" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeJavaImageNow = Get-ADGroupMember "HPCA_Exclude_Java_ImageNow" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeJavaImageNow).count
$HPCAExcludeJavaImageNowName = Get-AdGroup "HPCA_Exclude_Java_ImageNow" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeJavaLawson = Get-ADGroupMember "HPCA_Exclude_Java_Lawson" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeJavaLawson).count
$HPCAExcludeJavaLawsonName = Get-AdGroup "HPCA_Exclude_Java_Lawson" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeKB4048960 = Get-ADGroupMember "HPCA_Exclude_KB4048960" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeKB4048960).count
$HPCAExcludeKB4048960Name = Get-AdGroup "HPCA_Exclude_KB4048960" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeNKDevice = Get-ADGroupMember "HPCA_Exclude_NKDevices" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeNKDevice).count
$HPCAExcludeNKDeviceName = Get-AdGroup "HPCA_Exclude_NKDevices" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAExcludeOfficeViewers = Get-ADGroupMember "HPCA_Exclude_Viewers_OFC" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAExcludeOfficeViewers).count
$HPCAExcludeOfficeViewersName = Get-AdGroup "HPCA_Exclude_Viewers_OFC" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAJavaUninstall = Get-ADGroupMember "HPCA_Java _uninstall" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAJavaUninstall).count
$HPCAJavaUninstallName = Get-AdGroup "HPCA_Java _uninstall" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMSUpdates2017 = Get-ADGroupMember "HPCA_MS_Updates_2017" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMSUpdates2017).count
$HPCAMSUpdates2017Name = Get-AdGroup "HPCA_MS_Updates_2017" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMSUpdates2018 = Get-ADGroupMember "HPCA_MS_Updates_2018" -Recursive | Where-Object -Property ObjectClass -EQ "Computer" | Select-Object -Property name | ft -a -h 
($HPCAMSUpdates2018).count
$HPCAMSUpdates2018name = Get-AdGroup "HPCA_MS_Updates_2018" -Properties * | Select-Object -Property Name | ft -a -h


$HPCACRHPatch = Get-ADGroupMember "HPCA_CRH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCACRHPatch).count
$HPCACRHPatchName = Get-AdGroup "HPCA_CRH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMGMCPatch = Get-ADGroupMember "HPCA_MGMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMGMCPatch).count
$HPCAMGMCPatchName = Get-AdGroup "HPCA_MGMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAPHXPatch = Get-ADGroupMember "HPCA_SITE_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAPHXPatch).count
$HPCAPHXPatchname = Get-AdGroup "HPCA_SITE_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCARenoPatch = Get-ADGroupMember "HPCA_RENO_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCARenoPatch).count
$HPCARenoPatchName = Get-AdGroup "HPCA_RENO_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJPHXPatch = Get-ADGroupMember "HPCA_SITE2_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJPHXPatch).count
$HPCASJPHXPatchName = Get-AdGroup "HPCA_SITE2_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASMRMCPatch = Get-ADGroupMember "HPCA_SMRMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASMRMCPatch).count
$HPCASMRMCPatchName = Get-AdGroup "HPCA_SMRMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASRDHPatch = Get-ADGroupMember "HPCA_SRDH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASRDHPatch).count
$HPCASRDHPatchName = Get-AdGroup "HPCA_SRDH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCACorpPatch = Get-ADGroupMember "HPCA_CORP_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCACorpPatch).count
$HPCACorpPatchName = Get-AdGroup "HPCA_CORP_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCADHMFPatch = Get-ADGroupMember "HPCA_DHMF_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCADHMFPatch).count
$HPCADHMFPatchName = Get-AdGroup "HPCA_DHMF_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCADSCPatch = Get-ADGroupMember "HPCA_DSC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCADSCPatch).count
$HPCADSCPatchName = Get-AdGroup "HPCA_DSC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMethPatch = Get-ADGroupMember "HPCA_METH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMethPatch).count
$HPCAMethPatchName = Get-AdGroup "HPCA_METH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMGHPatch = Get-ADGroupMember "HPCA_MGH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMGHPatch).count
$HPCAMethPatchName = Get-AdGroup "HPCA_MGH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMHFPatch = Get-ADGroupMember "HPCA_MHF_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMHFPatch).count
$HPCAMHFPatchName = Get-AdGroup "HPCA_MHF_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMHSPatch = Get-ADGroupMember "HPCA_MHS_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMHSPatch).count
$HPCAMHSPatchName = Get-AdGroup "HPCA_MHS_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMMCMPatch = Get-ADGroupMember "HPCA_MMCM_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMMCMPatch).count
$HPCAMMCMPatchName = Get-AdGroup "HPCA_MMCM_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMSJPatch = Get-ADGroupMember "HPCA_MSJ_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMSJPatch).count
$HPCAMSJPatchName = Get-AdGroup "HPCA_MSJ_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMTSJPatch = Get-ADGroupMember "HPCA_MTSJ_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMTSJPatch).count
$HPCAMTSJPatchName = Get-AdGroup "HPCA_MTSJ_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCARORCPatch = Get-ADGroupMember "HPCA_RORC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCARORCPatch).count
$HPCARORCPatchName = Get-AdGroup "HPCA_RORC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASEQPatch = Get-ADGroupMember "HPCA_SEQ_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASEQPatch).count
$HPCASEQPatchName = Get-AdGroup "HPCA_SEQ_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASFMHPatch = Get-ADGroupMember "HPCA_SFMH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASFMHPatch).count
$HPCASFMHPatchName = Get-AdGroup "HPCA_SFMH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJBHPatch = Get-ADGroupMember "HPCA_SJBH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJBHPatch).count
$HPCASJBHPatchName = Get-AdGroup "HPCA_SJBH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJMCHPatch = Get-ADGroupMember "HPCA_SJMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJMCHPatch).count
$HPCASJMCHPatchName = Get-AdGroup "HPCA_SJMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJRHPatch = Get-ADGroupMember "HPCA_SJRH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJRHPatch).count
$HPCASJRHPatchName = Get-AdGroup "HPCA_SJRH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASMCPatch = Get-ADGroupMember "HPCA_SMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASMCPatch).count
$HPCASMCPatchName = Get-AdGroup "HPCA_SMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASMSFPatch = Get-ADGroupMember "HPCA_SMSF_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASMSFPatch).count
$HPCASMSFPatchName = Get-AdGroup "HPCA_SMSF_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASNMHPatch = Get-ADGroupMember "HPCA_SNMH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASNMHPatch).count
$HPCASNMHPatchName = Get-AdGroup "HPCA_SNMH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAWBFSPatch = Get-ADGroupMember "HPCA_WBFS_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAWBFSPatch).count
$HPCAWBFSPatchName = Get-AdGroup "HPCA_WBFS_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAWHCPatch = Get-ADGroupMember "HPCA_WHC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAWHCPatch).count
$HPCAWHCPatchName = Get-AdGroup "HPCA_WHC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMMCRPatch = Get-ADGroupMember "HPCA_MMCR_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMMCRPatch).count
$HPCAMMCRPatchName = Get-AdGroup "HPCA_MMCR_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMMSPatch = Get-ADGroupMember "HPCA_MMS_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMMSPatch).count
$HPCAMMSPatchName = Get-AdGroup "HPCA_MMS_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASECHPatch = Get-ADGroupMember "HPCA_SECH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASECHPatch).count
$HPCASECHPatchName = Get-AdGroup "HPCA_SECH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAAGCHPatch = Get-ADGroupMember "HPCA_AGCH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAAGCHPatch).count
$HPCAAGCHPatchName = Get-AdGroup "HPCA_AGCH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCABMHPatch = Get-ADGroupMember "HPCA_BMH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCABMHPatch).count
$HPCABMHPatchName = Get-AdGroup "HPCA_BMH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCACHMCPatch = Get-ADGroupMember "HPCA_CHMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCACHMCPatch).count
$HPCACHMCPatchName = Get-AdGroup "HPCA_CHMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCACHSBCPatch = Get-ADGroupMember "HPCA_CHSB_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCACHSBCPatch).count
$HPCACHSBCPatchName = Get-AdGroup "HPCA_CHSB_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAGMHPatch = Get-ADGroupMember "HPCA_GMH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAGMHPatch).count
$HPCAGMHPatchName = Get-AdGroup "HPCA_GMH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAIHOPatch = Get-ADGroupMember "HPCA_IHO_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAIHOPatch).count
$HPCAIHOPatchname = Get-AdGroup "HPCA_IHO_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMHBPatch = Get-ADGroupMember "HPCA_MHB_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMHBPatch).count
$HPCAMHBPatchName = Get-AdGroup "HPCA_MHB_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMMCPatch = Get-ADGroupMember "HPCA_MMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMMCPatch).count
$HPCAMMCPatchName = Get-AdGroup "HPCA_MMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAMSHPatch = Get-ADGroupMember "HPCA_MSH_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAMSHPatch).count
$HPCAMSHPatchName = Get-AdGroup "HPCA_MSH_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCANHMCPatch = Get-ADGroupMember "HPCA_NHMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCANHMCPatch).count
$HPCANHMCPatchName = Get-AdGroup "HPCA_NHMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCAPASPatch = Get-ADGroupMember "HPCA_PAS_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCAPASPatch).count
$HPCAPASPatchName = Get-AdGroup "HPCA_PAS_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASBMCPatch = Get-ADGroupMember "HPCA_SBMC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASBMCPatch).count
$HPCASBMCPatchName = Get-AdGroup "HPCA_SBMC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJPVPatch = Get-ADGroupMember "HPCA_SJPV_Patch" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJPVPatch).count
$HPCASJPVPatchName = Get-AdGroup "HPCA_SJPV_Patch" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASJRMPatch = Get-ADGroupMember "HPCA_SJRM_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASJRMPatch).count
$HPCASJRMPatchName = Get-AdGroup "HPCA_SJRM_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASMHPPatch = Get-ADGroupMember "HPCA_SMHP_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASMHPPatch).count
$HPCASMHPPatchName = Get-AdGroup "HPCA_SMHP_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASMLBPatch = Get-ADGroupMember "HPCA_SMLB_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASMLBPatch).count
$HPCASMLBPatchName = Get-AdGroup "HPCA_SMLB_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCATRCPatch = Get-ADGroupMember "HPCA_TRC_PATCH" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCATRCPatch).count
$HPCATRCPatchName = Get-AdGroup "HPCA_TRC_PATCH" -Properties * | Select-Object -Property Name | ft -a -h


$HPCASATGROUP = Get-ADGroupMember "HPCA_SAT_GRP" -Recursive | Where-Object -Property ObjectClass -EQ "computer" | Select-Object -Property name | ft -a -h 
($HPCASATGROUP).count
$HPCASATGROUPName = Get-AdGroup "HPCA_SAT_GRP" -Properties * | Select-Object -Property Name | ft -a -h


#List the edmPolicy Attributes per HPCA Group
$HPCAInDeploymentPatchedmPolicy = Get-ADGroup -Identity "HPCA_InDeployment_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCACRITICALPatchedmPolicy = Get-ADGroup -Identity "HPCA_CRITICAL_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCADEFAULTPatchedmPolicy = Get-ADGroup -Identity "HPCA_DEFAULT_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCADisabledComputersPatchedmPolicy = Get-ADGroup -Identity "HPCA_Disabled_Computers" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
$HPCAEnterprisePatchedmPolicy = Get-ADGroup -Identity "HPCA_Enterprise_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCAFivePercentPatchedmPolicy = Get-ADGroup -Identity "HPCA_FivePercent_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCAPhaseOnePatchedmPolicy = Get-ADGroup -Identity "HPCA_PhaseOne_Patch" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
$HPCATestTeamedmPolicy = Get-ADGroup -Identity "HPCA_Test_Team" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCATestBrandonedmPolicy = Get-ADGroup -Identity "HPCA_Test_Brandon" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
$HPCAMSUpdates2017edmPolicy = Get-ADGroup -Identity "HPCA_MS_Updates_2017" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
$HPCAMSUpdates2018edmPolicy = Get-ADGroup -Identity "HPCA_MS_Updates_2018" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
#$HPCAJavaUninstalledmPolicy = Get-ADGroup -Identity "HPCA_Java _uninstall" -Properties * | Select-Object -Property edmPolicy -ExpandProperty edmPolicy | ft -a -h
}