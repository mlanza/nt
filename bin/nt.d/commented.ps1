#!/usr/bin/env pwsh
# Process stdin, keep everything before first ;;;, then filter out lines starting with ;;

$content = $Input | Out-String
if ($content) {
    # Split on first ;;; and keep everything before it
    $indexOfTripleSemicolon = $content.IndexOf(";;;")
    if ($indexOfTripleSemicolon -ge 0) {
        $content = $content.Substring(0, $indexOfTripleSemicolon)
    }
    
    # Filter out lines that start with ;; when trimmed
    $content -split "`r?`n" | Where-Object { 
        $trimmed = $_.Trim()
        $trimmed.Length -gt 0 -and -not $trimmed.StartsWith(";;")
    } | Write-Output
}