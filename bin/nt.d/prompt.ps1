#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Expand wikilinks in a prompt using existing nt helpers.
.DESCRIPTION
  Reads a prompt from an optional positional argument or stdin. When wikilinks
  are detected through `nt wikilinks`, it appends an `---` section with the
  context pulled from `nt about --agent`. The section is only added when
  wikilinks are present.
#>
[CmdletBinding()]
param(
  [Parameter(Position=0)]
  [string]$prompt
)
# Initialize prompt and payload from stdin if piped
$rawInput = ''
if ([Console]::IsInputRedirected) {
  $rawInput = [Console]::In.ReadToEnd()
}
if (-not $prompt -and $rawInput) {
  $prompt = $rawInput
} elseif ($prompt -and $rawInput) {
  $payload = $rawInput
}
if (-not $prompt.Trim()) {
  return
}
$cleanPrompt = $prompt.TrimEnd("`r", "`n")
$wikilinks = @($cleanPrompt | nt wikilinks) |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ } |
  Select-Object -Unique
$pattern = '(?s)(\[{3,})(.+?)(\]{3,})'
$finalPrompt = [regex]::Replace($cleanPrompt, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{
  param($match)
  $open = $match.Groups[1].Value
  $close = $match.Groups[3].Value
  $inner = $match.Groups[2].Value
  $count = [math]::Min($open.Length, $close.Length)
  $target = [math]::Max(2, $count - 1)
  $prefix = '[' * $target
  $suffix = ']' * $target
  return "$prefix$inner$suffix"
})
$aboutArgs = @('about') + $wikilinks + @('--agent')
$contextOutput = & nt @aboutArgs
$contextText = ($contextOutput -join "`n").Trim()
if ($LASTEXITCODE -ne 0 -or -not $contextText) {
  $warnings = ($wikilinks | ForEach-Object { "⚠️ [[$_]]" }) -join ', '
  $contextText = "[Wikilinks not found: $warnings]"
}

# Handle payload if present
if ($payload) {
  if ($wikilinks.Count -gt 0) {
    $promptBlock = "$finalPrompt`n`n---`n$contextText"
  } else {
    $promptBlock = $finalPrompt
  }
  Write-Output $promptBlock
  $payloadTrimmed = $payload.TrimEnd("`r", "`n")
  # blank line before separator
  Write-Output ""
  $sepOutput = $payloadTrimmed | nt sep
  $sepOutput = $sepOutput -replace '(?m)^---$', "---`n# Input"
  Write-Output $sepOutput
  return
}

if ($wikilinks.Count -eq 0) {
  Write-Output $finalPrompt
  return
}

Write-Output "$finalPrompt`n`n---`n$contextText"
