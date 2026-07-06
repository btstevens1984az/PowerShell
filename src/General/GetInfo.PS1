# Purpose: GetInfo — General-purpose PowerShell utilities.
#This is powershell script that connect to Active directory and Queries a group for all its computer objects or gets content from a txt file containig the computers
#then pipelines the output to the function named get-hostinfo  which produces a custom object called computer with a lot of properties like 
#name, ipaddress , responsetime , sitelocation , srvmodel , opertaing system type ,  maxclockspeed , number of physical processors , number of cores per processor , total storage , total rams
#since the output is an object , it can be pipelined to Select-object to select the required properties 
#then again it can be pipelined to Export-csv where the output can be viewed in Ms Excel , or Export-Clixml to produce an xml which can be imported as an object later on


function get-hostinfo 

				{
	Begin {
		Write-output "ADC Inventory Collection"
	}
	
	Process {
	#parsing out the result from computer LDAP name to computer netbios name
	$x=$_.split(",")
	$server=$x[0].Substring(3)
    Write-Host $server
	
	trap {
		Write-Host -ForegroundColor Red "   <<<Spider Alert>>>  Error connecting to server : " $server ". Please make sure that the server is online and that WMI Queries are enabled."
		continue
		}
	
	#Nullifying Wmi Queries results from previous objects , to fix the problem of assigning previous Wmi Query values to offline servers
	$pingresult=0
	$RamResult=0
	$ModelResult=0
	$CpuResult=0
	$DiskResult=0
		
		
	#Quering Wmi for certian properties to collect information for the computer
	$pingresult = Get-WmiObject -Query "SELECT * FROM Win32_PingStatus WHERE Address = '$server'" -ErrorAction Stop
	$RamResult = Get-WmiObject -Query "SELECT * from Win32_PhysicalMemory" -computername $server -ErrorAction Stop
	$ModelResult = Get-WmiObject -Query "SELECT * from Win32_ComputerSystem" -computername $server -ErrorAction Stop
	$CpuResult = Get-Wmiobject -Query "select * from Win32_Processor" -ComputerName $server -ErrorAction Stop
	$DiskResult = Get-Wmiobject -Query "select * from Win32_DiskDrive" -ComputerName $server -ErrorAction Stop
	$OSResult = Get-WmiObject -Query "select * from win32_operatingsystem" -ComputerName $server -ErrorAction stop
	$appresult = Get-WmiObject -Query "select * from win32_Product" -ComputerName $server -ErrorAction stop
	
	#creating a new object called computer
	$Computer = New-Object psobject
	
	#the following section Adds properties to the computer Object 

	#Adding properties from ping result
	$Computer | Add-Member NoteProperty Name $server
	$Computer | Add-Member NoteProperty ResponseTime ($pingresult.responsetime)
	$Computer | Add-Member NoteProperty IPAddress ($pingresult.protocoladdress)
	
	#Adding a property called Site location depending on the computer ipaddress
	if ($pingresult.protocoladdress.StartsWith('10.6.0.'))
		{$Computer | Add-Member NoteProperty Sitelocation ("Site1")
		}
	elseif ($pingresult.protocoladdress.StartsWith('10.6.32.'))
		{$Computer | Add-Member NoteProperty Sitelocation ("Site2")	
		}
	else {
		$Computer | Add-Member NoteProperty Sitelocation ("UNKNOWN")
	}
	
	#Adding a property for Server Model
	$Model = $ModelResult.Manufacturer + $ModelResult.Model
	$Computer | Add-Member NoteProperty SrvModel ($Model)
	
	#Adding a properties for processor including clock speed , Number of cores and Number of physical processsorts
	#if the lenght of the object cpuresult is greater than 0 , then there are more than one instance of the Win32_processor class which means
	#there are more than one physical processor on the server , since all physical cpuz on the same board are identical then getting the result
	#from object[0] in the collection does the trick
	if ($CpuResult.length )
		{
		$Computer | Add-Member Noteproperty CpuMHZ ($cpuresult[0].maxclockspeed)
		$Computer | Add-Member Noteproperty ProcessorCores ($CpuResult[0].NumberOfCores)
		$Computer | Add-Member NoteProperty PhysicalProcessors ($CpuResult.length)
		
	}
	elseif ( -not $CpuResult.length) 
		{ 
		$Computer | Add-Member Noteproperty CpuMHZ ($cpuresult.maxclockspeed)
		$Computer | Add-Member Noteproperty ProcessorCores ($CpuResult.NumberOfCores)
		$Computer | Add-Member NoteProperty PhysicalProcessors ('0')
	}
	
	#Adding a property for total number of Rams
	#doing a ram counter and accumelating the capacity property of all the instances of Win32_PhysicalMemory Class
	$ramcounter = 0
	$RamResult | ForEach-Object { $ramcounter = $ramcounter + $_.Capacity }
	$Computer | Add-Member NoteProperty RAMS ($ramcounter / 1048576)
	
	#Adding property for total Disk space 
	$storagecounter = 0
	$DiskResult | ForEach-Object {
							if ($_.mediatype -eq "Fixed hard disk media")
							{$storagecounter = $storagecounter + $_.size}
	}
	$Computer | Add-Member NoteProperty TotalStorageGB ([int]($storagecounter / 1gb ))
	
	#Adding properties for OS type and Version number
	$Computer | Add-Member NoteProperty OSType ($OSResult.caption)
	$Computer | Add-Member NoteProperty Servicepack ($OSResult.csdversion)
	
	#adding a property for the installed applications
	$apparray = ""
	$appresult | ForEach-Object { $apparray = ( $apparray + $_.name + "," ) }
	$Computer | Add-Member Noteproperty AppList ( $apparray )
	
	Write-Output $Computer
		}
		
	End {
	Write-host "End of Inventory Collection"
	}
	
				}

# <<<<<<  Script execution Starts HERE  >>>>>>>		

#comment this part out if you want to create a connection to Active directory to get the computer objects
#connecting to AD to query computers in a security group named "servers"
$servergroup=[ADSI]"LDAP://CN=Servers,DC=example,DC=local" 
#Set your location for AD group containing servers
#$groupmembers=$servergroup.member

#Actual command being line (pipeline)

# you can use Get-hostinfo function in the following Ways
$groupmembers | get-hostinfo | Select Name , IPAddress , Sitelocation , SrvModel , TotalStorageGB , RAMS , CpuMhz , ProcessorCores , PhysicalProcessors, Applist | Export-Csv C:\spiderresult.csv
#$groupmembers | get-hostinfo | Select Name , OSType , Servicepack ,  IPAddress , Sitelocation , SrvModel , TotalStorageGB , RAMS , CpuMhz , ProcessorCores , PhysicalProcessors , Applist | Export-Clixml c:\test\spiderobj.xml
#Get-Content c:\servers.txt | Select Name , IPaddress , Srvmodel | Export-csv C:\output.csv        "getting content from alocal file"
#$groupmembers | get-hostinfo | Select Name , OSType , Rams , Cpumhz  | export-clixml c:\compobjs.xml 
