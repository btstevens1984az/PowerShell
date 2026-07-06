# Purpose: HTMLTable — IT reporting and dashboard generation.

<#
    You can use and combine these functions anywhere you need to create an HTML based table with PowerShell.  A few use cases:
    Notification e-mails.  Particularly if readability is important.
    Ad hoc dashboards.  Temporarily spin up a more in depth page containing performance data, recent errors, etc.

#>

function ConvertTo-PropertyValue {
    <#
    .SYNOPSIS
    Convert an object with various properties into an array of property, value pairs 
    
    .DESCRIPTION
    Convert an object with various properties into an array of property, value pairs

    If you output reports or other formats where a table with one long row is poorly formatted, this is a quick way to create a table of property value pairs.

    There are other ways you could do this.  For example, I could list all noteproperties from Get-Member results and return them.
    This function will keep properties in the same order they are provided, which can often be helpful for readability of results.

    .PARAMETER inputObject
    A single object to convert to an array of property value pairs.

    .PARAMETER leftheader
    Header for the left column.   Default: Property

    .PARAMETER rightHeader
    Header for the right column.  Default: Value

    .PARAMETER memberType
    Return only object members of this membertype.  Default:  Property, NoteProperty, ScriptProperty

    .EXAMPLE
    get-process powershell_ise | convertto-propertyvalue

    I want details on the powershell_ise process.
        With this command, if I output this to a table, a csv, etc. I will get a nice vertical listing of properties and their values
        Without this command, I get a long row with the same info

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    .FUNCTIONALITY
    General Command
    #> 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromRemainingArguments=$false)]
        [PSObject]$InputObject,
        
        [validateset("AliasProperty", "CodeProperty", "Property", "NoteProperty", "ScriptProperty",
            "Properties", "PropertySet", "Method", "CodeMethod", "ScriptMethod", "Methods",
            "ParameterizedProperty", "MemberSet", "Event", "Dynamic", "All")]
        [string[]]$memberType = @( "NoteProperty", "Property", "ScriptProperty" ),
            
        [string]$leftHeader = "Property",
            
        [string]$rightHeader = "Value"
    )

    begin{
        #init array to dump all objects into
        $allObjects = New-Object System.Collections.ArrayList

    }
    process{
        #if we're taking from pipeline and get more than one object, this will build up an array
        [void]$allObjects.add($inputObject)
    }

    end{
        #use only the first object provided
        $allObjects = $allObjects[0]

        #Get properties.  Filter by memberType.
        $properties = $allObjects.psobject.properties | ?{$memberType -contains $_.memberType} | select -ExpandProperty Name

        #loop through properties and display property value pairs
        foreach($property in $properties){

            #Create object with property and value
            $temp = "" | select $leftHeader, $rightHeader
            $temp.$leftHeader = $property.replace('"',"")
            $temp.$rightHeader = try { $allObjects | select -ExpandProperty $temp.$leftHeader -erroraction SilentlyContinue } catch { $null }
            $temp
        }
    }
}

