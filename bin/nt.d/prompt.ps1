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
  [string]$Prompt
)
if (-not $Prompt) {
  $Prompt = [Console]::In.ReadToEnd()
}
if (-not $Prompt.Trim()) {
  return
}
$cleanPrompt = $Prompt.TrimEnd("`r", "`n")
$wikilinks = @($cleanPrompt | nt wikilinks) |
  ForEach-Object { $_.Trim() } |
  Where-Object { $_ } |
  Select-Object -Unique
if ($wikilinks.Count -eq 0) {
  Write-Output $cleanPrompt
  return
}
$aboutArgs = @('about') + $wikilinks + @('--agent')
$contextOutput = & nt @aboutArgs
$contextText = ($contextOutput -join "`n").Trim()
if ($LASTEXITCODE -ne 0 -or -not $contextText) {
  $warnings = ($wikilinks | ForEach-Object { "⚠️ [[$_]]" }) -join ', '
  $contextText = "[Wikilinks not found: $warnings]"
}
Write-Output "$cleanPrompt`n`n---`n$contextText"
