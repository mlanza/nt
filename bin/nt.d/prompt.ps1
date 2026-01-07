#!/usr/bin/env pwsh

$prompt = @($args) + @($input) | Out-String
$wikilinks = $prompt | nt wikilinks

$prompt
if ($wikilinks) {
  write-host "---"
  $wikilinks | nt prereq | nt seen | nt page --agent --heading=2 | nt tidy
}

