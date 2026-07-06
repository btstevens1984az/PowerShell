# Purpose: Get-HostNameWMIwithIP — General-purpose PowerShell utilities.
# use start-transcript to get log of script actions
# change machine data list path and file name to current location and file name of server list

# $LogOutputTrans = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckHostNameWMIfromIPList.txt")
# start-transcript -Path "\\114.148.18.125\updatesinventory$\Transcripts\$LogOutputTrans" -IncludeInvocationHeader

$ErrorActionPreference= 'SilentlyContinue'

# $WordToFind= "srvadmin"
$MachineIP = get-content "c:\PStemp\IPList.txt"
$LogOutputName = $((Get-Date).ToString('yyyyMMdd-hhmm') + "_CheckHostName.txt")
# $timeStarted = get-date
 Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems starting processing at $timeStarted"

	foreach ($computerIP in $MachineIP) {
		Write-Host -ForegroundColor Yellow $ComputerIP " is processing now"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "************************"
		Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ComputerIP is processing now"
		
# test if online
		
		If ((Test-Connection -computername $ComputerIP -Quiet) -eq $true) {
		
#get hostname from WMI

		$LocalComputerName = Get-WmiObject -Class Win32_ComputerSystem -Namespace "root\cimv2" -ComputerName $ComputerIP | Select-Object Name
		
		$Namefound = $localComputerName.name
#
				Write-Host -ForegroundColor Yellow $ComputerIP is $LocalComputerName
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "$ComputerIP $NameFound"
	}
		
	Else { 
				Write-Host -ForegroundColor RED $ComputerIP "NOT ONLINE"
				Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName"  "$ComputerIP not online No further processing done"			
				}
				
			Write-Host -ForegroundColor Yellow $ServerItem Completed 
			Write-Host "     Next System        "
			Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " $ServerItem Completed "
			Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" " "
}
Write-Host -ForegroundColor GREEN "All systems have completed processing"
$timeCompleted = get-date
Add-Content "\\114.148.18.125\UpdatesInventory$\$LogOutputName" "All systems have completed processing $timeCompleted"

