# Purpose: PowerBall — General-purpose PowerShell utilities.
#how long will it take Powershell to guess the correct Powerball numbers
$currentWhiteWinners = 8,10,29,40,59
$CurrentPowerBall = 26
function Get-NormalNumber {
    param ([int[]]$numbers)
             $num = Get-Random -Minimum 1 -Maximum 69 
             if ($num -in $numbers)
             {
                $num = Get-NormalNumber
             }
             $num
         }
Function Get-NormalNumbers
{
    $normalNumbers = @()
    for($i=1;$i -le 5;$i++)
{
   $normalNumbers +=  Get-NormalNumber $normalNumbers
   
}
    $normalNumbers
}
$WhiteNumbers = Get-NormalNumbers
$powerBall = Get-Random -Minimum 1 -Maximum 29

measure-command -Expression {

$count = 0

Do
{
        $count++
        if ($count % 5000 -eq 0)
        {Write-Progress -Activity "Attempting to Match Winning Powerball Numbers" -Status "Attempt: $count" -PercentComplete (($count/292201338) *100)}
        $WhiteNumbers = Get-NormalNumbers
        $powerBall = Get-Random -Minimum 1 -Maximum 29

}until (-not(Compare-Object $currentWhiteWinners $WhiteNumbers) -and ( $CurrentPowerBall -eq $powerBall))
Write-host "I've matched Powerball with Powershell"
}