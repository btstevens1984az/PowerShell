# Purpose: Create-WqlQuerySetting — General-purpose PowerShell utilities.
function Create-WqlQuerySetting {
    param (
    [object]$CI,
    [string]$WqlQuerySettingClass,
    [string]$WqlQuerySettingNamspace,
    [string]$WqlQuerySettingWhere,
    [string]$WqlQuerySettingProperty
    )

    #Set the WqlQuerySetting object information
    $WqlQuerySettingDataType = ([Microsoft.ConfigurationManagement.DesiredConfiguration.Rules.ScalarDataType]::Int64)
    $WqlQuerySettingLogicalName = "WqlSetting_$([Guid]::NewGuid())"
    $WqlQuerySettingName = "$WqlQuerySettingClass"+"_"+"$WqlQuerySettingProperty"
    $WqlQuerySettingDescription = "Scripted setting"

    #Create the WqlQuerySetting object and set the properties
    $WqlQuerySetting = New-Object -TypeName Microsoft.ConfigurationManagement.DesiredConfiguration.Settings.WqlQuerySetting -ArgumentList $WqlQuerySettingDataType,$WqlQuerySettingLogicalName,$WqlQuerySettingName,$WqlQuerySettingDescription
    $WqlQuerySetting.Class = $WqlQuerySettingClass
    $WqlQuerySetting.Namespace = $WqlQuerySettingNamspace
    $WqlQuerySetting.Where = $WqlQuerySettingWhere
    $WqlQuerySetting.Property = $WqlQuerySettingProperty
    
    #Load the SDMPackageXML of the CI
    $CISDMPackageXML = New-Object -TypeName XML
    $CISDMPackageXML.LoadXml($($CI.SDMPackageXML))

    #Create the XmlWriterSettings object and set the properties
    $XMLWriterSettings = New-Object System.Xml.XmlWriterSettings 
    $XMLWriterSettings.Indent = $true 
    $XMLWriterSettings.OmitXmlDeclaration = $false 
    $XMLWriterSettings.NewLineOnAttributes = $true 
 
    #Create the new XmlWriter 
    $XMLWriter = [system.xml.XmlWriter]::Create("C:\Temp\WqlQuerySetting.xml", $XMLWriterSettings) 
 
    #Serialize the WqlQuerySetting object to the XmlWriter
    $WqlQuerySetting.SerializeToXml($XMLWriter)
 
    #Flush and dispose the XmlWriter
    $XMLWriter.Flush()
    $XMLWriter.Dispose()
 
    #Load the WqlQuerySettingXML
    $WqlQuerySettingXML = New-Object -TypeName XML
    $WqlQuerySettingXML.Load("C:\Temp\WqlQuerySetting.xml")
 
    #Import the WqlQuerySettingXML node to the SDMPackageXML of the CI
    $ImportNodeXML = $CISDMPackageXML.ImportNode($WqlQuerySettingXML.SimpleSetting,$true)

    #Add the imported node to the SDMPackageXML of the CI and save it
    $CISDMPackageXML.DesiredConfigurationDigest.OperatingSystem.Settings.ChildNodes[0].AppendChild($ImportNodeXML)
    $CISDMPackageXML.Save("C:\Temp\NewSDMPackageXML.xml")
 
    #Update the CI with the new SDMPackageXML
    Set-CMConfigurationItem -Name $CI.LocalizedDisplayName -DesiredConfigurationDigestPath C:\Temp\NewSDMPackageXML.xml -Verbose
}