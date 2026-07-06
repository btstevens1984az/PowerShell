# Purpose: Install-Java817164bit — PowerShell automation.
Function Install-Java817164bit {
# Download and silent install Java Runtime Environement

# working directory path
$workd = "C:\Temp"

# Check if work directory exists if not create it
If (!(Test-Path -Path $workd -PathType Container))
{ 
New-Item -Path $workd  -ItemType directory 
}

#create config file for silent install
$text = '
INSTALL_SILENT=Enable
AUTO_UPDATE=Enable
SPONSORS=Disable
REMOVEOUTOFDATEJRES=1
'
$text | Set-Content "$workd\jreinstall.cfg"
    
#download executable, this is the small online installer
$source = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=233172_512cd62ec5174c3487ac17c61aaa89e8"
$destination = "$workd\jreInstall.exe"
$client = New-Object System.Net.WebClient
$client.DownloadFile($source, $destination)

#install silently
Start-Process -FilePath "$workd\jreInstall.exe" -ArgumentList INSTALLCFG="$workd\jreinstall.cfg" -ErrorAction SilentlyContinue

# Wait 120 Seconds for the installation to finish
Start-Sleep -s 30 -ErrorAction SilentlyContinue

# Remove the installer
rm -Force $workd\jre* -ErrorAction SilentlyContinue
}
