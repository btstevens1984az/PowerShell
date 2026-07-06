# Purpose: ClientCustimazion-DefaultApps — Microsoft Intune endpoint management.
#region Description
<#
       ===========================================================================
       Created on:         2020/11/28
       Filename:           ClientCustimazion-Part2.ps1

       Find us on:
             * Website:  https://www.msb365.blog
             * Technet:  https://social.technet.microsoft.com/Profile/MSB365
             * LinkedIn: https://www.linkedin.com/in/drago-petrovic/
             * Xing:     https://www.xing.com/profile/Drago_Petrovic
       ===========================================================================
       .DESCRIPTION




       .COPYRIGHT
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
       to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
       and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
       FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
       WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
       ===========================================================================
       .CHANGE LOG
             V0.10, 2020/02/18 - Initial version




--- keep it simple, but significant ---


--- by MSB365 Blog ---

#>
#endregion
# Set ExecutionPolicy and install Chocolatey
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('http://internal_raw_url/ChocolateyInstall.ps1'))
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Start-Sleep -s 1
choco install firefox googlechrome vlc 7zip.install notepadplusplus.install keepass filezilla putty protonvpn teamviewer -y
Start-Sleep -s 2
choco install brave -y
Start-Sleep -s 2
choco install adobereader -y
Start-Sleep -s 2
choco install forticlientvpn -y
Start-Sleep -s 1
refreshenv
Start-Sleep -s 1