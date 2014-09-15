try {
  $package = 'Terminals'
  $id = '832391'
  $time = '130430743277870000'
  $build = '20928'

  $uri = "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=terminals&DownloadId=$id&FileTime=$time&Build=$build"
  Install-ChocolateyPackage 'TerminalsSetup_V3.5' 'msi' '/quiet' $uri

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
