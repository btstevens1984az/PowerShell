# Purpose: PowerShell module — PowerShell automation.
MyJiraTickets {
    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/search?jql=assignee=$($script:JiraUserName)"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url


    $line = @{Expression={$_.key};Label="ID";width=10}, `
            @{Expression={$_.fields.issuetype.name};Label="Type";width=8}, `
            @{Expression={$_.fields.status.name};Label="Status";width=12}, `
            @{Expression={$_.fields.summary};Label="Summary";width=80}

    $json.issues | Format-Table $line
}

Function Get-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    return $json
}

Function Get-JiraTicketComments {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [switch]$List
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/comment"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    if ($List) {
        $line = @{Expression={$_.author.displayName};Label="Who"}, `
                @{Expression={Get-date $_.updated -Format "MM/dd/yyyy h:mm"};Label="When"}, `
                @{Expression={$_.body};Label="What"}
        $json.comments | Format-List $line
    } else {
        $line = @{Expression={$_.author.displayName};Label="Who";width=20}, `
                @{Expression={Get-date $_.updated -Format "MM/dd/yyyy h:mm"};Label="When";width=12}, `
                @{Expression={$_.body};Label="What";width=80}
        $json.comments | Format-Table $line -Wrap
    }
}

Function Get-JiraTicketStatus {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    return $json.fields.status.name
}

Function Start-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/transitions"

    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $transitionId = $($json.transitions | Where-Object { $_.name -eq "$($script:StartTransition)"}).id

    if (-not $transitionId) {
        Write-Error "Invalid transition for that ticket. Current ticket status is: `"$(Get-JiraTicketStatus $Ticket)`""
        return
    }

    if ($Comment) {
        $updateJSON = @"
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "$comment"
                }
            }
        ]
    },
    "transition": {
            "id": "$transitionId"
    }
}
"@
    } else {
        $updateJSON = @"
{
    "transition": {
            "id": "$transitionId"
    }
}
"@
    }

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Finish-JiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/transitions"

    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $transitionId = $($json.transitions | Where-Object { $_.name -eq "$($script:FinishTransition)"}).id

    if (-not $transitionId) {
        Write-Error "Invalid transition for that ticket. Current ticket status is: `"$(Get-JiraTicketStatus $Ticket)`""
        return
    }

    if ($Comment) {
        $updateJSON = @"
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "$comment"
                }
            }
        ]
    },
    "transition": {
            "id": "$transitionId"
    }
}
"@
    } else {
        $updateJSON = @"
{
    "transition": {
            "id": "$transitionId"
    }
}
"@
    }

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Add-JiraTicketComment {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Comment = $(Read-Host "Enter Comment for Ticket")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/comment"

    $updateJSON = @"
{
    "body": "$comment"
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Get-JiraTicketWatchers {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number")
    )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers"
    $json = Invoke-RestMethod -Method Get -Headers $script:JiraHeader -Uri $url

    $line = @{Expression={$_.name};Label="ID";width=15}, `
            @{Expression={$_.displayName};Label="Name";width=25}

    $json.watchers | Format-Table $line
}

Function Add-JiraTicketWatcher {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$UserName = $(Read-Host "Enter UserName")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers"

    $update = "$UserName"

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $update
}

Function Remove-JiraTicketWatcher {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$UserName = $(Read-Host "Enter UserName")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/watchers?username=$UserName"

    Invoke-RestMethod -Method DELETE -Headers $script:JiraHeader -Uri $url
}

Function Ping-JiraTicketWatchers {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA Ticket Number"),
        [string]$Subject = $(Read-Host "Enter Subject" ),
        [string]$Message = $(Read-Host "Enter message for ticket watchers")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/notify"

    $updateJSON = @"
{
    "subject": "$Subject",
    "textBody": "$Message",
    "to": {
        "reporter": false,
        "assignee": false,
        "watchers": true,
        "voters": false
    }
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $updateJSON
}

Function Add-TimeSpentOnJiraTicket {
    param (
        [string]$Ticket = $(Read-Host "Enter JIRA ticket number"),
        [string]$Comment = $(Read-Host "Enter comment for ticket"),
        [datetime]$When,
        [string]$Minutes = $(Read-Host "Enter number of hours spent on this ticket")
     )

    if (-not (IsConnected)) {
        Show-JiraServer
        return
    }

    $url = "$($script:JiraUrl)/rest/api/2/issue/$Ticket/worklog"

    if (-not $When) {
        $started = ([DateTime]::Now.AddMinutes(0 - [double]$Minutes)).ToString('o')
    } else {
        $started = $When.ToString('o') + $When.ToString('zzz');
    }

    $seconds = [double]$Minutes * 60

    $json = @"
{
    "comment": "$comment",
    "started": "$started",
    "timeSpentSeconds": $seconds
}
"@

    Invoke-RestMethod -Method POST -Headers $script:JiraHeader -Uri $url -Body $json
}

###############################################################################

Export-ModuleMember Add-JiraTicketComment
Export-ModuleMember Add-JiraTicketWatcher
Export-ModuleMember Add-TimeSpentOnJiraTicket
Export-ModuleMember Clear-JiraProfile
Export-ModuleMember Connect-JiraServer
Export-ModuleMember Disconnect-JiraServer
Export-ModuleMember Finish-JiraTicket
Export-ModuleMember Get-JiraProfile
Export-ModuleMember Get-JiraTicket
Export-ModuleMember Get-JiraTicketComments
Export-ModuleMember Get-JiraTicketStatus
Export-ModuleMember Get-JiraTicketWatchers
Export-ModuleMember Get-MyJiraTickets
Export-ModuleMember Invoke-Jira
Export-ModuleMember Ping-JiraTicketWatchers
Export-ModuleMember Remove-JiraTicketWatcher
Export-ModuleMember Show-JiraServer
Export-ModuleMember Show-JiraUser
Export-ModuleMember Start-JiraTicket

Set-Alias jira-profile-clear Clear-JiraProfile
Set-Alias jira-profile-load Get-JiraProfile

Export-ModuleMember -Alias jira-profile-clear
Export-ModuleMember -Alias jira-profile-load