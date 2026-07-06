# Purpose: ExportProcess-ToXML — Cross-cutting logging, error handling, and utilities.
ExportProcess-ToXML {
Get-Process | Export-Clixml C:\temp\mynewprocesses.xml
notepad C:\Temp\mynewprocesses.xml
}
