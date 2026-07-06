# Purpose: EnableMoreDSCLogging — Core infrastructure automation scripts.
#Verbose logging stored in Analytic Log
Update-xDscEventLogStatus -Channel Analytic -Status Enabled -ComputerName 105.88.133.105
#Debug log tends to have lower level LCM processing information
Update-xDscEventLogStatus -Channel debug -Status Enabled -ComputerName 105.88.133.105