# Purpose: MailboxReporting2 — 177.240.246.94 Online mailbox and mail flow administration.
If ($LiveCred -eq $null)
{$LiveCred = Get-Credential }
if ($session -eq $null)
{$Session = New-PSSession -ConfigurationName Microsoft.92.115.29.141 -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic –AllowRedirection
Import-PSSession $Session -AllowClobber
Connect-MsolService -Credential $LiveCred
}
Function FixHTML{param ([string]$string)$string.replace("&nbsp;",$null)$string}

$mailboxes = Get-Mailbox -Filter {(RecipientTypeDetails -eq 'UserMailbox')}
Function Get-Mailboxinfo
{
    [cmdletbinding()]
    param($mailbox,
    [validateRange(-999,0)]
    [int]$dayssinceLastLogon = -90
    )
    Write-Verbose "Getting mailboxstats for: $($mailbox.UserPrincipalName)"
    $mailboxStats = $mailbox | Get-MailboxStatistics
    if ($mailboxStats.LastlogonTime -gt ((Get-date).AddDays($dayssinceLastLogon)) -and $dayssinceLastLogon -ne 0  )
    {
        return
    }
    Write-Verbose "Getting MSOLUser info for: $($mailbox.UserPrincipalName)"
    $MSOLUser = Get-MsolUser -UserPrincipalName $mailbox.UserPrincipalName -ErrorAction SilentlyContinue
    Write-Verbose "Getting MailboxAutoReplyConfiguration info for: $($mailbox.UserPrincipalName)"
    $autoReply = Get-MailboxAutoReplyConfiguration  $mailbox.UserPrincipalName
    Write-Verbose "Creating custom object for: $($mailbox.UserPrincipalName)"
    if ($autoReply.InternalMessage){
            $pattern = "(?<=>)[^<>]+(?=<)"
            $OOFMessage = $autoReply.InternalMessage | Select-String -Pattern $pattern | ForEach-Object{FixHTML $_.matches.value}
            }
            else
            {
                $OOFMessage = $null
            }
            
    $obj = [pscustomobject]@{
        UserPrincipalName = $mailbox.UserPrincipalName
        DisplayName= $mailbox.DisplayName
        WhenMBXCreated = $mailbox.WhenMailboxCreated
        "Legal Hold" = if($mailbox.InPlaceHolds){"yes"}else{"no"}
        MailboxPlan =  $mailbox.MailboxPlan
        LastlogonTime = $mailboxStats.LastlogonTime
        ItemCount = $mailboxStats.ItemCount
        TotalItemSize = $mailboxStats.TotalItemSize
        Title =$null
        Department =$null
        Office =$null
        UsageLocation =$null
        AutoReplyState = $autoReply.AutoReplyState
        InternalMessage = $OOFMessage
        StartTime = $autoReply.StartTime
        LicenseInfo = $MSOLUser.Licenses.accountsku.SkuPartNumber -join ";"
    }
    If ($MSOLUser)
    {
        #populate info if MSOL User exists
        $obj.Title =$MSOLUser.title
        $obj.Department =$MSOLUser.department
        $obj.Office =$MSOLUser.office
        $obj.UsageLocation =$MSOLUser.usageLocation
    }
    Write-Verbose "Returning custom object for: $($mailbox.UserPrincipalName)"
      $obj
}
 $count = 0
 $results = ForEach ($MB in $mailboxes)
{
    $count++
    Write-Progress -Activity "Gathering Mailboxinfo" -Status $MB.DisplayName -PercentComplete ($count/$mailboxes.count*100)
    Get-Mailboxinfo $MB -Verbose -dayssinceLastLogon 0
}


$results | ogv