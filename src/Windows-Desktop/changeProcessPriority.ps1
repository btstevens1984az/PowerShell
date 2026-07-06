# Purpose: changeProcessPriority — Windows desktop configuration and management.
$note =Get-Process notepad
$note.PriorityClass = "BelowNormal"

#use below line if more than one process
#$note | %{$_.priorityclass= "belownormal"}

#another way
#Get-Process notepad | %{$_.priorityclass = "belownormal"}
#Get-process notepade |  FL name,priorityclass
