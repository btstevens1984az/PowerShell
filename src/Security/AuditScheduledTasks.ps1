# Purpose: AuditScheduledTasks — Security auditing and compliance checks.
# powershell2 
# Kerry AuditScheduledTasks.PS1
# connects to domain - gets server list - checks for scheduled tasks - emails csv
# S:\ADReports\ScheduledTasks  path to stored report

$erroractionpreference = "SilentlyContinue"  
  
function GetServersFromOU([string]$strDomainName, [array]$arrOUs)  
{  
    $arrDCs = $strDomainName.split(".")  
    $strFullDC = $null  
    foreach ($DC in $arrDCs)  
    {  
        if ($strFullDC -eq $null)  
        {  
            $strFullDC = "DC=$DC"  
        }  
        else  
        {  
            $strFullDC = "$strFullDC,DC=$DC"  
        }  
                          
    }  
              
    $arrComputers = @( )  
    foreach ($Ou in $arrOUs)  
    {  
        $strFilter = "computer"  
                                          
        $objDomain = New-Object System.DirectoryServices.DirectoryEntry  
                                          
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher  
        $objSearcher.SearchRoot = "LDAP://OU=$OU,$strFullDC"  
        $objSearcher.SearchScope = "subtree"   
        $objSearcher.PageSize = 3000  
                                          
        $objSearcher.Filter = "(objectCategory=$strFilter)"  
        $colResults = $objSearcher.FindAll()  
                      
                          
        foreach ($i in $colResults)  
        {  
            $objComputer = $i.GetDirectoryEntry()  
            $arrComputers += $objComputer.Name  
        }  
    }  
        $arrcomputers = $arrcomputers | Sort-Object  
    return $arrComputers  
}  
  
function CheckComputerConnectivity($computer)  
{  
    $bPing = $false  
    $bShare = $false  
    $result = $false  
    #Firstly check if the computer can be pinged.  
    "checking $computer"  
    $ping = New-Object Net.NetworkInformation.Ping  
    $PingResult = $ping.send($computer)  
    if ($PingResult.Status.Tostring().ToLower() -eq "success")  
    {  
        $bPing = $true  
        #Secondly check if can browse to the scheduled task share  
        $path = "\\$computer\admin`$\tasks"  
        $ShareErr = $null  
        $ShareResult = Get-ChildItem $path -ErrorVariable ShareErr  
        if ($ShareErr.count -eq 0) { $bShare = $true }  
                          
    }  
    if ($bPing -eq $true -and $bShare -eq $true)  
    { $result = $true }  
    return $result  
      
}  
  
  
$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf  
$scriptRoot = Split-Path(Resolve-Path $myInvocation.MyCommand.Path)  
# $OutPutCSVFile = Join-Path $scriptRoot "ScheduledTasks.csv" 
$OutPutCSVFile = "S:\ADReports\ScheduledTasks\ScheduledTasks2.csv"  
$strSMTP = "187.17.174.206"  
  
$strDomain = "108.45.123.69"  
$arrOUs = @( )  
$arrOus += "domain controllers"  
$arrOus += "servers"  
  
$arrComputers = GetServersFromOU $strDomain $arrOUs  
  
$arrSchTasksAttributes = @( )  
  
$arrSchTasksAttributes += "HostName"  
$arrSchTasksAttributes += "TaskName"  
$arrSchTasksAttributes += "Next Run Time"  
$arrSchTasksAttributes += "Status"  
$arrSchTasksAttributes += "Logon Mode"  
$arrSchTasksAttributes += "Last Run Time"  
$arrSchTasksAttributes += "Last Result"  
$arrSchTasksAttributes += "Creator"  
$arrSchTasksAttributes += "Schedule"  
$arrSchTasksAttributes += "Task To Run"  
$arrSchTasksAttributes += "Start In"  
$arrSchTasksAttributes += "Comment"  
$arrSchTasksAttributes += "Scheduled Task State"  
$arrSchTasksAttributes += "Scheduled Type"  
$arrSchTasksAttributes += "Start Time"  
$arrSchTasksAttributes += "Start Date"  
$arrSchTasksAttributes += "End Date"  
$arrSchTasksAttributes += "Days"  
$arrSchTasksAttributes += "Months"  
$arrSchTasksAttributes += "Run As User"  
$arrSchTasksAttributes += "Delete Task If Not Rescheduled"  
$arrSchTasksAttributes += "Stop Task If Runs X Hours and X Mins"  
$arrSchTasksAttributes += "Repeat: Every"  
$arrSchTasksAttributes += "Repeat: Until: Time"  
$arrSchTasksAttributes += "Repeat: Until: Duration"  
$arrSchTasksAttributes += "Repeat: Stop If Still Running"  
$arrSchTasksAttributes += "Idle Time"  
$arrSchTasksAttributes += "Power Management"  
  
