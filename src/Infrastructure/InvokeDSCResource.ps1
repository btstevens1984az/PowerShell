# Purpose: InvokeDSCResource — Core infrastructure automation scripts.
Invoke-DscResource -Name My_newService -Method get -Property @{name='bits';state='running'} -ModuleName My_NewService
Invoke-DscResource -Name My_newService -Method test -Property @{name='bits';state='running'} -ModuleName My_NewService
Invoke-DscResource -Name My_newService -Method set -Property @{name='bits';state='running'} -ModuleName My_NewService