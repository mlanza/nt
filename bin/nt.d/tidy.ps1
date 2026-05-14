[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read all input from stdin as UTF-8
$text = [Console]::In.ReadToEnd()

# Compact more than one blank line (interiors)
$text = $text -replace "(`r?`n){3,}", "`r`n`r`n"

# Ensure exactly one newline at end of file
$text = $text.TrimEnd("`r","`n") + "`r`n"

# Write output as UTF-8 without further changes
[Console]::Out.Write($text)
