$text = $input | Out-String
$text = $text -replace "(`r?`n){3,}", "`r`n`r`n" # compact more than 1 blank line interiors
$text = $text.TrimEnd("`r","`n") + "`r`n"        # exactly 1 blank line before EOF
$text
