# Purpose: inactive8weeksMOVE — General-purpose PowerShell utilities.
dsquery computer -inactive 8 -scope subtree -limit 0|dsmove -newparent OU=OldComputers,DC=example,DC=local