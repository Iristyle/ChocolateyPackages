$package = 'AndroidStudio'
$version = 130.737825

try {

  $build = Join-Path $Env:LOCALAPPDATA 'Android\android-studio\build.txt'

  if ((Test-Path $build) -and ((Get-Content $build) -match '.*?(\d+\.\d+)'))
  {
    $installedVersion = [decimal]$Matches[1]
    if ($installedVersion -lt $version)
    {
      Write-Host "Uninstalling existing version $installedVersion"
      . .\chocolateyUninstall.ps1

      $params = @{
        PackageName = $package;
        FileType = 'exe';
        #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
        SilentArgs = '/S';
        Url = 'http://dl.google.com/android/studio/android-studio-bundle-130.737825-windows.exe';
      }

      Install-ChocolateyPackage @params
    }
    else
    {
      Write-Host "$package $installedVersion already installed!"
    }
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
