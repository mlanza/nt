#!/usr/bin/env pwsh
$topics = @($input) + @($args)
$body = $topics | nt seen | nt prereq | nt seen | nt page --less | nt tidy
$body
$wikilinks = $body | nt wikilinks | nt seen
if ($wikilinks) {
  $mentioned = $wikilinks | nt n --unaliased
  if ($mentioned) {
    $mentioned | Where-Object { $_ -notin ($topics) } | sort | nt props tags situation -r situation --heading=2 | nt sep "# See Also"
  }
}
