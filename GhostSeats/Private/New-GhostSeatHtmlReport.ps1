function New-GhostSeatHtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Seats,

        [Parameter(Mandatory)]
        [psobject]$Summary,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $rows = foreach ($s in $Seats) {
        $badge = switch ($s.Category) {
            'DisabledAccount'  { 'badge-red' }
            'NeverSignedIn'    { 'badge-orange' }
            'Inactive'         { 'badge-yellow' }
            'GuestWithLicense' { 'badge-purple' }
            default            { 'badge-gray' }
        }
        @"
<tr>
  <td>$([System.Net.WebUtility]::HtmlEncode($s.DisplayName))</td>
  <td>$([System.Net.WebUtility]::HtmlEncode($s.UserPrincipalName))</td>
  <td><span class="badge $badge">$([System.Net.WebUtility]::HtmlEncode($s.Category))</span></td>
  <td>$([System.Net.WebUtility]::HtmlEncode([string]$s.InactiveDays))</td>
  <td>$([System.Net.WebUtility]::HtmlEncode($s.LicenseSummary))</td>
  <td class="money">`$$([System.Net.WebUtility]::HtmlEncode([string]$s.EstimatedMonthlyWasteUSD))</td>
  <td>$([System.Net.WebUtility]::HtmlEncode($s.RecommendedAction))</td>
</tr>
"@
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>GhostSeats Report</title>
<style>
  :root {
    --bg: #0f1419;
    --panel: #1a222c;
    --text: #e7eef7;
    --muted: #8fa3b8;
    --accent: #3dd6c6;
    --accent2: #7aa2ff;
    --line: #2a3644;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font-family: "Segoe UI", "Helvetica Neue", sans-serif;
    background:
      radial-gradient(1200px 600px at 10% -10%, rgba(61,214,198,.18), transparent 55%),
      radial-gradient(900px 500px at 100% 0%, rgba(122,162,255,.16), transparent 50%),
      var(--bg);
    color: var(--text);
  }
  .wrap { max-width: 1200px; margin: 0 auto; padding: 32px 20px 48px; }
  header { display: flex; justify-content: space-between; gap: 16px; align-items: end; margin-bottom: 28px; }
  h1 { margin: 0; font-size: 2rem; letter-spacing: -0.03em; }
  h1 span { color: var(--accent); }
  .sub { color: var(--muted); margin-top: 6px; }
  .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 24px; }
  .card {
    background: linear-gradient(180deg, rgba(255,255,255,.03), transparent), var(--panel);
    border: 1px solid var(--line);
    border-radius: 14px;
    padding: 16px;
  }
  .card .label { color: var(--muted); font-size: .85rem; }
  .card .value { font-size: 1.55rem; font-weight: 700; margin-top: 6px; }
  .card .value.accent { color: var(--accent); }
  table {
    width: 100%;
    border-collapse: collapse;
    background: var(--panel);
    border: 1px solid var(--line);
    border-radius: 14px;
    overflow: hidden;
  }
  th, td { padding: 12px 14px; text-align: left; border-bottom: 1px solid var(--line); font-size: .92rem; }
  th { color: var(--muted); font-weight: 600; background: rgba(0,0,0,.18); }
  tr:hover td { background: rgba(61,214,198,.05); }
  .money { font-variant-numeric: tabular-nums; color: var(--accent); font-weight: 600; }
  .badge { display: inline-block; padding: 3px 8px; border-radius: 999px; font-size: .78rem; font-weight: 600; }
  .badge-red { background: rgba(255,99,99,.15); color: #ff8e8e; }
  .badge-orange { background: rgba(255,168,76,.15); color: #ffb86b; }
  .badge-yellow { background: rgba(240,210,80,.15); color: #f0d250; }
  .badge-purple { background: rgba(180,140,255,.15); color: #c4a8ff; }
  .badge-gray { background: rgba(160,170,180,.12); color: #c0cad4; }
  footer { margin-top: 18px; color: var(--muted); font-size: .8rem; }
</style>
</head>
<body>
  <div class="wrap">
    <header>
      <div>
        <h1>Ghost<span>Seats</span></h1>
        <div class="sub">Unused Microsoft 365 license report · $([System.Net.WebUtility]::HtmlEncode($Summary.TenantName))</div>
      </div>
      <div class="sub">Generated UTC $($Summary.GeneratedAtUtc.ToString('yyyy-MM-dd HH:mm'))</div>
    </header>

    <div class="cards">
      <div class="card"><div class="label">Ghost seats</div><div class="value">$($Summary.GhostSeatCount)</div></div>
      <div class="card"><div class="label">Est. monthly waste</div><div class="value accent">`$$($Summary.EstimatedMonthlyWasteUSD)</div></div>
      <div class="card"><div class="label">Est. annual waste</div><div class="value accent">`$$($Summary.EstimatedAnnualWasteUSD)</div></div>
      <div class="card"><div class="label">Disabled + licensed</div><div class="value">$($Summary.DisabledAccountCount)</div></div>
      <div class="card"><div class="label">Never signed in</div><div class="value">$($Summary.NeverSignedInCount)</div></div>
      <div class="card"><div class="label">Inactive</div><div class="value">$($Summary.InactiveCount)</div></div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Name</th><th>UPN</th><th>Category</th><th>Inactive days</th>
          <th>Licenses</th><th>Monthly</th><th>Recommended action</th>
        </tr>
      </thead>
      <tbody>
        $($rows -join "`n")
      </tbody>
    </table>

    <footer>
      GhostSeats · Prices are estimates for planning only · DemoMode=$($Summary.DemoMode)
      · Source=$($Summary.Source)
    </footer>
  </div>
</body>
</html>
"@

    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value $html -Encoding UTF8
    return (Get-Item -LiteralPath $Path)
}
