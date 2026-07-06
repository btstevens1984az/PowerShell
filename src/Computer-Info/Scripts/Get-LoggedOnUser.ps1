# Purpose: Get-LoggedOnUser — Computer hardware and system inventory.
[CmdletBinding()]            
 Param             
   (                       
    [Parameter(Mandatory=$true,
               Position=0,                          
               ValueFromPipeline=$true,            
               ValueFromPipelineByPropertyName=$true)]            
    [String[]]$ComputerName
   )#End Param

Begin            
{            
 Write-Host "`n Checking Users . . . "
 $i = 0            
}#Begin          
Process            
{
    $ComputerName | Foreach-object {
    $Computer = $_
    try
        {
            $processinfo = @(Get-WmiObject -class win32_process -ComputerName $Computer -EA "Stop")
                if ($processinfo)
                {    
                    $processinfo | Foreach-Object {$_.GetOwner().User} | 
                    Where-Object {$_ -ne "NETWORK SERVICE" -and $_ -ne "LOCAL SERVICE" -and $_ -ne "SYSTEM"} |
                    Sort-Object -Unique |
                    ForEach-Object { New-Object psobject -Property @{Computer=$Computer;LoggedOn=$_} } | 
                    Select-Object Computer,LoggedOn
                }#If
        }
    catch
        {
            "Cannot find any processes running on $computer" | Out-Host
        }
     }#Forech-object(ComputerName)       
            
}#Process
End
{

}#End

}#Get-LoggedOnUser
