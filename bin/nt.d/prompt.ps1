#!/usr/bin/env pwsh

$prompt = @($args) + @($input) | Out-String
$wikilinks = $prompt | nt commented | nt wikilinks | nt prereq

$prompt
if ($LASTEXITCODE -eq 0) {
  if ($wikilinks) {
    $copy = $wikilinks | nt seen | nt page --less --heading=2 | nt tidy
    $copy | nt sep
    $others = $copy | nt wikilinks | nt seen
    $others | Where-Object { $_ -notin ($wikilinks) } | sort | nt props tags description -r description -u description --heading=2 | nt sep
  }
} else {
  $code = $LASTEXITCODE
  Write-Host "⚠️ Wikilink expansion is not enabled."
  exit $code
}
