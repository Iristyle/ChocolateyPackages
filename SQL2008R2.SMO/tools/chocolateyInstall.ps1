$package = 'SQL2008R2.SMO'

try {
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/quiet';
    url = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x86/SharedManagementObjects.msi';
    url64bit = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/SharedManagementObjects.msi';
  }

  Install-ChocolateyPackage @params

  # install both x86 and x64 editions of SMO since x64 supports both
  # to install both variants of powershell, both variants of SMO must be present
  $IsSytem32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and `
    ($Env:PROCESSOR_ARCHITEW6432 -eq $null))
  if (!$IsSytem32Bit)
  {
    $params.url64bit = $params.url
    Install-ChocolateyPackage @params
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
