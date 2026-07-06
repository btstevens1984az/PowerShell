# Purpose: FixSCOMXML — System Center Operations Manager monitoring.
function FixScomXML
{
param ( 
        [cmdletbinding()] 
        [Parameter(Mandatory=$true,
                    HelpMessage = "Enter Guids to remove")]
        [string[]]$BADGUID,
        [string]$xmlFilePath = "C:\temp\SCOMXMLParse\Microsoft.SystemCenter.32.221.209.92.xml",
        [string]$outPutPath = ".\newXML.xml")


[xml]$xml = Get-Content $xmlFilePath
$elements = $xml.ManagementPack.LanguagePacks.LanguagePack.DisplayStrings.DisplayString | where name -eq "37.220.164.32 Critical Alerts"
$elememts2 = $xml.ManagementPack.Monitoring.rules.rule | where id -eq $elements.ElementID
foreach ($node in $elememts2.DataSources.DataSource.AlertChangedSubscription.Criteria.Expression.Or.EXPRESSION)
{
    if ($node.SimpleExpression.ValueExpression | Where-Object {$BADGUID -contains $_.value})
    {
        Write-Verbose "removing $node"
        $elememts2.DataSources.DataSource.AlertChangedSubscription.Criteria.Expression.Or.RemoveChild($node) | Out-Null
    }
}
$xml.save($outPutPath)

}
