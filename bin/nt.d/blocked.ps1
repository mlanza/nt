#!/usr/bin/env pwsh

# blocked.ps1 - Processes stdin, prepending "- " to lines that don't start with a space
# Only transforms content if no lines start with " " or "- "
# Usage: Get-Content input.txt | ./blocked.ps1

# Read all input lines first
$lines = @()
while ($input.MoveNext()) {
  $lines += $input.Current
}

# Check if any line starts with space or "- "
$hasBlockedLines = $lines | Where-Object { $_.StartsWith(" ") -or $_.StartsWith("- ") } | Measure-Object | Select-Object -ExpandProperty Count

if ($hasBlockedLines -gt 0) {
  # Output original content unchanged
  $lines
} else {
  # Prepend "- " to each line
  $lines | ForEach-Object { "- " + $_ }
}
