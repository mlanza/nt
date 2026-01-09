#!/usr/bin/env pwsh

# blocked.ps1 - Processes stdin, prepending "- " to lines that don't start with a space
# Usage: Get-Content input.txt | ./blocked.ps1

while ($input.MoveNext()) {
    $line = $input.Current
    if ($line.Length -gt 0 -and $line[0] -ne ' ' -and $line[0] -ne '-') {
        "- " + $line
    } else {
        $line
    }
}
