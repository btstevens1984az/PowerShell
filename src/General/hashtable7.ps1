# Purpose: hashtable7 — General-purpose PowerShell utilities.
# Create variables to contain the data we wish to pass into New-ADuser. 
# these might be drawn from multiple sources. SQL, HR, user input, etc.

$path="OU=Finance,OU=Personnel,DC=contoso,DC=com"
$Lastname="Hopper"
$FirstName="Grace"
$Title="Rear Admiral"
$Name="HopperG"

# Imagine we have received these values from files or database or user input, etc.
# The list of parameters could be quite large. For example, New-ADuser accepts
# over fifty parameters! We can build up all the values into some single hash
# table, the key names matching the cmdlet arguments

$splat = @{"Name"=$Name;"Surname"=$LastName;"GivenName"=$FirstName;"Path"=$path;"Title"=$Title}

# and now call the cmdlet, with this single hashtable reference, 
# using the form @hashtable

New-ADUser @splat

# Consider creating a simple function within a script and pass arguments using "splatting". 

