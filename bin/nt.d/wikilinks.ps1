#!/usr/bin/env pwsh
param(
  [Alias('t')]
  [string]$type = 'bracket',
  [Alias('priority')]
  [switch]$include_priority
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

$results = @()
$input | ForEach-Object {
  $line = $_
  foreach ($pattern in $selectedPatterns) {
    $matches = [regex]::Matches($line, $pattern)
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
}

if ($include_priority) {
  $results
} else {
  $results | Where-Object { $_ -notin @('A', 'B', 'C') }
}
