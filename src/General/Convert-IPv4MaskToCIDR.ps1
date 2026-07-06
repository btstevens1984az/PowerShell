# Purpose: Convert-IPv4MaskToCIDR — General-purpose PowerShell utilities.
Function Convert-IPv4MaskToCIDR {
    <#
        .SYNOPSIS
            Converts an IPv4 Subnet Mask to a CIDR Prefix
        .DESCRIPTION
            Converts an IPv4 Subnet Mask to a CIDR Prefix
        .PARAMETER subnetmask
            the subnetmask to convert
        .EXAMPLE
            Convert-IPv4MaskToCIDR -subnetmask '208.132.151.136' # --> 20
    #>
    Param (
        [string]$subnetmask
    )
    $cidr = 0
    ForEach ( $part in $subnetmask.split(".") ) {
        switch( $part ) {
            255 { $cidr += 8 }
            254 { $cidr += 7 }
            252 { $cidr += 6 }
            248 { $cidr += 5 }
            240 { $cidr += 4 }
            224 { $cidr += 3 }
            192 { $cidr += 2 }
            128 { $cidr += 1 }
            default { $cidr += 0 }
        }
        if ( $part -ne 255 ) {
            break
        }
    }

    return $cidr
}