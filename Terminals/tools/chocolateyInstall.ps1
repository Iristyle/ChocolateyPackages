try {
  $package = 'Terminals'

  $uri = 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=terminals&DownloadId=351257&FileTime=129755485683300000&Build=19471'
  Install-ChocolateyPackage 'SetupTerminals_v2.0' 'msi' '/quiet' $uri

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
