# Purpose: ResetOffice365 — Microsoft 365 tenant administration.
#Step1
$VbsPath ="C:\Program Files\Microsoft Office\Office15\OSPP.VBS"

$output = cscript $VbsPath /dstatus
$Keys  = $output | Select-String -Pattern "Last 5 characters of installed product key:" | Select-Object -ExpandProperty line |
            ForEach-Object { $_.substring($_.length -5)}
$keys | ForEach-Object {

      cscript $VbsPath "/unpkey:$_"
}

#Step2
dir HKCU\Software\Microsoft\Office\15.0\Common\Identity\Identities -Recurse | Remove-Item 

#Step3 Credmgr
$OfficeCreds = cmdkey /list | Select-string -Pattern "Office15" | ForEach-Object {($_.line -split "target=")[1]   }
$OfficeCreds | ForEach-Object { cmdkey "/delete:$_"}

#Step4
cscript $VbsPath  /act