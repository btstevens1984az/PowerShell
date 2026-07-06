# Purpose: CreateFiles — Storage management and disk operations.
#this demo convers:
#.. to create an array with a specific range of number
# foreach loop
#invoke-Expression cmdlet
$a = 1..255

foreach ($i in $a)
{
	invoke-expression "fsutil file createNew c:\temp\mynewfile$i.txt 1000"
}