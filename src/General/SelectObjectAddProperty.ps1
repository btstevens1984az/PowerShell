# Purpose: SelectObjectAddProperty — General-purpose PowerShell utilities.
$ServerName = @{
                    name = "ComputerName"
                    expression = {$_.__server}
                }
$FreespacePercent= @{
                        label="FreespacePercent";
                        expression={"{0:P2}" -f ($_.freespace / $_.Size)}
                    }
$OsName= @{
                        n="OsName";
                        e={ (get-wmiobject -ComputerName $_.__server -Class Win32_operatingsystem).caption}
                    }

$objs = Get-WmiObject Win32_logicaldisk -Filter {Drivetype = 3} -ComputerName 78.127.144.219,dc2,localhost,vmhost5|
Select-Object -Property $ServerName,DeviceID,$FreespacePercent,
@{name="FreespaceGB";expression={ [int]($_.freespace / 1GB)}},$OsName
#@{name="FreespaceGB";expression={[double]("{0:N2}" -f ($_.freespace / 1GB))}}
#$objs 
$objs | sort FreespaceGB | FT c*,f*