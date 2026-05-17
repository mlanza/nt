#!/usr/bin/env pwsh
param(
  [Alias('t')]
  [string]$type = 'bracket',
  [Alias('priority')]
  [switch]$include_priority,
  [Alias('fenced','include-fenced')]
  [switch]$include_fenced
)

# Split comma-separated types into array
$typeArray = $type -split ',' | ForEach-Object { $_.Trim() }

$patterns = @{
  'tag' = '#(\w+)|#\[\[([^\]]+)\]\]'
  'bracket' = '(?<!#)\[\[([^\]\r\n]+)\]\]'
}

# Handle 'all' type by expanding to all available types
if ($typeArray -contains 'all') {
  $typeArray = $patterns.Keys
}

$selectedPatterns = @()
foreach ($t in $typeArray) {
  if ($patterns.ContainsKey($t)) {
    $selectedPatterns += $patterns[$t]
  } else {
    Write-Error "Unknown type: $t. Valid types are: $($patterns.Keys -join ', '), all"
    exit 1
  }
}

$inputLines = @($input)
$content = $inputLines -join "`n"

$content = [regex]::Replace($content, '(?s)\[\[\[.*?\]\]\]', '')

if (-not $include_fenced) {
  $content = [regex]::Replace($content, '(?s)```.*?```', '')
}

$results = @()
foreach ($pattern in $selectedPatterns) {
  $matches = [regex]::Matches($content, $pattern)
  foreach ($match in $matches) {
    if ($match.Groups.Count -gt 1) {
      for ($i = 1; $i -lt $match.Groups.Count; $i++) {
        if ($match.Groups[$i].Success) {
          $results += $match.Groups[$i].Value
        }
      }
    }
  }
}

if ($include_priority) {
  $results
} else {
  $results | Where-Object { $_ -notin @('A', 'B', 'C') }
}
