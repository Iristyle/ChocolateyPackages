try {
  $package = 'Terminals'

  $uri = 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=terminals&DownloadId=720349&FileTime=130216499768500000&Build=20748'
  Install-ChocolateyPackage 'TerminalsSetup_V3.3' 'msi' '/quiet' $uri

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
