# Purpose: SimpleperfMonitor — System monitoring and alerting.
$results = get-counter "\logicaldisk(*)\avg. disk sec/write" -MaxSamples 5 -SampleInterval 2

$results.counterSamples | where instancename -eq "c:" | Out-GridView