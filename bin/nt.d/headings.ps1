#!/usr/bin/env pwsh
# Filter lines matching Markdown headings (h1–h6) from stdin
foreach ($line in $input) {
  if ($line -match '^(#{1,6})\s') {
    $line
  }
}
