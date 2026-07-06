
function Get-ActiveDirectoryMenu {

<#
    .SYNOPSIS
    Get-ActiveDirectoryMenu is an advanced Powershell function. It gives you a menu of powerful Active Directory commands.

  #>

$line='========================================================='
$line2='________________________________________________________'

cls

do {

Write-Host ''
Write-Host 'ACTIVE DIRECTORY Domain Services Section' -ForegroundColor Green ''
Write-Host ' 1 - List of Domain Controller and FSMO Roles'
Write-Host ' 2 - Domain Main Configuration'
Write-Host ' 3 - Forest Main Configuration'
Write-Host ' 4 - List all Windows Clients'
Write-Host ' 5 - List all Windows Server'
Write-Host ' 6 - List all Computer (sort by operatingsystem)'
Write-Host ' 7 - Run systeminfo on remote computers'
Write-Host ' 8 - List Domain Admins'
Write-Host ' 9 - Enabled Optional Features'
Write-Host '10 - List of Active GPOs'
Write-Host '11 - Default Password Policy Settings'
Write-Host '12 - Active Directory Sites'
Write-Host '13 - Users Last Logon'
Write-Host '14 - List all Users (enabled)'
Write-Host '15 - List User Details'
Write-Host '16 - List all Groups'
Write-Host '17 - List Group Memberships'
Write-Host '18 - Send message to users Desktop'
Write-Host '19 - Get Logged on User'
Write-Host '0  - Quit'
Write-Host ''
$line
Write-Host ''

$input=Read-Host 'Select'

switch ($input)
 {
 1 {
    $dc=Get-ADDomainController -Filter * 
    $dccount=$dc | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Active Directory Domain Controller ($env:userdnsdomain)" 
    $line2 
    $dc | Format-Table Name,Ipv4Address,OperatingSystem,Site,IsGlobalCatalog,OperationMasterRoles -autosize -wrap
    Write-Host 'Total Number:    '$dccount""
    Read-Host 'Enter to continue'
    } 

 2 {
    
    Write-Host -ForegroundColor Green 'DOMAIN Configuration' 
    $line2 
    Get-ADDomain | Format-List DNSRoot, DomainMode, ComputersContainer, DeletedObjectsContainer, UsersContainer
    Read-Host 'Press 0 and Enter to continue'
    }
 
 3 {
    Write-Host -ForegroundColor Green 'FOREST Configuration' 
    $line2 
    Get-ADForest | Format-List RootDomain, ForestMode, Domains, Sites
    Read-Host 'Press 0 and Enter to continue'
    } 
 
 4 {
    $client=Get-ADComputer -Filter {operatingsystem -notlike '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $ccount=$client | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Windows Clients $env:userdnsdomain"
    $line2 
    Write-Output $client | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address -AutoSize
    Write-Host 'Total: '$ccount""
    Read-Host 'Press 0 and Enter to continue'
    }
 
 5 {
    $server=Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $scount=$server | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "Windows Server ($env:userdnsdomain)" 
    $line2
    Write-Output $server | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address
    Write-Host 'Total: '$scount""
    Read-Host 'Press 0 and Enter to continue'
    }
 
 6 {
    $all=Get-ADComputer -Filter * -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $acount=$all | Measure-Object | Select-Object -ExpandProperty count
    Write-Host -ForegroundColor Green "All Computer ($env:userdnsdomain)" 
    $line2 
    Write-Output $all | Select-Object Name,Operatingsystem,OperatingSystemVersion,IPv4Address | Sort-Object OperatingSystem | Format-Table -GroupBy OperatingSystem 
    Write-Host 'Total: '$acount""
    Read-Host 'Press 0 and Enter to continue'
    }

 7  {    do {

        Write-Host ''
        Write-Host 'Select the scope:' -ForegroundColor Green
        Write-Host ''
        Write-Host '1 - Localhost'
        Write-Host '2 - Remote Computer (Enter Computername)'
        Write-Host '3 - All Windows Server'
        Write-Host '4 - All Windows Computer'
        Write-Host '0 - Quit'
        Write-Host ''
        $scopesi=Read-Host 'Select'
        
        $header='Host Name','OS','Version','Manufacturer','Configuration','Build Type','Registered Owner','Registered Organization','Product ID','Install Date','Boot Time','System Manufacturer','Model','Type','Processor','Bios','Windows Directory','System Directory','Boot Device','Language','Keyboard','Time Zone','Total Physical Memory','Available Physical Memory','Virtual Memory','Virtual Memory Available','Virtual Memory in Use','Page File','Domain','Logon Server','Hotfix','Network Card','Hyper-V'


        switch ($scopesi) {

        1 {
            
            & "$env:windir\system32\systeminfo.exe" /FO CSV | Select-Object -Skip 1 | ConvertFrom-Csv -Header $header
            
          }

        2 {
            Write-Host 'Separate multiple computernames by comma. (example: server01,server02)'
            Write-Host ''
            $comps=Read-Host 'Enter computername'
            $comp=$comps.Split(',')
            Invoke-Command -ComputerName $comps {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header
            }

        3 { 
            Invoke-Command -ComputerName (Get-ADComputer -Filter {operatingsystem -like '*server*'}).Name {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header
        
            }

        4 {
            Invoke-Command -ComputerName (Get-ADComputer -Filter *).Name {systeminfo /FO CSV | Select-Object -Skip 1} -ErrorAction SilentlyContinue | ConvertFrom-Csv -Header $header
            }

            }  
            
            }
        while ($scopesi -ne '0')
            }
                     
      
 
 8 {
    Write-Host -ForegroundColor Green 'The following users are member of the Domain Admins group:'`n
    (Get-ADGroupMember 'Domain Admins').Name
    Read-Host 'Press 0 and Enter to continue'
    }
 
 9 {
    Write-Host -ForegroundColor Green 'The following optional features are enabled:'`n 
    (Get-ADOptionalFeature -Filter *).Name
    Read-Host 'Press 0 and Enter to continue'
    }

 10 {
    Write-Host -ForegroundColor Green 'The GPOs below are linked to AD Objects:'`n 
    Get-GPO -All | ForEach-Object {
    If ( $_ | Get-GPOReport -ReportType XML | Select-String '<LinksTo>' ) {
    Write-Host $_.DisplayName}}
    Read-Host 'Press 0 and Enter to continue'
    }
 
 11 {
     Write-Host -ForegroundColor Green 'The Default Domain Policy is configured as follows:'`n 
     Get-ADDefaultDomainPasswordPolicy | Format-List ComplexityEnabled, LockoutDuration,LockoutObservationWindow,LockoutThreshold,MaxPasswordAge,MinPasswordAge,MinPasswordLength,PasswordHistoryCount,ReversibleEncryptionEnabled
     Read-Host 'Press 0 and Enter to continue' 
     } 
 
 12 {
        Write-Host -ForegroundColor Green 'Active Directory Sites:'`n 
        
        $GetSite = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
        $Sites = @()
        foreach ($Site in $GetSite) {
        $Sites += New-Object -TypeName PSObject -Property (
        @{
        'SiteName'  = $site.Name
        'SubNets' = $site.Subnets -Join ','
        'Servers' = $Site.Servers -Join ','
        }
        )
        }
        $Sites | Format-Table -AutoSize -Wrap
        Read-Host 'Press 0 and Enter to continue'
        }
 13 {
        do {
       
        $userl=Read-Host 'Enter user logon name'
        Get-ADUser $userl -Properties lastlogondate | Format-Table Givenname,Surname,LastLogonDate
        $input=Read-Host 'Quit searching users? (Y/N)'
        }
        while ($input -eq 'N')
        }
        

14 {
        Get-ADUser -Filter {enabled -eq $true} | Sort-Object Name | Format-Wide Name -Column 4
        Read-Host 'Press 0 and Enter to continue'
        
        }
15 {    do {

        $userp=Read-Host 'Enter user logon name'
        Get-ADUser $userp -Properties * | Format-List GivenName,SurName,DistinguishedName,Enabled,EmailAddress,ProfilePath,ScriptPath,MemberOf,LastLogonDate,whencreated
        $input=Read-Host 'Quit searching users? (Y/N)'
        }
        while ($input -eq 'N')
        }

16 {
        Get-ADGroup -Filter * | Sort-Object Name | Format-Wide Name -Column 3
        Read-Host 'Press 0 and Enter to continue'
        }

17 {    do {
        $groupm=Read-Host 'Enter group name'
        Get-ADGroupMember $groupm | Format-Table Name -AutoSize -Wrap
        $input=Read-Host 'Quit searching groups? (Y/N)'
        }
        while ($input -eq 'N')
        }

18 {    do {
        Write-Host ''
        Write-Host 'To which computers should a message be sent?' -ForegroundColor Green
        Write-Host ''
        Write-Host '1 - Localhost'
        Write-Host '2 - Remote Computer (Enter Computername)'
        Write-Host '3 - All Windows Server'
        Write-Host '4 - All Windows Computer'
        Write-Host '0 - Quit'
        Write-Host ''
        $scopemsg=Read-Host 'Select'
        
        

        switch ($scopemsg) {

        1 {
            
            $msg=Read-Host 'Enter the message that is sent to all users logged on to the computer (LOCALHOST)'
            msg * "$msg"
            
          }

        2 {
            Write-Host 'Separate multiple computernames by comma. (example: server01,server02)'
            Write-Host ''
            $comp=Read-Host 'Enter computername'
            $comps=$comp.Split(',')
            $msg=Read-Host 'Enter message'
            Invoke-Command -ComputerName $comps -ScriptBlock {msg * $using:msg}
            
          } 
            

        3 {
            Write-Host 'Note that the message will be sent to all servers!' -ForegroundColor Red
            
            $msg=Read-Host 'Enter the message that is sent to all users logged on to WINDOWS SERVER operating systems'
            
            (Get-ADComputer -Filter {operatingsystem -like '*server*'}).Name | Foreach-Object {Invoke-Command -ComputerName $_ -ScriptBlock {msg * $using:msg} -ErrorAction SilentlyContinue}}
           }}
        
        while ($scopemsg -ne '0')
}

19 {   $result=@()

       $cred=Get-Credential

       $read=Read-Host 'Enter Computer Name'

       Invoke-Command -ComputerName $read -ScriptBlock {quser} -Credential $cred | Select-Object -Skip 1 | Foreach-Object {

       $b=$_.trim() -replace '\s+',' ' -replace '>','' -split '\s'

       If ($b[2] -like 'Disc*') {

            $array= ([ordered]@{
                'User' = $b[0]
                'Computer' = $read
                'Date' = $b[4]
                'Time' = $b[5]
                })
    
            Write-Output $array
            
            
    }

    else {

            $array= ([ordered]@{
                'User' = $b[0]
                'Computer' = $read
                'Date' = $b[5]
                'Time' = $b[6]
                })
    
           
            Write-Output $array 
           
}
} 


            Read-Host 'Press 0 and Enter to continue'
                   
}


}

}

while ($input -ne '0')

}

