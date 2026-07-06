# Purpose: InactiveMove — General-purpose PowerShell utilities.
# powershell 2
# kerry k 
# dsquery to get list of computers inactive for 8 weeks
# read list into move to  OU=OldComputers

dsquery computer -inactive 8 >>inactiveXXX.txt

C:\>for /F %x in ('type inactiveXXX.txt') do (dsquery computer -samid %x$) | dsmove %x -newparent ou=oldcomputers,DC=example,DC=local
