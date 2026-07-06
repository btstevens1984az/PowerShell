# Purpose: OperatorAdjustSpace — General-purpose PowerShell utilities.
& {
  $unary = [Management.Automation.Language.TokenFlags]::UnaryOperator


  $info = Get-SteroidsAST

  $tokenCount = $info.TokenList.Count

  # we need a minimum of three tokens for this test
  if ($tokenCount -ge 3) 
  { 
  
    for ($i=1; $i -lt $tokenCount-1; $i++)
    {
      $token = $info.TokenList[$i]
      $previoustoken = $info.TokenList[$i-1]
      $nexttoken = $info.TokenList[$i+1]
    
      if ($token.TokenFlags -like '*Operator')
      {
        # exclude unary operators
        if (($token.TokenFlags -band $unary) -eq $unary) { continue }
      
        $start = $previoustoken.Extent.EndOffset
        $end = $token.Extent.StartOffset
        if ($end-$start -eq 0)
        {
          [ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, ' ', $false)
        }
      
        $start = $token.Extent.EndOffset
        $end = $nexttoken.Extent.StartOffset
        if ($end-$start -ne 1)
        {
          [ISESteroids.SteroidsFixer.Helpers]::AddTextChange($start, $end, ' ', $false)
        }
        $i++
      }
    
    }
  
  }
  Invoke-SteroidsTextChange
}
