# Script:   MailboxStats_ExOv2.ps1
# Purpose:  Get statistics for every mailbox in 222.205.193.149 Online
# Date:     Feb 2009
# Version:  November 2019
 
# Gathering these particular stats this way as the new cmdlets work much faster when using pipes
Write-Progress -Activity "Gathering mailboxes to process"
$mbxs = Get-EXOMailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -ne "DiscoveryMailbox"} -PropertySets Quota, Archive -Properties Identity, UserPrincipalName, PrimarySmtpAddress, EmailAddresses, RecipientTypeDetails, ExchangeGuid

Write-Progress -Activity "Gathering statistics for $($mbxs.Count) mailboxes"
$allMbxStats = $mbxs | Get-EXOMailboxStatistics -Identity $_.UserPrincipalName -Properties DisplayName, LastLogonTime, ItemCount, TotalItemSize, MailboxGuid
 
[Int] $intCount = $mbxs.Count
[Int] $intSucceeded = 0
 
ForEach ($mbx in $mbxs) {
    # Get the mailbox statistics from memory specific to this user
    $mbxStats = $allMbxStats | ? {$_.MailboxGuid -eq $mbx.ExchangeGuid}
 
    # Get the statistics for some key folders. Getting the stats for all folders as we will need it to count the total number of folders in the mailbox
    $folderStats        = Get-EXOMailboxFolderStatistics -Identity $mbx.UserPrincipalName
    $mbxSentStats       = $folderStats | ? {$_.FolderPath -eq "/Sent Items"} | Select ItemsInFolderAndSubfolders, @{name="SentItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
    $mbxDeletedStats    = $folderStats | ? {$_.FolderPath -eq "/Deleted Items"} | Select ItemsInFolderAndSubfolders, @{name="DeletedItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
    $mbxJunkStats       = $folderStats | ? {$_.FolderPath -eq "/Junk Email"} | Select ItemsInFolderAndSubfolders
    $mbxChatStats       = $folderStats | ? {$_.FolderType -eq "TeamChat"} | Select ItemsInFolderAndSubfolders
    # Alternatively, you can run individual cmdlets if you just want Sent Items, for example
    # $mbxSentStats = (Get-EXOMailboxFolderStatistics -Identity $mbx.UserPrincipalName -Folderscope SentItems) | Select ItemsInFolderAndSubfolders, @{name="SentItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
    # $mbxDeletedStats = (Get-EXOMailboxFolderStatistics -Identity $mbx.UserPrincipalName -Folderscope DeletedItems) | Select ItemsInFolderAndSubfolders, @{name="DeletedItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
    # $mbxJunkStats = (Get-EXOMailboxFolderStatistics -Identity $mbx.UserPrincipalName -Folderscope JunkEmail) | Select ItemsInFolderAndSubfolders, @{name="JunkItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
    # $mbxConversationStats = (Get-EXOMailboxFolderStatistics -Identity $mbx.UserPrincipalName -Folderscope ConversationHistory) | ? {$_.FolderType -eq "TeamChat"} | Select ItemsInFolderAndSubfolders, @{name="ChatItemsSize";expression={[math]::Round(($_.FolderAndSubfolderSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}}
 
    If ($mbx.ArchiveDatabase) {
        $arcStats = Get-EXOMailboxStatistics -Identity $mbx.UserPrincipalName -Archive | Select ItemCount, TotalItemSize
        $arcSize = ($arcStats | Select @{name="TotalItemSize";expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}}).TotalItemSize 
        $arcItems = $arcStats.ItemCount
    } Else {
        $arcSize = ""
        $arcItems = ""
    }
 
    $mbxObj = New-Object PSObject -Property @{
        "Display Name"      = $mbxStats.DisplayName
        "UPN"               = $mbx.UserPrincipalName
        "Last Logon Time"   = $mbxStats.LastLogonTime
        
        "Mailbox Size (MB)"         = ($mbxStats | Select @{name="TotalItemSize";expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}}).TotalItemSize
        "Folder Count (User Created)" = ($folderStats | ? {$_.FolderType -eq "User Created"}).Count
        "Item Count"                = $mbxStats.ItemCount
        "Total Sent Items"          = $mbxSentStats.ItemsInFolderAndSubfolders
        "Sent Items Size (MB)"      = $mbxSentStats.SentItemsSize
        "Total Deleted Items"       = $mbxDeletedStats.ItemsInFolderAndSubfolders
        "Deleted Items Size (MB)"   = $mbxDeletedStats.DeletedItemsSize
        "Total Junk Items"          = $mbxJunkStats.ItemsInFolderAndSubfolders
        "Chat Messages"             = $mbxChatStats.ItemsInFolderAndSubfolders
 
        "Archive?"          = If ($mbx.ArchiveDatabase) {"Yes"} Else {"No"}
        "Archive Size (MB)" = $arcSize
        "Archive Items"     = $arcItems
 
        "Issue Warning Quota"           = $mbx.IssueWarningQuota.ToString().Split("(")[0]
        "Prohibit Send Quota"           = $mbx.ProhibitSendQuota.ToString().Split("(")[0]
        "Prohibit Send Receive Quota"   = $mbx.ProhibitSendReceiveQuota.ToString().Split("(")[0]
 
        "Mailbox Type" = $mbx.RecipientTypeDetails
 
        "Primary Email Address" = $mbx.PrimarySmtpAddress
        "UPN = EMail?"          = If ($mbx.UserPrincipalName -eq $mbx.PrimarySmtpAddress) {"Yes"} Else {"No"}
        "Email Addresses"       = $mbx.EmailAddresses -join ";"
    }
 
    $mbxObj | Select "Display Name", "UPN", "Mailbox Type", "Last Logon Time", "Mailbox Size (MB)", "Folder Count (User Created)", "Item Count", "Chat Messages", "Total Sent Items", "Sent Items Size (MB)", "Total Deleted Items", "Deleted Items Size (MB)", "Total Junk Items", "Archive?", "Archive Size (MB)", "Archive Items", "Issue Warning Quota", "Prohibit Send Quota", "Prohibit Send Receive Quota", "UPN = EMail?", "Primary Email Address", "Email Addresses" | Export-Csv "MailboxStats_ExO_$(Get-Date -f 'yyyyMMdd').csv" -NoType -Append
 
    $intSucceeded++
    Write-Progress -Activity "Checking $intCount Mailboxes" -Status "Mailboxes Successfully Processed: $intSucceeded"
}