try {
  $package = 'SublimeText2.PackageControl'

  # install package control
  $installPath = Join-Path $Env:ProgramFiles 'Sublime Text 2'
  $sublimeDataPath = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Sublime Text 2'
  $packagesPath = Join-Path $sublimeDataPath 'Installed Packages'
  if (!(Test-Path $packagesPath)) { New-Item $packagesPath -Type Directory }
  $packageControl = Join-Path $packagesPath 'Package Control.sublime-package'

  if (!(Test-Path $packageControl))
  {
    # http://wbond.net/sublime_packages/package_control/installation
    $packageUrl = 'http://sublime.wbond.net/Package%20Control.sublime-package'
    Get-ChocolateyWebFile -url $packageUrl -fileFullPath $packageControl
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
