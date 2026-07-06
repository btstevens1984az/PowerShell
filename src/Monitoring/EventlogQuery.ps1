# Purpose: EventlogQuery — System monitoring and alerting.
get-wmiobject Win32_NtlogEvent -filter "logfile='application' and eventtype=1 and SourceName='userenv'"