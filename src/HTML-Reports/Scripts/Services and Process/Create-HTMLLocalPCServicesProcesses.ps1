# Purpose: Create-HTMLLocalPCServicesProcesses — HTML report generation utilities.
$css = @'
  <style>
    table {background-color:white;}
    body {background-color: gray;}
    body.background-image {opacity: 0.1;}
    #svc h1 {color:#4CAF50;background-color:#e6ffe6;text-align:center;}
    #svc {font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;border-collapse: collapse;width: 100%;}    
    #svc td, #svc th {border: 1px solid #ddd; padding: 8px;}    
    #svc tr:nth-child(even){background-color: #e2e2e2;}
    #svc tr:nth-child(odd){background-color: #fbfbfb;}
    #svc tr:hover {background-color: green;}
    #svc th {padding-top: 12px;padding-bottom: 12px;text-align: left;background-color: #4CAF50;color: white;}

    #prc h1 {color:red;background-color:#ffe6e6;text-align:center;}
    #prc {font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;border-collapse: collapse;width: 100%;}    
    #prc td, #prc th {border: 1px solid #ddd; padding: 8px;}    
    #prc tr:nth-child(even){background-color: #f2f2f2;}
    #prc tr:hover {background-color: #ddd;}
    #prc th {padding-top: 12px;padding-bottom: 12px;text-align: left;background-color: red;color: white;}

  </style>
'@

$js = @'
  <script>
    var allTableCells = document.getElementsByTagName("td");
    
    for(var i = 0, max = allTableCells.length; i < max; i++) {
        var node = allTableCells[i];
    
        //get the text from the first child node - which should be a text node
        var currentText = node.childNodes[0].nodeValue; 
    
        //check for 'one' and assign this table cell's background color accordingly 
        if (currentText = "stopped")
            node.style.backgroundColor = "red";
    }
  </script>;
'@

$fragSvc = get-service -name eventlog | Select-Object Status,Name,StartType | ConvertTo-Html -PreContent '<div id="svc"><h1>SERVICES</h1>' -PostContent '</div><br><br>' -Fragment | Out-String
$fragPrc = Get-Process -name w* | Select-Object Id,Name,BasePriority  | ConvertTo-Html -PreContent '<div id="prc"><h1>PROCESSES</h1>' -PostContent '</div>' -Fragment | Out-String
ConvertTo-Html -Head $css -PostContent $fragSvc,$fragPrc,$js | Out-File "C:\Temp\'$Env:COMPUTERNAME'-Services.html"
