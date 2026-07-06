# Purpose: loadscripts — Core infrastructure automation scripts.
#loadscripts
#function with dot source all ps1 files in a specified directory
#be sure to dot source the loadscripts function itself
#usage: 
# . loadscripts \\240.217.252.191\share\directory

function loadscripts
{
	param($directory=$(throw "need to specify a directory"))
	dir $directory -rec -Include *.ps1 | %{invoke-expression ". $($_.Fullname)"}
}