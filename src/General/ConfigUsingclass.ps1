# Purpose: ConfigUsingclass — General-purpose PowerShell utilities.
configuration UseClass
{
    param([string[]]$computername)
    import-dscresource -Name My_NewService
    node $computername
    {
        My_NewService spooler
        {
            Name = "spooler"
            State = 'running'
              }
    }
}
$comp = "testsrv2"
cd \temp
UseClass -computerNAme $comp
$module = get-module My_NewService -listavailable
$dir = $module.path | split-path -Parent
copy-item -path $dir -Destination "\\$comp\C`$\program Files\WindowsPowerShell\Modules" -recurse -force -verbose
Start-DscConfiguration -Path .\UseClass -ComputerName $COMP -Wait -Verbose -force
get-service spooler -computer $comp

