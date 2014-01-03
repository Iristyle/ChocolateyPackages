$package = 'AndroidStudio'
$majorVersion = '0.3.2'
$buildVersion = 132.893413

try {

  $build = Join-Path $Env:LOCALAPPDATA 'Android\android-studio\build.txt'

  if ((Test-Path $build) -and ((Get-Content $build) -match '.*?(\d+\.\d+)'))
  {
    $installedVersion = [decimal]$Matches[1]
    if ($installedVersion -lt $buildVersion)
    {
      Write-Host "Uninstalling existing version $installedVersion"
      . .\chocolateyUninstall.ps1
    }
    else
    {
      Write-Host "$package $installedVersion already installed!"
      exit
    }
  }

  $params = @{
    PackageName = $package;
    FileType = 'exe';
    #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
    SilentArgs = '/S';
    Url = "https://dl.google.com/android/studio/install/$majorVersion/android-studio-bundle-$buildVersion-windows.exe";
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
