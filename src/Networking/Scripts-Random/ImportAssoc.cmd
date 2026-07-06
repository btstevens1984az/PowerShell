@echo off
dism.exe /online /Import-DefaultAppAssociations:"%~dp0defaultapps.xml"