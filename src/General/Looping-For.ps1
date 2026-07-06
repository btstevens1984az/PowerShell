# Purpose: Looping-For — General-purpose PowerShell utilities.
# date is beginning of the year
$BoY=(Get-Date).AddDays( -(get-date).DayOfYear )

for ($i=1; $i -LT 365; $i++) {

  $day1=$BoY.AddDays($i);
  $day2=$BoY.AddDays($i+1)
#
# if one (and only one) has changed, then we flipped over!
#
  if ($day1.IsDaylightSavingTime() -XOR $day2.IsDaylightSavingTime()) {
    "Daylight Savings switch: {0:D}" -f $day2 
  }
}