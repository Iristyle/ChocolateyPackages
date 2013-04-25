$package = 'AWSTools.Powershell'

try {
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/quiet';
    url = 'http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi';
  }

  Install-ChocolateyPackage @params
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
