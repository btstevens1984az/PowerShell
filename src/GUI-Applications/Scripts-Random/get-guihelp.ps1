# Purpose: get-guihelp — PowerShell automation.
function get-guihelp

{

 

if (!$args[0])

    {$a ="HH.EXE mk:@MSITStore:C:\powershell help\powershell.chm::/test.htm"

     Invoke-Expression $a;break}

 

   if ($args[0].contains("about_"))

 

       {$a = "HH.EXE mk:@MSITStore:C:\powershell help\powershell.chm::/about/" + $args[0] + ".help.htm"

        Invoke-Expression $a}

 

   elseif ($args[0].contains("-"))

 

       {$a = "HH.EXE mk:@MSITStore:C:\powershell help\powershell.chm::/cmdlets/" + $args[0] + ".htm"

         Invoke-Expression $a}

 

   else

 

       {if ($args[0].contains(" "))    

 

           {$b = $args[0] -replace(" ","")

            $a = "HH.EXE mk:@MSITStore:C:\powershell help\powershell.chm::/vbscript/" + $b + ".htm"

            Invoke-Expression $a

           }

 

       else

  

           {$b = $args[0]

            $a = "HH.EXE mk:@MSITStore:C:\powershell help\powershell.chm::/vbscript/" + $b + ".htm"

            Invoke-Expression $a

            }

 

$a

       }

}