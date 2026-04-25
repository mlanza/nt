#!/usr/bin/env pwsh
# Clean invisible/zero-width/control characters from stdin

# Read entire stdin into $raw
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { return }

# Remove Unicode format-control characters (zero-width spaces, joiners, BOM, etc.)
$clean = $raw -replace '[\p{Cf}]', ''

# Strip carriage returns to normalize to LF
$clean = $clean -replace "`r", ""

# Collapse ChatGPT line-wrap backslashes (backslash at end-of-line)
$clean = $clean -replace '\\\n\s*', ' '

# Emit cleaned text exactly as-is
[Console]::Out.Write($clean)
