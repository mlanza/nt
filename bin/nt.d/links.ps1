#!/usr/bin/env pwsh
param(
  [Alias('t')]
  [string]$type = 'all',
  [switch]$bare
)

$patterns = @{
  'md' = '\[[^\]\r\n]+\]\(\s*https?:\/\/[^\s)]+(?:\s+"[^"\r\n]*")?\s*\)'
  'bare' = '(?<!\[[^\]]*]\(\s*)https?:\/\/[^\s)\]]+'
}

# Handle 'all' type by expanding to all available types
$typeArray = if ($type -eq 'all') { $patterns.Keys } else { $type -split ',' | ForEach-Object { $_.Trim() } }

$selectedPatterns = @()
foreach ($t in $typeArray) {
  if ($patterns.ContainsKey($t)) {
    $selectedPatterns += $patterns[$t]
  } else {
    Write-Error "Unknown type: $t. Valid types are: $($patterns.Keys -join ', '), all"
    exit 1
  }
}

$input | ForEach-Object {
  $line = $_
  foreach ($pattern in $selectedPatterns) {
    $matches = [regex]::Matches($line, $pattern)
    foreach ($match in $matches) {
      if ($pattern -eq $patterns['md']) {
        if ($match.Value -match '^\[([^\]]+)\]\((https?:\/\/[^\s)]+)') {
          if ($bare) {
            $Matches[2]
          } else {
            "$($Matches[2]) => $($Matches[1])"
          }
        }
      } else {
        $match.Value
      }
    }
  }
}
