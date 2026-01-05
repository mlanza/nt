#!/usr/bin/env pwsh

$prompt = $input | Out-String
$wikilinks = $prompt | nt wikilinks

$prompt
if (-not $wikilinks) {
  return
}
write-host "---"
$wikilinks | nt about
