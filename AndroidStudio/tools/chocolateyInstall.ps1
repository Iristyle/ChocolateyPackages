$package = 'AndroidStudio'

try {
  $params = @{
    PackageName = $package;
    FileType = 'exe';
    #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
    SilentArgs = '/S';
    Url = 'http://dl.google.com/android/studio/android-studio-bundle-130.737825-windows.exe';
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
