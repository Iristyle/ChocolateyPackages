$package = 'Leiningen'
$version = '2.7.1'

try {
  $installDir = Join-Path $Env:USERPROFILE '.lein'
  if (Test-Path $installDir)
  {
    Remove-Item $installDir -Recurse -ErrorAction SilentlyContinue
  }

  $batDir = Join-Path $Env:ChocolateyInstall 'bin'
  $lein = Join-Path $batDir 'lein.bat'
  if (Test-Path $lein)
  {
    Remove-Item $lein -ErrorAction SilentlyContinue
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
