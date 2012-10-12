$package = 'SQL2008.NativeClient'

try {
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/quiet';
    url = 'http://go.microsoft.com/fwlink/?LinkId=123717&clcid=0x409';
    url64bit = 'http://go.microsoft.com/fwlink/?LinkId=123718&clcid=0x409';
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
