$package = 'Leiningen'
$version = 'stable'

try {
  $url = "https://raw.github.com/technomancy/leiningen/$version/bin/lein.bat"

  $batDir = Join-Path $Env:ChocolateyInstall 'bin'
  $lein = Join-Path $batDir 'lein.bat'

  Write-Host "Downloading from $url"

  $client = New-Object Net.WebClient
  $client.DownloadFile($url, $lein)

  Write-Host "Download from $url complete"

  Write-Host "Executing bootstrap script from $batDir"

  # $batDir is already in PATH
  lein self-install
  lein
  lein version

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
