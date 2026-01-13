#!/usr/bin/env pwsh
param(
  [string]$Separator = '---'
)

$seen = $false

$input | ForEach-Object {
  if (-not $seen) {
    $Separator
    $seen = $true
  }
  $_
}
