try {
  $package = 'SublimeText3.PowershellAlias'

  $sublDefined = Test-Path function:subl
  $profileExists = Test-Path $PROFILE
  $sublInProfile = $profileExists -and (((Get-Content $PROFILE) -match '^function\s+subl\s+\.*Sublime Text 3').Count -gt 0)

  # add subl alias to powershell profile
  if (!$sublDefined -and !$sublInProfile)
  {
    New-Item (Split-Path $PROFILE) -Type Directory -ErrorAction SilentlyContinue
    'function subl { &"${Env:ProgramFiles}\Sublime Text 3\sublime_text.exe" $args }' |
      Out-File -FilePath $PROFILE -Append -Encoding UTF8
    Write-Host 'Added subl alias to Powershell profile to launch Sublime Text 3!'
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
