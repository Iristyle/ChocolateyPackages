try {
  $package = 'Terminals'

  $uri = 'http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=terminals&DownloadId=766741&FileTime=130311898883870000&Build=20859'
  Install-ChocolateyPackage 'TerminalsSetup' 'msi' '/quiet' $uri

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
