# Purpose: Get-HotFixReports — Windows Update and patch management.
#create an HTML hotfix report
# Get-HotFixReports.PS1 
Param(
[int]$Days = 45,
$Path = "C:\HTMLReports\HotFixReport.htm"
)
 
#import computer information
# $computers = Import-Csv C:\HTMLReports\computers.csv
$computers = Get-Content C:\HTMLReports\serverslist.txt 

#dot source the hot fix function
# . C:\scripts\AdvancedFunction-HotfixReport.ps1
 
#get all hotfixes installed since $Days days ago
Write-Host "Getting hot fix data...please wait" -foregroundcolor magenta
#group data by computername
$data = $computers | Get-HotFixReports -After (Get-Date).AddDays(-$days) | Group-Object -Property Computername
 
Write-Host "Preparing report..." -foregroundcolor magenta
#initialize an empty array
$fragments=@()
 
#create a fragments for each computername
foreach ($item in $data) {
    #define a heading with the computer name and total number of hotfixes
    $fragments+="<H2>$($item.name) [$($item.count)]</H2>"
    #convert data to an XML fragment
    [xml]$frag = $item.Group | Select-Object -Property * -ExcludeProperty Computername |
    ConvertTo-HTML -Fragment -as Table  
 
    #insert security class for Security Updates
    $frag.SelectNodes("//td[text()='Security Update']") | foreach {
      $class = $frag.CreateAttribute("class")
      $class.value = 'security'
      $_.Attributes.append($class) | Out-Null
    }
 
    #turn urls into links. This assumes the entire text value is a url
    $frag.SelectNodes("//*[contains(text(),'http')]") | foreach {
       #get the current value
      $url = $_.'#text'
      #replace the value with html link
      $_.'#text' = "<a href=$url target=_blank>$url</a>"
    }
 
    #replace XML characters for <> in the body
    $fragments+= $frag.InnerXml.replace("&lt;","<").Replace("&gt;",">" )
}
 
#html report title
$ReportTitle = "Company Hotfix Report - $Days Days"
 
#define a header with an embedded style sheet   
$head = @"
<Title>$ReportTitle</Title>
<style>
body { background-color:#D5DBDB;
       font-family:Tahoma;
       font-size:10pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
table { width:95%;margin-left:5px; margin-bottom:20px;}
.security { color:red;}
</style>
<br>
<H1>$ReportTitle</H1>
"@
 
$footer = "<H5><i>Report run $(Get-Date)</i></H5>"
 
#create the HTML report and save to a file
ConvertTo-HTML -Head $head -body $fragments -PostContent $footer | Out-File -FilePath $Path -Encoding ascii
 
#display the file object
Get-item -Path $path