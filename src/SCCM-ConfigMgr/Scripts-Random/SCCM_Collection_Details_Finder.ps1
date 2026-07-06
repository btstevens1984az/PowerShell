# Purpose: SCCM Collection Details Finder — Configuration Manager collections and deployments.
# SCCM DEVICE COLLECTION DETAILS FINDER


# This script is used to gather SCCM DEVICE collection membership information.


# The supported device collection memberships that can be queried are DIRECT, INCLUDE COLLECTION and EXCLUDE COLLECTION
# The script retrieve the membership details including Collection IDs, Direct Membership Clients, Include Collection names,
# Include Collection IDs, Exclude Collection names, and Exclude Collection IDs.
# For every collection, once the information is collected, it exports the output to a csv file.
# Every search for a device collection retrieves the collection membership details, and append to the same csv file.

## HOW TO USE ##
# PREREQ: To use this script, ensure the SCCM 2012 console is installed locally, and the updated SCCM cmdlet library is installed.
# To use the script, replace the SCCM site code �XXX� to your actual site code in the script.
# Also, change the location and the filename of the csv file as desired.

# Import the SCCM powershell module
Import-Module(Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
$script:SiteCode = �XXX� # Enter your Site Code
Set-Location($SiteCode + �:�)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = �SCCM Collection Details Finder�
$form.Size = New-Object System.Drawing.Size(330,200)
$form.StartPosition = �CenterScreen�

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(85,80)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = �OK�
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(160,80)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = �Cancel�
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = �Please enter a Device Collection Name:�
$form.Controls.Add($label)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(30,140)
$label2.Size = New-Object System.Drawing.Size(280,20)
$label2.Text = �Created by Talha Qamar | http://www.talhaqamar.com&#8221;
$form.Controls.Add($label2)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(293,20)
$form.Controls.Add($textBox)

$form.Topmost = $True

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
$CollectionName = $textBox.Text
#�Collection Name:�, $CollectionName | Out-file C:\Scripts\test.csv
$CollectionID = Get-CMCollection -Name $CollectionName | foreach { $_.CollectionID }

if ($CollectionID -ne $null)
{
$DirectMbrshp = Get-CMDeviceCollectionDirectMembershipRule -Name $CollectionName | foreach { $_.RuleName }
$IncludeMbrshpCollection = Get-CMDeviceCollectionIncludeMembershipRule -CollectionName $CollectionName | foreach { $_.RuleName }
$IncludeMbrshpCollectionID = Get-CMDeviceCollectionIncludeMembershipRule -CollectionName $CollectionName | foreach { $_.IncludeCollectionID }
$ExcludeMbrshpCollection = Get-CMDeviceCollectionExcludeMembershipRule -CollectionName $CollectionName | foreach { $_.RuleName }
$ExcludeMbrshpCollectionID = Get-CMDeviceCollectionExcludeMembershipRule -CollectionName $CollectionName | foreach { $_.ExcludeCollectionID }

[pscustomobject]@{
CollectionName = $CollectionName
CollectionID = $CollectionID
DirectMbrship = (@($DirectMbrshp) -join �,�)
IncludeMbrship_Collection = (@($IncludeMbrshpCollection) -join �,�)
IncludeMbrship_ID = (@($IncludeMbrshpCollectionID) -join �,�)
ExcludeMbrship_Collection = (@($ExcludeMbrshpCollection) -join �,�)
ExcludeMbrship_ID = (@($ExcludeMbrshpCollectionID) -join �,�)
} | Export-Csv -notype C:\Scripts\CollectIt.csv -Append

}
}