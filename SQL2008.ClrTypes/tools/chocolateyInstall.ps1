$package = 'SQL2008.ClrTypes'

try {
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/quiet';
    url = 'http://go.microsoft.com/fwlink/?LinkId=123721&clcid=0x409';
    url64bit = 'http://go.microsoft.com/fwlink/?LinkId=123722&clcid=0x409';
  }

  Install-ChocolateyPackage @params

  # http://forums.iis.net/p/1174672/1968094.aspx
  # it turns out that even on x64, x86 clr types should also be installed
  # or SMO breaks
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
