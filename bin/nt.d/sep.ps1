#!/usr/bin/env pwsh
param(
  [string]$Separator = '\n---'
)

# Support standard escape sequences (e.g. \n, \r, \t) in the separator
$Separator = [regex]::Unescape($Separator)

$seen = $false

$input | ForEach-Object {
  if (-not $seen) {
    $Separator
    $seen = $true
  }
  $_
}