# SIG # Begin signature block
# MIIVPwYJKoZIhvcNAQcCoIIVMDCCFSwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTveBF8sIdji0PuF+gmmU2xG9
# WmygghAlMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BJ8wggOHoAMCAQICEhEh1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQUFADBS
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UE
# AxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAeFw0xNjA1MjQwMDAw
# MDBaFw0yNzA2MjQwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8wHQYDVQQKExZHTU8g
# R2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxTaWduIFRTQSBmb3Ig
# TVMgQXV0aGVudGljb2RlIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal+oTDYUDFRrVZUjtC
# oi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1AcjzyCXenSZKX1GyQ
# oHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFFWbIub2Jd4NkZrItX
# nKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7spTj1Tk7Om+o/SWJMV
# TLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5crCpGTkqUPqp0Dw6
# yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAOBgNVHQ8BAf8EBAMC
# B4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6
# Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADAWBgNV
# HSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIuY3JsMFQGCCsGAQUF
# BwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNv
# bS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0OBBYEFNSihEo4Whh/
# uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0hZuw3WrWFKnBMA0G
# CSqGSIb3DQEBBQUAA4IBAQCPqRqRbQSmNyAOg5beI9Nrbh9u3WQ9aCEitfhHNmmO
# 4aVFxySiIrcpCcxUWq7GvM1jjrM9UEjltMyuzZKNniiLE0oRqr2j79OyNvy0oXK/
# bZdjeYxEvHAvfvO83YJTqxr26/ocl7y2N5ykHDC8q7wtRzbfkiAD6HHGWPZ1BZo0
# 8AtZWoJENKqA5C+E9kddlsm2ysqdt6a65FDT1De4uiAO0NOSKlvEWbuhbds8zkSd
# wTgqreONvc0JdxoQvmcKAjZkiLmzGybu555gxEaovGEzbM9OuZy5avCfN/61PU+a
# 003/3iCOTpem/Z8JvE3KGHbJsE2FUPKA0h0G9VgEB7EYMIIHZjCCBk6gAwIBAgIT
# YwAArxjmdIZS9nwHvAAAAACvGDANBgkqhkiG9w0BAQsFADBEMRMwEQYKCZImiZPy
# LGQBGRYDZWR1MRMwEQYKCZImiZPyLGQBGRYDY2h3MRgwFgYDVQQDEw9EaWduaXR5
# SGVhbHRoSUEwHhcNMTcxMDI3MTUxMTQ3WhcNMTgxMDI3MTUxMTQ3WjCBwzETMBEG
# CgmSJomT8ixkARkWA2VkdTETMBEGCgmSJomT8ixkARkWA2NodzEXMBUGA1UECwwO
# UmVnaW9uYWxfU2l0ZXMxDTALBgNVBAsTBEFaTlYxDDAKBgNVBAsTA1BIWDEOMAwG
# A1UECxMFVXNlcnMxHzAdBgNVBAMTFlN0ZXZlbnMsIEJyYW5kb24gLSBQSFgxMDAu
# BgkqhkiG9w0BCQEWIUJyYW5kb24uU3RldmVuc0BEaWduaXR5SGVhbHRoLm9yZzCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALonq2L7UxgH0oJLs2mkibSV
# JaInCBpljrai6Fh5a81gY5DSG9ahBkX1XNhnPonJwiO1RxXWY2wY/VESr3Dd/Dvu
# 3lTdRYYhiLG6pSItjTVw6Ve1scDRzZe9pR06ctH6Riugt2Cu9BMG1r1ucY6wzBWI
# 7sDxN/4ki6yRxu2S8/K8fzn4zt4NdhYnKzyT5i7BBVv9rRkcMOjo1N7qI5k5+xq8
# t59i0kvS7NUlI6tov/V6lWY8WIVOAOYnTE76diUqt+QeMkod+2hCvzhUWFGFcPeS
# xfE+0mptf16iOhF8lvjDsGGkgFfWRRUWhIDuX2qxNWCoWAoTIE8nrlpVJUHwrgMC
# AwEAAaOCA88wggPLMAsGA1UdDwQEAwIFoDA9BgkrBgEEAYI3FQcEMDAuBiYrBgEE
# AYI3FQiH8v4ng9G4IIP9nx+E8vIJhMrDDoFXyucQhaf/QgIBZAIBFDBEBgkqhkiG
# 9w0BCQ8ENzA1MA4GCCqGSIb3DQMCAgIAgDAOBggqhkiG9w0DBAICAIAwBwYFKw4D
# AgcwCgYIKoZIhvcNAwcwHQYDVR0OBBYEFAWQPyFOlS2mhywBH7S6mkxciB2CMB8G
# A1UdIwQYMBaAFPI0vBtLV30VNENMtdxkgzZ355kCMIIBCQYDVR0fBIIBADCB/TCB
# +qCB96CB9IaBt2xkYXA6Ly8vQ049RGlnbml0eUhlYWx0aElBLENOPVBIWC1WQVBQ
# LTUzOCxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vydmlj
# ZXMsQ049Q29uZmlndXJhdGlvbixEQz1jaHcsREM9ZWR1P2NlcnRpZmljYXRlUmV2
# b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2lu
# dIY4aHR0cDovL2NlcnRzcnYuZGlnbml0eWhlYWx0aC5vcmcvcGtpL0RpZ25pdHlI
# ZWFsdGhJQS5jcmwwggFNBggrBgEFBQcBAQSCAT8wggE7MIGqBggrBgEFBQcwAoaB
# nWxkYXA6Ly8vQ049RGlnbml0eUhlYWx0aElBLENOPUFJQSxDTj1QdWJsaWMlMjBL
# ZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNo
# dyxEQz1lZHU/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwWQYIKwYBBQUHMAKGTWh0dHA6Ly9jZXJ0c3J2LmRpZ25p
# dHloZWFsdGgub3JnL3BraS9QSFgtVkFQUC01MzguY2h3LmVkdV9EaWduaXR5SGVh
# bHRoSUEuY3J0MDEGCCsGAQUFBzABhiVodHRwOi8vY2VydHNydi5kaWduaXR5aGVh
# bHRoLm9yZy9vY3NwMB0GA1UdJQQWMBQGCCsGAQUFBwMEBggrBgEFBQcDAjAnBgkr
# BgEEAYI3FQoEGjAYMAoGCCsGAQUFBwMEMAoGCCsGAQUFBwMCMFEGA1UdEQRKMEig
# IwYKKwYBBAGCNxQCA6AVDBNic3RldmVuczAwN0BjaHcuZWR1gSFCcmFuZG9uLlN0
# ZXZlbnNARGlnbml0eUhlYWx0aC5vcmcwDQYJKoZIhvcNAQELBQADggEBADwO96VE
# ttH18MDJWBVigqfmS4KCMxZatD853p+t4zMTowd/dNBvJde38H9ZImMPig0zgLaM
# rz46yhu4OCqJkpqIJ93YHiaWy7keU0nH1p3zxDAiI7GEgV+UBKGZN5d2rJ1TPzyz
# yf3wNnBvZq7S4IngEcNgZYaTLGjfgvGF+Uv8FeUCBR6bua5Kt6cJV7TWtDdtB2X8
# lmD64GVR+vZ1g/xpo6emIrVVZGTXXq6OKiBTc7DjCV0mleHShyMezl9RSnB6In7s
# LvjdoAnDoORIkzDv2uLnKnHMiz+vLMvRLmuRA3A13Ye/g2TQOMq90bP5xbRo6ZQB
# nGf9NIS1i7CVVJMxggSEMIIEgAIBATBbMEQxEzARBgoJkiaJk/IsZAEZFgNlZHUx
# EzARBgoJkiaJk/IsZAEZFgNjaHcxGDAWBgNVBAMTD0RpZ25pdHlIZWFsdGhJQQIT
# YwAArxjmdIZS9nwHvAAAAACvGDAJBgUrDgMCGgUAoFowGAYKKwYBBAGCNwIBDDEK
# MAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAjBgkqhkiG9w0B
# CQQxFgQUzdQzSg3BfxWqVA+FjQf5aDb0lxswDQYJKoZIhvcNAQEBBQAEggEAEpae
# ELKCcE+Kg4mIs7xR4i7cfbO68BLta2Zm4EqzqoGUSquDdMSQit/F5r6CwXG+I/Xf
# 8uINXrz4p70a83Z5sNRUm9ZeIEgeaT2p0URIkE8MuHlrGKDGwlsORo/5rvlDQ8d8
# ycfasNa3YyMsyU2BpohZLtG+bMJJdHmh2D4LPLgwvdtUsjNjMMAj0siJZTZrmtqr
# NLU6MoJix061A0FQSE3HeFZTX3oBa0KN80wolEHXF7FH1a1NkC+NROSA/95/3Y3D
# rjzDRRpl5EqzK3dQsIrnFl8u44yPxekDGBIW0w39DBqJ4QEMVComKApTYIZF1rYE
# yE1d5Cfc7WWnbXyjA6GCAqIwggKeBgkqhkiG9w0BCQYxggKPMIICiwIBATBoMFIx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQD
# Ex9HbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIEcyAhIRIdaZp2SXPvH4Qn7p
# GcxTQRQwCQYFKw4DAhoFAKCB/TAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwG
# CSqGSIb3DQEJBTEPFw0xNzExMDIxNzM5NThaMCMGCSqGSIb3DQEJBDEWBBT/fDgY
# day+8iPSFlQFboZre9TLAzCBnQYLKoZIhvcNAQkQAgwxgY0wgYowgYcwgYQEFGO4
# L6th9YOQlpUFCwAknFApM+x5MGwwVqRUMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJKoZIhvcNAQEBBQAE
# ggEAdh6mX8sm25dyz9nNQu8IkAjQ1RZD9cxOTyGiq8cpJvq8BABFpB4GyGm5OFOf
# CwsIr+fJ4kgLwI4HAAbzHxknMRQEwmB2D/RZvCeDJy/h49Y3NPDdgsDd6eXnjgoy
# fgaV1fnNCODL5V/yURfNXOYhW0dYUEoYpimsTXGASjAqaxwD3V4QjbKVgaEmI9Vv
# RDuyKXx258YSuzCqLBYJDlMmYbDu4Pl5pVuCgk90yezVPP+G5B8c5W4EOBXEvOLL
# s/CC7poMD4v5kVNej1YvuvFfNrWk+RdhoKByqDOpgPqH/DUAkSm4PMXS/eECKYRd
# o/rFLDjseMLyvZsuQWEAECMhyw==
# SIG # End signature block
