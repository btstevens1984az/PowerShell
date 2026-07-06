# Purpose: bindingConversion — General-purpose PowerShell utilities.


foreach ($binding in $IIS)
{
    $delimiter = ','
    If ($binding.binding -like "*$delimiter*")
    {
        
        $bindingcount = ($binding.binding -split $delimiter).count
    }
    Else
    {
        $bindingcount=0
    }
    #$properties = "Binding","Port","CertificateThumbprint","CertificateStoreName","IPAddress","HostName"
    $properties = 'port','IIS-App-IP','CertificateThumbprint','CertificateStoreName','Binding'
    $bindinginfoHash=@{}
    for($count=0;$count -le $bindingcount;$count++)
    {
        foreach ($property in $properties)
        {   
            $bindinginfoHash.$property = ($binding.$property -split $delimiter)[$count]
        }
        $bindinginfohash.'IIS-HostName' = $binding.'IIS-HostName'
        $bindinginfoHash
    }
}
