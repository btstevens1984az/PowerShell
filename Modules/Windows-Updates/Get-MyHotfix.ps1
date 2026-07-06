# Purpose: Get-MyHotfix — Windows Update and patch management.
 
#BasicFunction-HotFixReport.ps1
 
Function Get-MyHotFix {
 
[cmdletbinding()]
Param(
[string[]]$Computername = $env:COMPUTERNAME,
[ValidateSet("Security Update","HotFix","Update")]
[string]$Description,
[string]$Username,
[datetime]$Before,
[datetime]$After,
[System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
)
 
#create a hashtable of parameters to splat to Get-Hotfix
$params = @{
    ErrorAction = 'Stop'
    Computername = $Null
}
 
if ($Credential.UserName) {
    #add the credential
    $params.Add("Credential",$Credential)
}
 
if ($Description) {
    #add the description parameter
    $params.add("Description",$Description)
}
 
foreach ($Computer in $Computername) {
    #add the computer name to the parameter hashtable
    $params.Computername = $Computer
    Try {
        #get all matching results and save to a variable
        $data = Get-MyHotfix @params 
        
        #filter on Username if it was specified 
        if ($Username) {
           #filter with v4 Where method for performance
           #allow the use of wildcards
          $data = $data.Where({$_.InstalledBy -match $Username})
        }
        
        #filter on Before
        if ($before) {
            $data = $data.Where({$_.InstalledOn -le $Before})
        }
 
        #filter on After
        if ($after) {
            $data = $data.Where({$_.InstalledOn -ge $After})
        }
 
        #write the results
        $data | Select-Object -Property PSComputername,HotFixID,Description,InstalledBy,InstalledOn,
        @{Name="Online";Expression={$_.Caption}} | Format-Table
 
    } #Try
    Catch {
        Write-Warning "$($computer.toUpper()) Failed. $($_.exception.Message)"
    } #Catch
 
} #foreach computer
 
} #end Get-MyHotFix function