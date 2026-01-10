#!/usr/bin/env pwsh

$prompt = @($args) + @($input) | Out-String
$wikilinks = $prompt | nt wikilinks | nt prereq

$prompt
if ($LASTEXITCODE -eq 0) {
  if ($wikilinks) {
    write-host "---"
    $wikilinks | nt seen | nt page --less --heading=2 | nt tidy
  }
} else {
  $code = $LASTEXITCODE
  Write-Host "⚠️ Wikilink expansion is not enabled."
  exit $code
}
