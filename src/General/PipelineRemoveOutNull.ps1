# Purpose: PipelineRemoveOutNull — General-purpose PowerShell utilities.
& {
	$items = [ISESteroids.SteroidsFixer.Helpers]::GetAST('Pipeline')
	foreach($item in $items)
	{
		if ($item.PipelineElements[-1].Extent.Text -eq 'Out-Null')
		{
			# remove last pipeline element
			[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($item.PipelineElements[-2].Extent.EndOffset, $item.PipelineElements[-1].Extent.EndOffset, '')
    
			# add $null assignment
			[ISESteroids.SteroidsFixer.Helpers]::AddTextChange($item.PipelineElements[0].Extent.StartOffset, $item.PipelineElements[0].Extent.StartOffset, '$null = ')
    
		}
	}
	Invoke-SteroidsTextChange
}
