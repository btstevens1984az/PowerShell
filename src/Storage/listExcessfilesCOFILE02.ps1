# Purpose: listExcessfilesCOFILE02 — Storage management and disk operations.
# powershell 2
# kerry k
# get dir list of files by extension and write to CSV
get-childitem P:\ -include *.exe -recurse | select-object fullname | export-csv h:\ad-reports\CO-File02ExcessFileList-EXE.csv
get-childitem P:\ -include *.mp3 -recurse | select-object fullname | export-csv h:\ad-reports\CO-File02ExcessFileList-MP3.csv
get-childitem P:\ -include *.AVI -recurse | select-object fullname | export-csv h:\ad-reports\CO-File02ExcessFileList-AVI.csv
get-childitem P:\ -include *.JPEG -recurse | select-object fullname | export-csv h:\ad-reports\CO-File02ExcessFileList-JPEG.csv
get-childitem P:\ -include *.JPG -recurse | select-object fullname | export-csv h:\ad-reports\CO-File02ExcessFileList-JPG.csv


