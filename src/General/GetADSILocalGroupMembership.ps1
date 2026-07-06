#Adapted from
#https://mcpmag.com/articles/2015/06/18/reporting-on-local-groups.aspx
Function Get-adsiLocalGroup  {
<#
.Synopsis
   Gets local group membership of remote computers using ADSI.
.DESCRIPTION
   Gets local group membership of remote computers using ADSI.
.PARAMETER  ComputerName
    Specify one or more computer names...
.EXAMPLE
    #Get users and administrators membership and send to out-gridview
   Get-adsiLocalGroup -Computername 201.72.64.23,DC4,KMS,VMHOST5 -Group Administrators,Users -Verbose |
        Out-GridView
   https://mcpmag.com/articles/2015/06/18/reporting-on-local-groups.aspx
#>

  Param( 
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)] 
  [String[]]$Computername =  $Env:COMPUTERNAME,

  [parameter(Mandatory)]
  [string[]]$Group

  )

  Begin {

        Function  ConvertTo-SID {
        
            Param([byte[]]$BinarySID)
        
            (New-Object  System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value
        
        }
        Function  Get-LocalGroupMember {
          Param  ($Group)
          $group.Invoke('members')  | 
            ForEach-Object {$_.GetType().InvokeMember("Name",  'GetProperty',  $null,  $_, $null)}
            }

        }

  Process  {

  ForEach  ($Computer in  $Computername) {

  Try  {

  Write-Verbose  "Connecting to $($Computer)"

  $adsi  = [ADSI]"WinNT://$Computer"

  If  ($PSBoundParameters.ContainsKey('Group')) {

  Write-Verbose  "Scanning for groups: $($Group -join ',')"

  $Groups  = ForEach  ($item in  $group) {                        

  $adsi.Children.Find($Item, 'Group')

  }

  } Else  {

  Write-Verbose  "Scanning all groups"

  $groups  = $adsi.Children | where {$_.SchemaClassName -eq  'group'}

  }

  If  ($groups) {

  $groups  | ForEach {

  [pscustomobject]@{

  Computername = $Computer

  Name = $_.Name[0]

  Members = ((Get-LocalGroupMember  -Group $_))  -join ', '

  SID = (ConvertTo-SID -BinarySID $_.ObjectSID[0])

  }

  }

  } Else  {

  Throw  "No groups found!"

  }

  } Catch  {

  Write-Warning  "$($Computer): $_"

  }

  }

  }

  }


#Get-adsiLocalGroup -Computername  201.72.64.23,DC4,KMS,VMHOST5 -Group  Administrators,  Users -Verbose  |
# Out-GridView