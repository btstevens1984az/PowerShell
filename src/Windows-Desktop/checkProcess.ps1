# Purpose: checkProcess — Windows desktop configuration and management.
$erroractionpreference = "Continue" # shows error message, but continue
$error.clear()
# DEBUG MODE : $erroractionpreference = "Inquire"; "`$error = $error[0]"
$myName = $MyInvocation.MyCommand.Name

#  ### New Variables ###
# Start with empty parameters (launch arguments)
$params   = '';
# Define hash/associative array of known paths for executable files
# IMPORTANT: key needs to match executable name for STOP wait and mode to work
# NOTE: start arguments are added later so that the same path can be used for starting and stopping processes (executables)
$knownPaths = @{
    'bttray'               = "$env:ProgramFiles\WIDCOMM\Bluetooth Software\BTTray.exe"; `
    'chrome'               = "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"; `
    'concentr'             = "$env:ProgramFiles\Citrix\ICA Client\concentr.exe"; `
    'communicator'         = "$env:ProgramFiles\Microsoft Office Communicator\communicator.exe"; `
    'dropbox'              = "$env:APPDATA\Dropbox\bin\Dropbox.exe"; `
    'evernote'             = "$env:ProgramFiles\Evernote\Evernote3.5\evernote.exe"; `
    'iexplore'             = "$env:ProgramFiles\Internet Explorer\iexplore.exe"; `
    'JabraDeviceService'   = "$env:ProgramFiles\Jabra\Jabra PC Suite\JabraDeviceService.exe"; `
    'JabraSkypeDriver'     = "$env:ProgramFiles\Jabra\Jabra PC Suite\JabraSkypeDriver.exe"; `
    'JabraAvayaOneXDriver' = "$env:ProgramFiles\Jabra\Jabra PC Suite\JabraAvayaOneXDriver.exe"; `
    'JabraAvayaIPDriver'   = "$env:ProgramFiles\Jabra\Jabra PC Suite\JabraAvayaIPDriver.exe"; `
    'katmouse'             = "$env:ProgramFiles\KatMouse\KatMouse.exe"; `
    'msosync'              = "$env:ProgramFiles\Microsoft Office\Office14\MSOSYNC.EXE"; `
    'outlook'              = "$env:ProgramFiles\microsoft office\office12\outlook.exe"; `
    'shmobile'             = "$env:ProgramFiles\Riverbed\Steelhead Mobile\shmobile.exe"; `
    'onexcengine'          = "$env:ProgramFiles\Avaya\Avaya one-X Communicator\onexcengine.exe"; `
    'onexcui'              = "$env:ProgramFiles\Avaya\Avaya one-X Communicator\onexcui.exe";
    'puretext'             = "$env:USERPROFILE\storage\software\PureText.exe"; `
    'wfcrun32'             = "$env:ProgramFiles\Citrix\ICA Client\wfcrun32.exe"; `
    'xmarkssync'           = "$env:ProgramFiles\Xmarks\IE Extension\xmarkssync.exe"; `
}

# Predefine 'prompt-list' to control which processes invoke user approval and which ones terminate silently
$askTerminate =@("outlook","iexplore","chrome","firefox");

#  ### Pre-defined procedures ###
# checkProcess([Process Name], [Start|Stop])
function checkProcess([string]$processName,[string]$mode) {
    #Write-Output checkProcess"($processName,$mode)"
    $process = Get-Process $processName -ErrorAction SilentlyContinue
    switch ($mode) {
        "Start" {
            if ($?) {
                # process is already running
                Write-Warning "FYI: $processName is already running."
            } else {
                if ($knownPaths.Keys -contains $processName) {
                    # check for launch/start parameters
                    switch ($processName) {
                        "concentr"       {$params = '/startup';}
                        "communicator" {$params = '/fromrunkey';}
                        "evernote"     {$params = '/minimized';}
                        "xmarkssync"   {$params = '-q';}
                    }
                    # launch process from known path
                    #write-host "Launching '$processName' from "$knownPaths.$processName
                    write-host "Start $processName $params";
					& $knownPaths.$processName $params
                } else {
                    Write-Warning "Path to launch '$processName' is undefined"
                }
            }
        }
        "Stop" {
            if ($?) {
                # $process is running
                if ($askTerminate -contains $processName) {
                    # processName is running, prompt to close
                    Write-Warning "$processName is still running."
                    $confirm = Read-Host "Close $processName, then type ok and click [Enter] to proceed."
                    while ($prompt -ne "True") {
                        if($confirm -ilike "ok") {
                            $prompt = "True"
                        } else {
                            Write-Warning "Invalid response '$confirm'"
                            $confirm = Read-Host "Type ok and click [Enter] once $processName is closed."
                        }
                    }
                    start-sleep 1; # wait one second to allow time for $process to stop
                    # Check if the process was stopped after we asked
                    $process = Get-Process $processName -ErrorAction SilentlyContinue
                    while ($process) {
                        # Application/process is still running, prompt to terminate
                        Write-Warning "$processName is still running."
                        $response = Read-Host "Would you like to force terminate? (Y/N)"
                        if($response -ilike "Y") {
                            terminate($process)
                        } elseif($response -ilike "N") {
                            # manually override termination
                            break
                        } else {
                            Write-Warning "Invalid response '$response'."
                        }
                        # confirm process is terminated
                        $process = Get-Process $processName -ErrorAction SilentlyContinue | out-null
                    }
                } else {
                    # kill the process
                    terminate($process)
                }
            }
        }
        default {
            # default mode is a wait mode
            # Write-Warning "$myName: waiting for $processName"
            # Check if $processName is running
            write-host "Checking if $processName is running"
            start-sleep -Milliseconds 500
            $process = Get-Process $processName -ErrorAction SilentlyContinue # | out-null
            while ($process) {
                # it appears to be running; let's wait for it
                $counter = 0; # we always start from zero
                $waitTime = 5 # Define how many seconds we want to wait per loop
                while ($counter -lt $waitTime) {
                    write-progress -activity "Waiting for $processName" -status "ctrl-c to break the loop" -percentcomplete ($counter/$waitTime*100)
                    Start-Sleep -Seconds 1;
                    $counter++;
                }
                write-warning "still waiting for $processName"
                # check again
                $process = Get-Process $processName -ErrorAction SilentlyContinue #| out-null
            }
            write-progress -activity "Waiting for $processName" -status "." -Completed #-percentcomplete (100)
        }
    }
}

function terminate($process) {
    # Check what we got; it could be a single process object or a collection of them
    if ($process.count -gt 1) {
        # We found more than one running process to kill
        $process | foreach {stop-process $_.id}
    } else {
        # otherwise, just kill the one process
        stop-process $process.id
        Start-Sleep -s 1 # wait just a sec to make sure it's gone
    }
}

# check count of arguments
switch ($args.length){
    1 { # default to "wait" mode
        checkProcess $args[0] "Wait"; # "Stop";
    }
    2 { # pass provided arguments to checkProcess function
        checkProcess $args[0] $args[1];
    }
    default { write-warning "Invalid arguments: $args."
        write-warning "Syntax: checkProcess <Process Name>, [Start|Stop]."
    break
    }
}
