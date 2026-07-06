@echo off
sc config mpssvc start= auto
sc start mpssvc
NetSh Advfirewall set allprofiles state off
exit