$package = 'SQL2008R2.NativeClient'

try {
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = ' /qb IACCEPTSQLNCLILICENSETERMS=YES';
    url = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/sqlncli.ms';
    url64bit = 'http://download.microsoft.com/download/B/6/3/B63CAC7F-44BB-41FA-92A3-CBF71360F022/1033/x64/sqlncli.msi';
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
