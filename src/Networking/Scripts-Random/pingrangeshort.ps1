# Purpose: pingrangeshort — Network diagnostics, DNS, DHCP, and connectivity.
1..100 | %{ping "127.0.0.$_"}