# Purpose: killprocess — Windows desktop configuration and management.
gwmi win32_process -computer "78.61.6.96" -Filter "name='calc.exe'" | %{$_.terminate()|out-null}