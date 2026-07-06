# Purpose: GetVMQinfo — General-purpose PowerShell utilities.

Get-NetAdapterVmq –Name * | Where-Object -FilterScript { $_.Enabled }  | select * | Out-GridView

Get-NetAdapterVmq –Name * | Where-Object -FilterScript { $_.Enabled }  | select * |
Export-Clixml .\export.xml

Get-NetAdapterVmq –Name * | Where-Object -FilterScript { $_.Enabled }  | select i*,n*