$arrObjTasks = @()  
foreach ($computer in $arrComputers)  
{  
    "Auditing $computer"  
    $IsComputerAccessible = CheckComputerConnectivity $computer  
    "$IsComputerAccessible"  
    if ($IsComputerAccessible -eq $true)  
    {  
        "Successfully connected to $computer"  
        $arrtasks = @( )  
        #$arrtasks = schtasks /query /S $computer /fo csv /nh /v
		$arrtasks = schtasks /query /S $computer /fo csv /v 
        $arrtasksTemp = @( )  
        #whe description contains multiple lines, the schtasks command returns multiple lines as well.  
        #We need to combine them into one line.  
        #remove the spaces and empty lines  
        $arrtasks | foreach-object { $_=$_.trimEnd(); $_=$_.trimstart() ; if ($_.length -ne 0) { $arrtasksTemp += $_ } }  
        $arrtasks = $arrtasksTemp  
        $arrtasksTemp = @( )  
        $strTemp = $null  
        #join the muti-line description field into one line  
        for ($i = 0; $i -le ($arrtasks.count -1); $i++)  
        {  
            # for a string starts and ends with the quotation mark, it is OK  
            if ( $arrtasks[$i].substring(0, 1) -eq '"' -and $arrtasks[$i].substring($arrtasks[$i].length-1,1) -eq '"')  
                {  
                    $arrtaskstemp += $arrtasks[$i]  
                }  
                elseif ( $arrtasks[$i].substring(0, 1) -eq '"' -and $arrtasks[$i].substring($arrtasks[$i].length-1,1) -ne '"')  
                    {  
                        $strTemp = $arrtasks[$i]  
  
                    }  
                    elseif ( $arrtasks[$i].substring(0, 1) -ne '"' -and $arrtasks[$i].substring($arrtasks[$i].length-1,1) -ne '"')  
                        {  
                            $strTemp = $strTemp + " " + $arrTasks[$i]  
                        }  
                        elseif ( $arrtasks[$i].substring(0, 1) -ne '"' -and $arrtasks[$i].substring($arrtasks[$i].length-1,1) -eq '"')  
                            {  
                                $strTemp = $strTemp + " " + $arrTasks[$i]  
                                $arrtaskstemp += $strTemp  
                                $strTemp = $null  
                                                                  
                            }  
                        }  
                        $arrtasks = $arrtaskstemp  
                        $arrtasksTemp = @()  
          
          
        foreach ($task in $arrtasks)  
        {  
            $task = $task -replace ('","', "^")  
            #Remove the first character, which is a quotation mark  
            if ( $task.substring(0, 1) -eq '"' ) {$task = $task.substring(1,$task.length-1)}  
                #Remove the last character, which is a quotation mark  
                if ( $task.substring($task.length-1, 1) -eq '"' ) {$task = $task.substring(0,$task.length-1)}  
                    $objtasks = $null  
                    $objtasks = New-Object psobject  
                    $arrtaskvalues = @( )  
                    $arrtaskvalues = $task.split("^")  
                    for ($i = 0; $i -le ($arrtaskvalues.count -1); $i++)  
                    {  
                        Add-Member -inp $objTasks -membertype noteproperty -name $arrSchTasksAttributes[$i] -value $arrtaskvalues[$i]                                                  
                    }  
                    $arrObjTasks += $objTasks  
        }  
    }  
              
}  
        $arrObjTasks | Select-Object * | Export-Csv -notypeinformation $OutPutCSVFile  
                  
#email the output csv file  
        $date = ((Get-Date).dateTime).tostring()  
        $strSubject = "ADC Domain Servers Scheduled Tasks Audit Report - $date"      
        $strBody = "scheduled tasks report attached."  
      
        $MailMessage = New-Object System.Net.Mail.MailMessage  
        $SMTPClient = New-Object System.Net.Mail.smtpClient  
        $SMTPClient.host = $strSMTP  
        $Recipient = New-Object System.Net.Mail.MailAddress("kkreitin@245.125.148.64", "Recipient")  
        $Sender = New-Object System.Net.Mail.MailAddress("PowerShellReports@245.125.148.64", "Sender")  
        $MailMessage.Sender = $Sender  
        $MailMessage.From = $Sender  
        $MailMessage.Subject = $strSubject  
        $MailMessage.To.add($Recipient)  
        $MailMessage.Body = $strBody  
        $MailMessage.attachments.add($OutPutCSVFile)  
        $SMTPClient.Send($MailMessage) 

