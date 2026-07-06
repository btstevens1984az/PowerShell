# Purpose: Get-ComputerWmiInformation — Windows desktop configuration and management.
# ------------------------------------------------------------------------
# DATE: 7/9/2009
#
# KEYWORDS: Get-WmiObject, Param, Function,
# If statement, [switch]
# COMMENTS: This script uses a number of functions
# to retrieve basic wmi information from a local or remote 
# computer. Which wmi functions are called is controlled 
# via the command line parameters. 
#
# ------------------------------------------------------------------------
Param(
   [string]$computer=$env:computerName,
   [switch]$disk,
   [switch]$processor,
   [switch]$memory,
   [switch]$network,
   [switch]$video,
   [switch]$all
) #end param

Function Get-Disk($computer)
{
 Get-WmiObject -class Win32_LogicalDisk -computername $computer
} #end Get-Disk

Function Get-Processor($computer)
{
 Get-WmiObject -class Win32_Processor -computername $computer
} #end Get-Processor

Function Get-Memory($computer)
{
 Get-WmiObject -class Win32_PhysicalMemory -computername $computer
} #end Get-Processor

Function Get-Network($computer)
{
 Get-WmiObject -class Win32_NetworkAdapter -computername $computer
} #end Get-Processor

Function Get-Video($computer)
{
 Get-WmiObject -class Win32_VideoController -computername $computer
} #end Get-Processor

Function Get-CommandLineOptions
{
  
if($all) 
  {
    Get-Disk($computer)
    Get-Processor($computer)
    Get-Memory($computer)
    Get-Network($computer)
    Get-Video($computer)
     exit
  } #end all

if($disk) 
  {
    Get-Disk($computer)
  } #end disk

if($processor) 
  {
    Get-Processor($computer)
  } #end processor

if($memory) 
  {
    Get-Memory($computer)
  } #end memory

if($network) 
  {
    Get-Network($computer)
  } #end network

if($video) 
  {
    Get-Video($computer)
  } #end video
} #end function Get-CommandLineOptions

# *** Entry Point to Script ***

Get-CommandLineOptions