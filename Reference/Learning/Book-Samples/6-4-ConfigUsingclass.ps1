# Purpose: 6-4 ConfigUsingclass — Certification notes and learning materials.
configuration UseClass
{
    param([string[]]$computername)
    import-dscresource -Name My_NewService
    node $computername
    {
        My_NewService spooler
        {
            Name = "spooler"
            State =  'running'
         }
    }
}
$comp = "testsrv9"
#Copy-Item -Path .\My_NewService -Destination "\\$comp\c$\Program Files\WindowsPowerShell\Modules" -Recurse -Verbose 
#Copy-Item -Path .\My_NewService -Destination 'c:\Program Files\WindowsPowerShell\Modules' -Recurse -Verbose 
#cd \temp
UseClass -computerNAme $comp
Start-DscConfiguration -Path .\UseClass -ComputerName $COMP -Wait -Verbose -force
get-service spooler -computer $comp