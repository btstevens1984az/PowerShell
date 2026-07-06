# Purpose: OpenPasswordProtectedWord — Security auditing and compliance checks.
# ------------------------------------------------------------------------
# DATE: 6/21/2009
#
# KEYWORDS: Excel.Application, password, param,
# workbooks.open
# COMMENTS: This script accepts a filename and a
# password from the command line, and opens a password
# protected word document
#
# Windows PowerShell 2.0 Best Practices
# ------------------------------------------------------------------------
#Requires -version 2.0
Param(
  [Parameter(Mandatory=$true)]
  [string]$fileName,
  [Parameter(Mandatory=$true)]
  [string]$password
)
Function Open-PasswordProtectedDocument($filename,$password)
{
 $Conversion= $false
 $readOnly = $false
 $addRecentFiles = $false
 $doc = New-Object -Comobject Word.Application
 $doc.visible = $true
 $doc.documents.open($filename,$Conversion,$readOnly,$addRecentFiles,$password) |  
 out-null
} #end function Open-PasswordProtectedDocument

# *** Entry Point to Script ***

Open-PasswordProtectedDocument -filename $filename -password $password