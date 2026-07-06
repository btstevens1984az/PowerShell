# Purpose: CmdtoObj — General-purpose PowerShell utilities.
$results = qwinsta /server:localhost 
$pattern = "(?<id>\d+)\s+(?<state>Disc|Active|Conn\w*)"
#Names Capture Groups apparently don't wortk with select-string
$r = $results | Select-String -Pattern $pattern  #AllMatches
$objs = foreach ($line in $r)
{
    [pscustomobject]@{
                        id =$line.Matches.groups.value[1]
                        State= $line.Matches.groups.value[2]
                        line = $line.tostring()
                        }
}

#Named Capture Groups work with -match
$objs = Foreach ($line in $results)
{
    if($line -match $pattern)
    {
    [pscustomobject]@{
                        id =$Matches.id
                        State= $Matches.state
                        line = $line
                        }      
    }
}
$objs