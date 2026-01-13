#!/usr/bin/env pwsh

$prompt = @($args) + @($input) | Out-String
$wikilinks = $prompt | nt commented | nt wikilinks | nt prereq

$prompt
if ($LASTEXITCODE -eq 0) {
  $wikilinks | nt about
} else {
  $code = $LASTEXITCODE
  Write-Host "⚠️ Wikilink expansion is not enabled."
  exit $code
}
