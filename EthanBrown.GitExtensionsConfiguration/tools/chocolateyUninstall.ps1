$package = 'EthanBrown.GitExtensionsConfiguration'

try {
  Write-Host "Configure settings from the Git Extensions menu (Settings -> Settings) manually"
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
