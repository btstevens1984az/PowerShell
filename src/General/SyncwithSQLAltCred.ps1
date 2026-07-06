# Purpose: SyncwithSQLAltCred — General-purpose PowerShell utilities.
#matchsiteCode function is likely bugged in this version.
Import-Module ActiveDirectory
$changes = @()
#***************Modify Here*****************
$Groups = "testGCF1","testGCF2","testGCF3","testGCF4"
$changesFilePathXML = ".\changes.xml"
$changesFilePathCSV = ".\changes.csv"
$ADGroups = $groups | Get-ADGroup
$ADprop1 = "extensionAttribute1"
$ADprop2 = "extensionAttribute2"
$ADProps = $ADprop1,$ADprop2
$SQLServer = "sql2008r2"
#use Server\Instance for named SQL instances!
$SQLDBName = "TestCF"
$Table = 'dbo.RFSQL$'
$emailMatch = '*@Kaylos.lab'
$user = "kayloslab\testsql"
$pass = ConvertTo-SecureString -AsPlainText -Force -String "Password1"
$DomainNetbios = "kayloslab"  #Short domain name
$DomainFQDN = "kaylos.lab"
#***********End Modify Section*****************
$ADcreds = New-Object System.Management.Automation.PSCredential ($user, $pass)
New-PSDrive -PSProvider ActiveDirectory -Name $DomainNetbios -Root "" –Server $DomainFQDN  `
–credential $ADcreds
Set-location "$($DomainNetbios):"


$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter

$SqlQuery = "select [handle],[GroupID],LEFT ([GroupID],5) as [FiveSiteCode],LEFT ([GroupID],3) as [ThreeSiteCode] FROM $Table WHERE [GroupID] NOT LIKE '%NO[_]Number'"
$SqlQuery2 = "select [handle],[GroupID],LEFT ([GroupID],5) as [FiveSiteCode],LEFT ([GroupID],3) as [ThreeSiteCode] FROM $Table WHERE [GroupID] LIKE '%NO[_]Number'"

$SqlCmd.CommandText = $SqlQuery
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

$SqlCmd.CommandText = $SqlQuery2
$SqlAdapter.SelectCommand = $SqlCmd
$DataSetNN = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSetNN)
$SqlConnection.Close()


$users = Get-aduser -filter {mail -like $emailMatch} -ResultSetSize $null -Properties $ADProps

function CheckForGroupMemberships
{  
    param ($ADUser,$ADGroups)

    Foreach ($ADGroup in $ADGroups)
    {
        if (Get-ADUser -Filter { memberOf -RecursiveMatch $ADgroup.DistinguishedName } -SearchBase $ADuser.DistinguishedName -SearchScope Base)
        {
          #match
          $true
          break
        }

    }
}

Function UpdateProperty
{
    param($ADUser,$PropertyToupdate,$PropertyValue)
    $error.clear()
    Write-Debug "Updating $($ADuser.DistinguishedName)"
    Write-Debug "Current Site Code: $($ADUser.($($ADPROP1)))"
    Write-Debug "Current Handle: $($ADUser.$($ADPROP2))"
    Write-Debug "New Handle: $PropertyValue"
    Write-debug "ProertyToupdate: $($PropertyToupdate)"
	$ADUser | Set-ADUser -replace @{$PropertyToupdate=$PropertyValue}
    if ($error)
    {
        Write-Error "Update Not Successful on $($ADuser.DistinguishedName)"
        $error.Clear()
    }
    else
    {
        Write-Debug "Update Success on $($ADuser.DistinguishedName)"
        $ObjHash = @{
                        DN=$aduser.DistinguishedName
                        $ADPROP1 = $aduser.($($ADPROP1))
                        $PropertyToupdate = $aduser.($($PropertyToupdate))
                        NewValue = $PropertyValue
                    }
        $changeObj = new-object PsObject -property $objHash
        $global:changes += $changeObj
    }



}

Function MatchSiteCode
{
    param ($MatchDataSet,$ADUser)
    If (!($aduser.($($ADprop1))))
    {
        $NoMatch = $DataSet.tables[0].select("FiveSiteCode = 'USA_A'") | select -First 1
		if (!($aduser.($($ADprop2))))
		{
            UpdateProperty -ADUser $ADUser -PropertyToupdate $ADprop2 -PropertyValue $nomatch.handle

		}
		elseIf ($aduser.($($ADprop2)) -ne $nomatch.handle)
		{
            UpdateProperty -ADUser $ADUser -PropertyToupdate $ADprop2 -PropertyValue $nomatch.handle
		}
    }
    else
    {
        $Fivematch = $DataSet.tables[0].select("FiveSiteCode = '$($aduser.($($ADprop1)))'") | select -First 1
        If ($Fivematch)
        {
            If ($aduser.($($ADprop2)) -ne $fivematch.handle)
            {
                UpdateProperty -ADUser $ADUser -PropertyToupdate $ADprop2 -PropertyValue $fivematch.handle
            }     
        }
        Else
        {
            $ThreeMatch = $DataSet.tables[0].select("ThreeSiteCode = '$($aduser.($($ADprop1)))'") | select -First 1
            If($ThreeMatch)
			{
                If ($aduser.($($ADprop2)) -ne $ThreeMatch.handle)
                {
                    UpdateProperty -ADUser $ADUser -PropertyToupdate $ADprop2 -PropertyValue $ThreeMatchmatch.handle
                }
			}
           else
           {
                    $NoMatch = $DataSet.tables[0].select("FiveSiteCode = 'USA_A'") | select -First 1
                    UpdateProperty -ADUser $ADUser -PropertyToupdate $ADprop2 -PropertyValue $nomatch.handle				
           }
 
        }
    }
}



foreach ($user in $users)
{
    if (CheckForGroupMemberships -ADuser $user -ADGroups $ADGroups)
    {#Use Dataset
        MatchSiteCode -MatchDataSet $DataSet -aduser $user
    }
    else
    {#use NNDataSet
        MatchSiteCode -MatchDataSet $DataSetNN -aduser $user
    }

}

Function GetDateStringForFiles
{
	$date = Get-Date
	$day = ([string]($date.date)).split()[0]
	$time= (([string]($date.TimeofDay)).split("."))[0]
	$shortDate = "$day$time"
	$shortDate = $shortDate -replace "/"
	$shortDate = $shortDate -replace ":"
	$shortDate
}


Write-host "Exporting Log File $changesFilePathXML"
$changes | Export-Clixml -Path $changesFilePathXML
$changes | Export-Csv -NoTypeInformation -Path $changesFilePathCSV