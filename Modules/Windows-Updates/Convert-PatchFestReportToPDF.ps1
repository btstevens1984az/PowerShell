# Purpose: Convert-PatchFestReportToPDF — Windows Update and patch management.
Function Convert-PatchFestReportToPDF {
$PdfGenerator = "C$\Temp\NReco.PdfGenerator.dll"
$report = Get-Content -Path "\\C$\Temp\10.19.77.147.html"
            if (Test-Path -Path $PdfGenerator)
            {
                $ReportFormat = 'PDF'
                $PdfGenerator = "$((Get-Location).Path)\NReco.PdfGenerator.dll"
                $Assembly = [Reflection.Assembly]::LoadFrom($PdfGenerator) #| Out-Null
                $PdfCreator = New-Object -TypeName 'NReco.PdfGenerator.HtmlToPdfConverter'
                $ReportOutput = $PdfCreator.GeneratePdf([string]$Report)
                Add-Content -Value $ReportOutput `
                                -Encoding byte `
                                -Path "\\C$\Temp\10.19.77.147.pdf"
            }
}