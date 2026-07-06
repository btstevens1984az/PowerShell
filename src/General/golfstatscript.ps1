# Purpose: golfstatscript — General-purpose PowerShell utilities.
$url = "http://www.pgatour.com/stats/stat.109.html"
$r = Invoke-WebRequest $url -UseBasicParsing
$arr =  Get-WebRequestTable $r -TableNumber 1

cls
$rosters = Get-Content -Path .\teams.txt | ConvertFrom-StringData

$rtw = "RANK THIS WEEK"
$rlw = "RANK LAST WEEK"
$pn = "PLAYER NAME"
$e = "EVENTS"
$m = "MONEY"
$ytdv = "YTD VICTORIES"


foreach ($playerinfo in $arr) {
foreach ($player in $rosters) {
for($i=1; $i -le 13; $i++) {
$mykey = ('DK' + [string]$i)
#Write-Output '$mykey ' = $mykey
#Write-Output '$player.$mykey ' = $player.$mykey
#Write-Output '$player.keys ' = $player.keys
#$playerinfo | gm
#Write-Output '$player.values ' = $player.values
#Write-Output '$playerinfo.P3 ' = $playerinfo.P3
#Write-Output '$playerinfo.value ' = $playerinfo.value
#pause
#if ($player.values -eq $player.$mykeys) {
if ($playerinfo.P3 -eq $player.values) {
$myHash = @{ 
$mykey = @{
"PlayerName" = $player.values
"RankThisWeek" = $playerinfo.P1
"RankLastWeek" = $playerinfo.P2
"Events" = $playerinfo.P4
"Money" = $playerinfo.P5
"YTDVictories" = $playerinfo.P6
}
}
#Write-Output '$myHash = ' $myHash
#$myHash | gm
#pause
}
#}
}
}
}


$myHash.keys | ForEach-Object {Write-Output $_["DK13"]}