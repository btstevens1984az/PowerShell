function Compare-File{
<#
    .SYNOPSIS
        A wrapper and extension foir the built-in Compare-Object cmdlet to compare two txt based files and receive a side-by-side comparison (including Line numbes).
        
    .DESCRIPTION
		This is based on an idea from Lee Holmes http://www.leeholmes.com/blog/2013/11/29/using-powershell-to-compare-diff-files/. Generates a line by line comparison of two 
		txt based files. Lines that are present in one file but not in the other are indicated by N/A
		
    .PARAMETER file1
        Path to the file that will be the reference object for the comparison
	
	.PARAMETER file2
		Path to the file that will be the difference object for the comparison
		
	.PARAMETER IncludeEqual
		If specified lines that are equal will be included in the output.
		
	.PARAMETER ExcludeDifferent
		If specified lines that are not equal will be excluded from the output.
		
    .EXAMPLE  
		$txt1=@"
		will stay
		this is some text
		more
		will be deleted
		"@ | Set-Content txt1.txt
		$txt2=@"
		will stay
		added is some text
		changed
		"@ | Set-Content txt2.txt

		Compare-File txt1.txt txt2.txt -IncludeEqual
#>
[CmdletBinding()] 
	param(
		[Parameter(Mandatory=$true)]
	    $file1,
		[Parameter(Mandatory=$true)]
	    $file2,
		[switch]$IncludeEqual,
		[switch]$ExcludeDifferent
	)
	$content1 = Get-Content $file1
	$content2 = Get-Content $file2
	$minCount=[Math]::Min($content1.Count,$content2.Count)
	$comparedLines = Compare-Object $content1 $content2 -IncludeEqual:$IncludeEqual -ExcludeDifferent:$ExcludeDifferent -SyncWindow 1 |
	    group { $_.InputObject.ReadCount } | sort Name
	$comparedLines | foreach {
		$curr=$_
		switch ($_.Group[0].SideIndicator){
			"==" { $right=$left=$curr.Group[0].InputObject;break} 
			"=>" { 
					$right,$left = $curr.Group[0].InputObject,$curr.Group[1].InputObject
					if ($curr.Count -eq 1 -and [int]$curr.Name -gt $minCount){ 
						$left="N/A"
					}
					break 
				 }
			"<=" { 
					$right,$left = $curr.Group[1].InputObject,$curr.Group[0].InputObject
					if ($curr.Count -eq 1 -and [int]$curr.Name -gt $minCount){
						$right="N/A"
					}
					break 
				 }                                                                  
		}
        New-Object PSObject -Property @{
            Line = $_.Name
            ($file1 | Split-Path -Leaf) = $left
            ($file2 | Split-Path -Leaf) = $right
        } 
	} | sort {[int]$_.Line} 
}

$txt1=@"
will stay
this is some text
more
will be deleted
"@ | Set-Content txt1.txt
$txt2=@"
will stay
added is some text
changed
"@ | Set-Content txt2.txt

Compare-File txt1.txt txt2.txt -IncludeEqual | ft -AutoSize

