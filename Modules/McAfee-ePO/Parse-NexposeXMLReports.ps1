# Purpose: Parse-NexposeXMLReports — McAfee ePolicy Orchestrator reporting.
Function Parse-NexposeXMLReports {
clear 
Write-Host $Host.UI.RawUI.WindowTitle = "Script to parse lms XML file and write output ot XLS file." 
Write-Host Author: username -BackgroundColor black -ForegroundColor white 
Write-Host `n

function getFileType($fileName)
{
	$file = split-path ($fileName) -leaf -resolve
	$actualFilename = $file.split('.')
	$type = $actualFilename[$actualFilename.Count - 1]
	return $type
}

function Read-OpenFileDialog([string]$WindowTitle, [string]$InitialDirectory, [string]$Filter = "All files (*.*)|*.*", [switch]$AllowMultiSelect) 
{   
    Add-Type -AssemblyName System.Windows.Forms 
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog 
    $openFileDialog.Title = $WindowTitle 

    if ($InitialDirectory -eq $Null) 
    { 
        $openFileDialog.InitialDirectory = $InitialDirectory 
    }  
    
    $openFileDialog.Filter = $Filter
    # Disable the 'visible' property so the document won't open in excel
    #$objExcel.Visible = $false 

    if ($AllowMultiSelect) 
    { 
        $openFileDialog.MultiSelect = $true 
    } 
    
    $openFileDialog.ShowHelp = $true    	# Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE. 
    $openFileDialog.ShowDialog() > $null 
    
    if ($AllowMultiSelect) 
    {
        return $openFileDialog.Filenames 
    } 
    else 
    { 
        Write-Host $openFileDialog.Filename
        return $openFileDialog.Filename 
    } 
}

function xmlParser
{
	$xdoc = new-object System.Xml.XmlDocument
	Write-Host "Choose your XML file  that need to be parsed." -ForegroundColor yellow
	$filePath = Read-OpenFileDialog("Select XML file:") 
    
    if (($filePath -eq $null) -or ($filePath -eq ""))
    {
        Write-host "No file is selected. Program is closing."
        return
    }
    
	$type = getFileType($filePath)

	if($type -ne 'xml')
	{
		Write-host "Your uploaded file is not XML file. Please select correct XML file."
		$filePath = Read-OpenFileDialog("Select XML file:") 
        
        if (($filePath -eq $null) -or ($filePath -eq ""))
        {
            Write-host "No file is selected. Program is closing."
            return
        }
        
        $type = getFileType($filePath)
        
        if($type -ne 'xml')
        {
            Write-host "Wrong file uploaded again. Program is closing."
            return
        }
	}
    
    $file = resolve-path($filePath)
	
    Write-host "Your XML file has been uploaded successfully."
    
	$xdoc.load($file)
	$xdoc = [xml] (get-content $file)
	return $xdoc
}

function excel 
{
	param
	(
		$sheet = $ws,
		$xdoc = $xdoc,
		$rowNumber = $rowNumber,
		$colNumber = $colNumber
	)
    
	$temp=$rowNumber
	
	foreach ($runtimeEvent in $xdoc.xml.RuntimeLog.RuntimeEvent) 
    {
		if($runtimeEvent.key -eq 'interactions learner_response')
		{
			$value = $runtimeEvent.value				
			$sheet.Cells.Item($rowNumber,$colNumber).FormulaLocal = $value.toString()
			$rowNumber++
		}
	}
	
	$rowNumber = $temp
	$colNumber = $colNumber + 1
	foreach ($runtimeEvent in $xdoc.xml.RuntimeLog.RuntimeEvent) 
	{
		if($runtimeEvent.key -eq 'interactions correct_responses pattern')
		{
			$value = $runtimeEvent.value				
			$sheet.Cells.Item($rowNumber,$colNumber).FormulaLocal = $value.toString()
			$rowNumber++
		}
	}
	
	$rowNumber = $temp
	$colNumber = $colNumber + 1
	
	$i=0
	foreach ($runtimeEvent in $xdoc.xml.RuntimeLog.RuntimeEvent) 
	{
		if($i -eq 1 -And $runtimeEvent.itemIdentifier){
		$stringtemp=$runtimeEvent.itemIdentifier
		$string=$stringtemp.Substring(0,$stringtemp.Length)
		$ws.Cells.Item(2,3)=$string
		
		}
		
		if($runtimeEvent.key -eq 'interactions result')
		{
			
			$value = $runtimeEvent.value				
			$sheet.Cells.Item($rowNumber,$colNumber).FormulaLocal = $value.toString()
			$rowNumber++
		}
		$i++
	}
	
}

function operation($ws)
{
	$ArrList = [System.Collections.ArrayList]@()
	
	Write-host "Please wait......" -ForegroundColor yellow
	
	for ($row = 1; $row -le 7; $row++)
	{
		for($col = 1; $col -le 15; $col++)
		{
			if($ws.Cells.Item($row,$col).Value() -ne $null)
			{
				if($ws.Cells.Item($row,$col).Value() -eq 'Result' -or $ws.Cells.Item($row,$col).Value() -eq 'Raters Result')
				{
					$ArrList.Add($col)
					$temRow = $row					
				}
			}
		}
	}

    for ($i = 0; $i -lt $ArrList.Count; $i++)
	{
		$xdoc = xmlParser
        if ($xdoc -eq 0)
        {
            return -1
        }          
          
		[int]$rowNumber = $temRow + 1
		$colNumber = $ArrList[$i] - 2
		
		if($i > 0)
		{
			excel -sheet $ws -xdoc $xdoc -rowNumber $rowNumber -colNumber $colNumber
		}
		else
		{
			excel -sheet $ws -xdoc $xdoc -rowNumber $rowNumber -colNumber $colNumber
		}
	}
	
}


function xml-ParseAndWriteToExcel
{	
	$xl = New-Object -COM "Excel.Application"
	$xl.Visible = $true
    
	Write-Host "Choose your output EXCEL template file that needs to be updated." -ForegroundColor yellow
	$xlsFile = Read-OpenFileDialog("Select Output EXCEL template file:") 
    
    if (($xlsFile -eq $null) -or ($xlsFile -eq ""))
    {
        Write-host "No file is selected. Program is closing."
        return
    }
    
    $type = getFileType($xlsFile)
	
	if(($type -ne 'xlsx')-and( $type -ne 'xls'))
	{
		Write-host "Your uploadeded file is not an EXCEL file. Please select an EXCEL file."
		$xlsFile = Read-OpenFileDialog("Select Output EXCEL template file:")
        
        if (($xlsFile -eq $null) -or ($xlsFile -eq ""))
        {
            Write-host "No file is selected. Program is closing."
            return
        }
        
        $type = getFileType($xlsFile)
        
        if(($type -ne 'xlsx')-and( $type -ne 'xls'))
        {
            Write-host "Wrong file uploaded again. Program is closing."
            return
        }
	}
	
	Write-host "Your EXCEL file has been uploaded successfully."
	
    $wb = $xl.Workbooks.Open($xlsFile)	
	$ws = $wb.Sheets.Item(1)
    
	$objXml = operation($ws)
	
    if ($objXml -eq -1)
    {
        $wb.Save()
        $xl.quit()
        return
    }
    $a = 
    Write-Host "Please wait, your result is under process...." -ForegroundColor yellow
    start-sleep -se 5
	
	#find out parent directory ---------------
	$strDir = Split-Path -parent $xlsFile 
	$rootPath = Split-Path $strDir
	
	# select date format---------------
	$date = Get-Date -Format M
	#$hour = Get-Date -Format hh
	#$min = Get-Date -Format mm
	#$second = Get-Date -Format ss
	#$amPm = Get-Date -Format tt
	
	#creation output folder and check its existence -------
	$final_local = "$rootPath\OutputFiles"
	if((Test-Path $final_local) -eq 0)
    {
        mkdir $final_local	
       
    }else{
		
	}
	#save as work book with updated data on output folder ------------------
    #$wb.SaveAs($final_local+"\CW User Scores_"+$date+"_"+$hour+"-"+$min+"-"+$second+" "+$amPm)+".xlsx"
	$wb.SaveAs($final_local+"\CW User Scores_"+$date)+".xlsx"
	#$xl.quit()
    
   
	Write-Host "Output has been generated and written on EXCEL file successfully.`nPlease see your EXCEL file at: `n$final_local. `n" -ForegroundColor yellow
	Write-Host "Console will terminate in "
	$x = 10
	while($x -gt 0) {
	if($x -eq 1) { Write-Host  "`r$x second..." -NoNewLine -ForegroundColor red }
	else { Write-Host  "`r$x seconds..." -NoNewLine -ForegroundColor red }
	start-sleep -s 1
	$x--
	}
	Stop-process $pid
}

xml-ParseAndWriteToExcel
}