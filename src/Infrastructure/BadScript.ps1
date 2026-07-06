# Purpose: BadScript — Core infrastructure automation scripts.
# ------------------------------------------------------------------------
# DATE: 8/22/2009
#
# KEYWORDS: template
#
# COMMENTS: This script has a couple of errors in it
# 1. TimesOne function multiplies by 2
# 2. Script pipelines input but function does not take pipe
# 3. Script divides by 0
#
#
# ------------------------------------------------------------------------

Function AddOne([int]$num)
{
 $num+1
} #end function AddOne

Function AddTwo([int]$num)
{
 $num+2
} #end function AddTwo

Function SubOne([int]$num)
{
 $num-1
} #end function SubOne

Function TimesOne([int]$num)
{
  $num*2
} #end function TimesOne

Function TimesTwo([int]$num)
{
 $num*2
} #end function TimesTwo

Function DivideNum([int]$num)
{ 
 12/$num
} #end function DivideNum

# *** Entry Point to Script ***

$num = 0
SubOne($num) | DivideNum($num)
AddOne($num) | AddTwo($num)
