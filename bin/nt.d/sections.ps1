#!/usr/bin/env pwsh
param(
  [Alias('o')]
  [string[]]$only
)
# Filter content by Markdown section names (h1–h6) from stdin.
# Without --only: list only the headings.
# With --only: output full sections for the named headings.

# Read all lines from stdin.
$content = [Console]::In.ReadToEnd().Replace("`r","") -split "`n"
if (-not $content) { exit }

# Parse sections: group heading + following lines.
$sections = @()
$current  = @{ Name = $null; Lines = @() }
foreach ($line in $content) {
  if ($line -match '^(#{1,6})\s+(.*)$') {
    if ($current.Lines.Count -gt 0) { $sections += $current }
    $current = @{ Name = $matches[2]; Lines = @($line) }
  } else {
    if ($current.Lines) { $current.Lines += $line }
  }
}
if ($current.Lines.Count -gt 0) { $sections += $current }

# If no --only, list only headings.
if (-not $only) {
  foreach ($sect in $sections) {
    Write-Output $sect.Lines[0]
  }
  exit
}

# Otherwise, filter sections by name.
$filtered = $sections | Where-Object { $only -contains $_.Name }

# Output filtered sections with a blank line before subsequent headings.
$first = $true
foreach ($sect in $filtered) {
  if (-not $first) { Write-Output "" }
  foreach ($l in $sect.Lines) { Write-Output $l }
  $first = $false
}
