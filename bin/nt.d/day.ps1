#!/usr/bin/env pwsh
param(
  [int]$Offset = 0
)

if ($MyInvocation.ExpectingInput) {
  foreach ($Offset in $input) {
    (Get-Date).AddDays($Offset).ToString('yyyy-MM-dd')
  }
} else {
  (Get-Date).AddDays($Offset).ToString('yyyy-MM-dd')
}
