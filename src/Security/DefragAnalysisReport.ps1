# Purpose: DefragAnalysisReport — Security auditing and compliance checks.
# ------------------------------------------------------------------------
# DATE: 1/17/2009
#
# KEYWORDS: Desktop management, Defrag, WMI
# win32_Volume, Foreach-Object begin, process, end
# Format-List
# COMMENTS: This script will accept an array of computer
# names. It then uses wmi to connect to each computer and
# do a defrag analysis. It creates a text file based upon the
# name of the computer. if the text file does not exist, it
# creates the file, otherwise it will append to the file. The
# file is stored locally in the filesystem of the launching 
# computer. NOT on the computer being defraged.
# You will need to have local administrator rights on the
# remote computer being defragged. By default it is using
# logged on credentials of the person who launched the 
# script.
#
# ------------------------------------------------------------------------
$arycomputer = "Vista","Berlin"
$FilePath = "C:\fso"
Foreach($Computer in $aryComputer)
{
 Get-WmiObject -Class win32_volume -Filter "DriveType = 3" `
       -ComputerName $computer | 
 ForEach-Object `
 -Begin { "Testing $computer" } `
 -Process { 
   "Testing drive $($_.name) for fragmentation. Please wait ..."
   $RTN = $_.DefragAnalysis()
  "Defrag report for $computer" >> "$FilePath\Defrag$computer.txt"
  "Report for Drive $($_.Name)" >> "$FilePath\Defrag$computer.txt"
  "Report date: $(Get-Date)" >> "$FilePath\Defrag$computer.txt"
  "--------------------------------" >> "$FilePath\Defrag$computer.txt"
   $RTN.DefragAnalysis | 
   Format-List -Property [a-z]* >> "$FilePath\Defrag$computer.txt"
} `
 -END { "Completed testing $computer" }
} #end foreach computer
