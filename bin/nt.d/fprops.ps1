#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# Parse GNU-style flags explicitly so --not and --list work through nt.
$exclude = $args -contains '--not'
$list = $args -contains '--list'
$names = @($args | Where-Object { $_ -notin @('--not', '--list') })
$unknown = @($names | Where-Object { $_ -like '--*' })
if ($unknown.Count -gt 0 -or $names.Count -eq 0) {
  [Console]::Error.WriteLine('Usage: nt fprops [--not] [--list] property [property ...]')
  exit 1
}

foreach ($line in $input) {
  $isProperty = $line -match '^\s*([^\s:]+)::\s*(.*)$'
  $name = if ($isProperty) { $Matches[1] } else { $null }
  $value = if ($isProperty) { $Matches[2] } else { $null }
  $selected = $isProperty -and $name -in $names
  $keep = if ($exclude) { -not $selected } else { $selected }

  if (-not $keep) {
    continue
  }
  if (-not $list) {
    $line
    continue
  }
  if ($isProperty) {
    # A comma inside a wikilink belongs to its name, not the value list.
    foreach ($match in [regex]::Matches($value, '\[\[.*?\]\]|[^,]+')) {
      $item = $match.Value.Trim()
      if ($item.StartsWith('[[') -and $item.EndsWith(']]')) {
        $item = $item.Substring(2, $item.Length - 4).Trim()
      }
      if ($item.Length -gt 0) {
        $item
      }
    }
  }
}
