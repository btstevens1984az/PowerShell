# Purpose: 3_Send-Email — General-purpose PowerShell utilities.
Import-Module ActiveDirectory

function Send-Report
    {
        [CmdletBinding()]
        param
            (
                [string[]]$to,
                [string]$subject="Automated Emailed",
                [string[]]$attachment,
                [string]$from="admin@example.com",
                [string]$body="This Message was sent by Automated Process"
            )

        BEGIN 
            {
                $smtp_server = "smtp.example.com"
                $smtp_port = 25
            }
        PROCESS 
            {
                Try
                    {
                      Send-MailMessage -To $to -Subject $subject -Attachments $attachment -BodyAsHtml $Body -SmtpServer $smtp_server -From $from
          
                    }
                Catch
                    {
                        "$satellite : $_.Exception.Message ";Continue
                    }
            }
        END {}
        

    }

function New-Zip
{
	param([string]$zipfilename)
	set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
	(dir $zipfilename).IsReadOnly = $false
}

function Add-Zip
{
	param([string]$zipfilename)

	if(-not (test-path($zipfilename)))
	{
		set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		(dir $zipfilename).IsReadOnly = $false	
	}
	
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($zipfilename)
	
	foreach($file in $input) 
	{ 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 500
	}
}



$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition #get directory of the script.
$today = Get-date -format MMddyyyy 
write-host $today


#      logic for Patch Reports
#
$Path = ("{0}\Satellite_report.csv" -f $scriptPath)
#$zipFile = ("{0}\reports_{1}.zip" -f $path,$today)

#Grabs all todays report in zip file in case they want to review.
#$FilesToZip = Get-ChildItem $Path -Exclude *.zip | Where-Object { (get-date $_.LastWriteTime -format MMddyyyy) -ge $today }   #foreach will fix and convert it to string[] otherwise errors because it doesn't know FullName prop
#foreach($file in $filesToZip) { write-host $file.fullname;$file | add-zip $zipFile }

[string[]] $attachment = $Path 

#this will send ent report in body.
#[string]$ent_Patch = Get-Content ("{0}\Reports\Ent_Report_{1}.html" -f $scriptPath,$today)
$body = "Satellite Report."
send-report -to $to -body $body -attachment $attachment

#clean up 

