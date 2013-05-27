$package = 'AndroidStudio'

try
{
  $installPath = (Join-Path "${Env:\ProgramFiles(x86)}" 'AndroidStudio'),
    (Join-Path 'Env:ProgramFiles' 'AndroidStudio') |
    ? { Test-Path $_ } |
    Select -First 1

  $uninstall = Join-Path $Env:LOCALAPPDATA 'Android\android-studio\uninstall.exe'

  #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
  $uninstallParams = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = '/S';
    File = $uninstall;
  }

  Uninstall-ChocolateyPackage @uninstallParams
  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
