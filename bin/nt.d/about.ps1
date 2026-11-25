#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

try {
  $topics = @($input) + @($args)
  $prereqs = $topics | nt prereq | nt seen
  $body = $topics | nt seen | nt prereq | nt seen | nt page --less | nt tidy
  $body
  $skills = $body | nt fprops skills --list | nt seen
  if ($skills) {
    $skills | sort | nt props tags description -r description --heading=2 | nt sep "# Skills" | nt sep ""
  }
  $wikilinks = $body | nt fprops skills prerequisites --not | nt wikilinks | nt seen
  if ($wikilinks) {
    $mentioned = $wikilinks | nt n --unaliased
    if ($mentioned) {
      $mentioned | Where-Object { $_ -notin ($topics + $prereqs) } | sort | nt props tags description -r description --heading=2 | nt sep "# See Also" | nt sep ""
    }
  }
} catch [System.Management.Automation.NativeCommandExitException] {
  # Native commands already report their errors on stderr.
  exit $_.Exception.ExitCode
} catch {
  [Console]::Error.WriteLine($_.Exception.Message)
  exit 1
}
