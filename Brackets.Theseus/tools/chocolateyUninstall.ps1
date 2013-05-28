$package = 'Brackets.Theseus'

try {
  $installPath = Join-Path $Env:APPDATA 'Brackets\extensions\user\brackets-theseus'
  Remove-Item $installPath -Recurse -ErrorAction SilentlyContinue

  npm uninstall -g node-theseus@0.0.7

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
