$package = 'MSXML6.SP1'

try {

  #Vista or greater already ships with MSXML6
  if ([Environment]::OSVersion.Version -ge [Version]'6.0')
  {
    Write-ChocolateySuccess "Installation of $package is not necessary on this OS"
    return
  }

  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/qb';
    url = 'http://download.microsoft.com/download/e/a/f/eafb8ee7-667d-4e30-bb39-4694b5b3006f/msxml6_x86.msi'
    url64bit = 'http://download.microsoft.com/download/e/a/f/eafb8ee7-667d-4e30-bb39-4694b5b3006f/msxml6_x64.msi'
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
