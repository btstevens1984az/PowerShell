# Purpose: ArrayVisual — General-purpose PowerShell utilities.
1..50 | %{
            [pscustomobject]@{ index = $_ -1
                                Value = "Value$_"
                                }

            } | ogv