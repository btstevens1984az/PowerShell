# Purpose: RegExCommonMistakes — General-purpose PowerShell utilities.
"test" -like "T*"
"test" -match "Tk*"# * Matches 0 or more of the preceeding token.
"test" -like "Tk*" 
"test" -match "Te+" # + is 1 or more
"etest" -match "T*"
"Test" -match "^T\w+" # \w = [a-zA-Z_0-9]
"Test" -like "T*"

#keep in mind -match is case insensitive