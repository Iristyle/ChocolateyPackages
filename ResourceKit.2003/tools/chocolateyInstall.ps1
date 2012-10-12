$package = 'ResourceKit.2003'

try {

  $tempPath = Join-Path $Env:TEMP 'rktools.2003'
  if (!(Test-Path $tempPath)) { New-Item -Type Directory $tempPath }

  #http://remstate.com/2008/05/21/the-windows-resource-kit/
  $params = @{
    packageName = $package;
    fileFullPath = Join-Path $tempPath 'rktools.exe'
    url = 'http://download.microsoft.com/download/8/e/c/8ec3a7d8-05b4-440a-a71e-ca3ee25fe057/rktools.exe'
  }

  Get-ChocolateyWebFile @params

  Push-Location $tempPath
  .\rktools.exe /T:$tempPath /C

  #Reference: RKTools is the param for a non default install directory
  $params = @{
    packageName = $package;
    fileType = 'msi';
    silentArgs = '/qn'; #, "RKTOOLS=`"$installDir`"";
    file = Join-Path $tempPath 'rktools.msi';
  }

  Install-ChocolateyInstallPackage @params
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