function New-HTMLHead {
    <#
    .SYNOPSIS
        Returns HTML including internal style sheet

    .DESCRIPTION
        Returns HTML including internal style sheet

    .PARAMETER cssPath
        If specified, contents of this file are embedded in an internal style sheet via <style> tags
        
        Note:  If you include your own CSS, please note that the New-HTMLTable function looks for 'odd' and 'even' class names.  Note .odd and .even defitions in $HTMLStyle.

    .PARAMETER title
        If specified, title to add in the head section

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    .FUNCTIONALITY
        General Command

    #>
    [cmdletbinding(DefaultParameterSetName="String")]    
    param(
        
        [Parameter(ParameterSetName='File')]
        [validatescript({test-path $_ -pathtype leaf})]$cssPath = $null,
        
        [Parameter(ParameterSetName='String')]
        [string]$style = "<style>
                    body {
                        color:#333333;
                        font-family:Calibri,Tahoma,arial,verdana;
                        font-size: 11pt;
                    }
                    h1 {
                        text-align:center;
                    }
                    h2 {
                        border-top:1px solid #666666;
                    }
                    table {
                        border-collapse:collapse;
                    }
                    th {
                        text-align:left;
                        font-weight:bold;
                        color:#eeeeee;
                        background-color:#333333;
                        border:1px solid black;
                        padding:5px;
                    }
                    td {
                        padding:5px;
                        border:1px solid black;
                    }
                    .odd { background-color:#ffffff; }
                    .even { background-color:#dddddd; }
                </style>",
        
        [string]$title = $null
    )

    #add css from file if specified
    if($cssPath){$style = "<style>$(get-content $cssPath | out-string)</style>"}

    #Return HTML
    @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            $(if($title){"<title>$title</title>"})
                $style
        </head>
        <body>

"@

}

function New-HTMLTable {
    <# 
    .SYNOPSIS 
    Create an HTML table from an input object
 
    .DESCRIPTION 
    Create an HTML table from an input object
 
    .PARAMETER  InputObject 
    One or more objects (ie. (Get-process | select Name,Company) 
 
    .PARAMETER Properties
    If specified, limit table to these specific properties in the order specified.
    
    .PARAMETER setAlternating

    .PARAMETER listTableHead
    If a list is provided, use this parameter to specify the list header (PowerShell uses * by default)

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    Props to Zachary Loeber for the idea: http://gallery.technet.microsoft.com/scriptcenter/Colorize-HTML-Table-Cells-2ea63acd

    I believe that .Net 3.5 is a requirement for using the Linq libraries

    .FUNCTIONALITY
    General Command
    #> 
    [CmdletBinding()] 
    param ( 
        [Parameter( Position=0,
                    Mandatory=$true, 
                    ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,

        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [string[]]$Properties,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [bool]$setAlternating = $true,

        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [string]$listTableHead = $null

        )
    
    BEGIN { 
        #requires -version 2.0
        add-type -AssemblyName System.xml.linq | out-null
        $Objects = New-Object System.Collections.ArrayList
    } 
 
    PROCESS { 

        #Loop through inputObject, add to collection.  Filter properties if specified.
        foreach($object in $inputObject){
            if($Properties){ [void]$Objects.add(($object | Select $Properties)) }
            else{ [void]$Objects.add( $object )}
        }

    } 
 
    END { 

        # Convert our data to x(ht)ml  
        $xml = [System.Xml.Linq.XDocument]::Parse("$($Objects | ConvertTo-Html -Fragment)")
        
        #replace * as table head if specified.  Note, this should only be done for a list...
        if($listTableHead){
            $xml = [System.Xml.Linq.XDocument]::parse( $xml.Document.ToString().replace("<th>*</th>","<th>$listTableHead</th>") )
        }

        if($setAlternating){
            #loop through descendents.  If their index is even mark with class even, odd with class odd.
            foreach($descendent in $($xml.Descendants("tr"))){
                if(($descendent.NodesBeforeSelf() | Measure-Object).count % 2 -eq 0){
                    $descendent.SetAttributeValue("class", "even") 
                }
                else{
                    $descendent.SetAttributeValue("class", "odd") 
                }
            }
        }
        #Provide full HTML or just the table depending on param
        $xml.Document.ToString()
    }
}

function Add-HTMLTableColor {
    <# 
    .SYNOPSIS 
    Colorize cells or rows in an HTML table, or add other inline CSS
 
    .DESCRIPTION 
    Colorize cells or rows in an HTML table, or add other inline CSS
 
    .PARAMETER  HTML 
    HTML string to work with

    .PARAMETER  Column 
    If specified, the column you want to modify.  This is case sensitive

    .PARAMETER  Argument 
    If Column is specified, this argument can be used to compare with current cell.

    .PARAMETER ScriptBlock
    If Column is specified, used to evaluate whether to colorize a cell.  If the scriptblock returns $true the cell will be colorized.
   
    $args[0] is the existing cell value in the table
    $args[1] is your Argument parameter

    Examples:
        {[string]$args[0] -eq [string]$args[1]} #existing cell value equals Argument.  This is the default
        {[double]$args[0] -gt [double]$args[1]} #existing cell value is greater than Argument.

    Use strong typesetting if possible.
 
    .PARAMETER  Attr 
    If Column is specified, the attribute to change should ColumnValue be found in the Column specified or if the ScriptBlock is true.  Default:  Style
 
    .PARAMETER  AttrValue 
    If Column is specified, the attribute value to set when the ColumnValue is found in the Column specified or if the ScriptBlock is true.
    
    Example: "background-color:#FFCC99;" 
 
    .PARAMETER WholeRow
    If specified, and Column is specified, set the Attr and AttrValue for the entire row, not just a cell.

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    .EXAMPLE
    # Table with the 20 most recent events, highlighting error and warning rows

        #gather 20 events from the system log and pick out a few properties
        $events = Get-EventLog -LogName System -Newest 20 | select TimeGenerated, Index, EntryType, UserName, Message

    #Create the HTML table without alternating rows, colorize Warning and Error messages, highlighting the whole row.
        $eventTable = $events | New-HTMLTable -setAlternating $false |
            Add-HTMLTableColor -Argument "Warning" -Column "EntryType" -AttrValue "background-color:#FFCC66;" -WholeRow |
            Add-HTMLTableColor -Argument "Error" -Column "EntryType" -AttrValue "background-color:#FFCC99;" -WholeRow

    #Build the HTML head, add an h3 header, add the event table, and close out the HTML
        $HTML = New-HTMLHead
        $HTML += "<h3>Last 20 System Events</h3>"
        $HTML += $eventTable | Close-HTML

    #test it out
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    Props to Zachary Loeber and Jaykul for the idea and help:
    http://gallery.technet.microsoft.com/scriptcenter/Colorize-HTML-Table-Cells-2ea63acd
    http://stackoverflow.com/questions/4559233/technique-for-selectively-formatting-data-in-a-powershell-pipeline-and-output-as

    I believe that .Net 3.5 is a requirement for using the Linq libraries
    
    .FUNCTIONALITY
    General Command
    #> 
    [CmdletBinding()] 
    param ( 
        [Parameter( Mandatory=$true,  
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$false)]  
        [string]$HTML,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [String]$Column="Name",
        
        [Parameter( Mandatory=$false,
                    ValueFromPipeline=$false)]
        $Argument=0,
        
        [Parameter( ValueFromPipeline=$false)]
        [ScriptBlock]$ScriptBlock = {[string]$args[0] -eq [string]$args[1]},
        
        [Parameter( ValueFromPipeline=$false)]
        [String]$Attr = "style",
        
        [Parameter( Mandatory=$true, 
                    ValueFromPipeline=$false)] 
        [String]$AttrValue,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)] 
        [switch]$WholeRow=$false

        )
    
        #requires -version 2.0
        add-type -AssemblyName System.xml.linq | out-null

        # Convert our data to x(ht)ml  
        $xml = [System.Xml.Linq.XDocument]::Parse($HTML)   
        
        #Get column index.  try th with no namespace first, then default namespace provided by convertto-html
        try{ 
            $columnIndex = (($xml.Descendants("th") | Where-Object { $_.Value -eq $Column }).NodesBeforeSelf() | Measure-Object).Count 
        }
        catch { 
            Try {
                $columnIndex = (($xml.Descendants("{http://www.w3.org/1999/xhtml}th") | Where-Object { $_.Value -eq $Column }).NodesBeforeSelf() | Measure-Object).Count
            }
            Catch {
                Throw "Error:  Namespace incorrect."
            }
        }

        #if we got the column index...
        if($columnIndex -as [double] -ge 0){
            
            #take action on td descendents matching that index
            switch($xml.Descendants("td") | Where { ($_.NodesBeforeSelf() | Measure).Count -eq $columnIndex })
            {
                #run the script block.  If it is true, set attributes
                {$(Invoke-Command $ScriptBlock -ArgumentList @($_.Value, $Argument))} { 
                    
                    #mark the whole row or just a cell depending on param
                    if ($WholeRow)  { 
                        $_.Parent.SetAttributeValue($Attr, $AttrValue) 
                    } 
                    else { 
                        $_.SetAttributeValue($Attr, $AttrValue) 
                    }
                }
            }
        }
        
        #return the XML
        $xml.Document.ToString() 
}

function Close-HTML {
    <# 
    .SYNOPSIS 
    Close out the body and html tags
 
    .DESCRIPTION 
    Close out the body and html tags
 
    .PARAMETER  HTML 
    HTML string to work with

    .PARAMETER Decode
    If specified, run HTML string through HtmlDecode

    .EXAMPLE
    #This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm

    .FUNCTIONALITY
    General Command
    #>

    [cmdletbinding()]
    param(
        [Parameter( Mandatory=$true,  
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$false)]  
        [string]$HTML,

        [switch]$Decode
    )
    #Thanks to ‏@ashyoungblood!
    if($Decode)
    {
        Add-Type -AssemblyName System.Web
        $HTML = [System.Web.HttpUtility]::HtmlDecode($HTML)
    }
    "$HTML </body></html>"
}

<# Generate tables with various Process information

#This example requires and demonstrates using the New-HTMLHead, New-HTMLTable, Add-HTMLTableColor, ConvertTo-PropertyValue and Close-HTML functions.
    
    #get processes to work with
        $processes = Get-Process
    
    #Build HTML header
        $HTML = New-HTMLHead -title "Process details"

    #Add CPU time section with top 10 PrivateMemorySize processes.  This example does not highlight any particular cells
        $HTML += "<h3>Process Private Memory Size</h3>"
        $HTML += New-HTMLTable -inputObject $($processes | sort PrivateMemorySize -Descending | select name, PrivateMemorySize -first 10)

    #Add Handles section with top 10 Handle usage.
    $handleHTML = New-HTMLTable -inputObject $($processes | sort handles -descending | select Name, Handles -first 10)

        #Add highlighted colors for Handle count
            
            #build hash table with parameters for Add-HTMLTableColor.  Argument and AttrValue will be modified each time we run this.
            $params = @{
                Column = "Handles" #I'm looking for cells in the Handles column
                ScriptBlock = {[double]$args[0] -gt [double]$args[1]} #I want to highlight if the cell (args 0) is greater than the argument parameter (arg 1)
                Attr = "Style" #This is the default, don't need to actually specify it here
            }

            #Add yellow, orange and red shading
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 1500 -attrValue "background-color:#FFFF99;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 2000 -attrValue "background-color:#FFCC66;" @params
            $handleHTML = Add-HTMLTableColor -HTML $handleHTML -Argument 3000 -attrValue "background-color:#FFCC99;" @params
      
        #Add title and table
        $HTML += "<h3>Process Handles</h3>"
        $HTML += $handleHTML

    #Add process list containing first 10 processes listed by get-process.  This example does not highlight any particular cells
        $HTML += New-HTMLTable -inputObject $($processes | select name -first 10 ) -listTableHead "Random Process Names"

    #Add property value table showing details for PowerShell ISE
        $HTML += "<h3>PowerShell Process Details PropertyValue table</h3>"
        $processDetails = Get-process powershell_ise | select name, id, cpu, handles, workingset, PrivateMemorySize, Path -first 1
        $HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $processDetails)

    #Add same PowerShell ISE details but not in property value form.  Close the HTML
        $HTML += "<h3>PowerShell Process Details object</h3>"
        $HTML += New-HTMLTable -inputObject $processDetails | Close-HTML

    #write the HTML to a file and open it up for viewing
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm
#>

<# Generate table With process name and handle count, with handle count colorized in shades of yellow, orange and red.
   #NOTE:  When colorizing a table more than one time, be sure to cover the broadest set first (e.g. handles 1000+) moving up to the highest (e.g. handles 3000+).
   #       Otherwise the broader set will override the style.

    #This example requires New-HTMLHead, New-HTMLTable, and Add-HTMLTableColor functions

    #Get process objects to show in the table
        $processes = Get-Process
    
    #build parameter hashtabled.
        $params = @{
            Column = "Handles"
            ScriptBlock = {[double]$args[0] -gt [double]$args[1]}
        }

    #Build initial HTML table using New-HTMLTable.  Pipe the results to color the cells shades of yellow, orange, red
        $handleTable = $processes | sort handles -descending | select Name, Handles -first 30 | New-HTMLTable |
            Add-HTMLTableColor -Argument 1000 -attrValue "background-color:#FFFF99;" @params |
            Add-HTMLTableColor -Argument 2000 -attrValue "background-color:#FFCC66;" @params |
            Add-HTMLTableColor -Argument 3000 -attrValue "background-color:#FFCC99;" @params

    #build HTML head, add a h3 level title
        $HTML = "$(New-HTMLHead) <h3>Process Handles</h3>"
    
    #add the colorized table and close out the HTML tags
        $HTML += $handleTable | Close-HTML

    #create a temporary htm file and open it
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm
#>

<# Generate table with the 20 most recent events, highlighting error and warning rows

    #gather 20 events from the system log and pick out a few properties
        $events = Get-EventLog -LogName System -Newest 20 | select TimeGenerated, EventID, EntryType, UserName, Message

    #Create the HTML table without alternating rows, colorize Warning and Error messages, highlighting the whole row.
        $eventTable = $events | New-HTMLTable -setAlternating $false |
            Add-HTMLTableColor -Argument "Warning" -Column "EntryType" -AttrValue "background-color:#FFCC66;" -WholeRow |
            Add-HTMLTableColor -Argument "Error" -Column "EntryType" -AttrValue "background-color:#FFCC99;" -WholeRow

    #Build the HTML head, add an h3 header, add the event table, and close out the HTML
        $HTML = New-HTMLHead
        $HTML += "<h3>Last 20 System Events</h3>"
        $HTML += $eventTable | Close-HTML

    #test it out
        set-content C:\test.htm $HTML
        & 'C:\Program Files\Internet Explorer\iexplore.exe' C:\test.htm
#>
