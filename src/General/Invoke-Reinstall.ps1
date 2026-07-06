# Purpose: Invoke-Reinstall — General-purpose PowerShell utilities.
#----------------------------
#Uses psexec to push the reinstall package
#----------------------------
function Invoke-Reinstall{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$ComputerName
    )

    Foreach($cn in $ComputerName)
    {
	    write-debug $cn
	    
            start-process psexec -ArgumentList " \\$cn  `"C:\Program Files (x86)\Marimba\Castanet Tuner\runchannel.exe`" -subscribe http://marimba.example.com:5282/.Organization/Application/Hewlett_Packard/.stage/HPCA_Agent_9_2_Reinstall -install"
		         
	   
        
    }
}



