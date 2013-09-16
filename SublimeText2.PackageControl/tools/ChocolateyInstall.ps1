function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $package = 'SublimeText2.PackageControl'

  $current = Get-CurrentDirectory
  . (Join-Path $current 'SublimeHelpers.ps1')
  . (Join-Path $current 'JsonHelpers.ps1')

  # TODO: come up with a better way to do this install / set this setting
  # that will work based on the semver in this packages .nuspec file
  Install-SublimePackageControl -PreRelease
  $packageControl = Join-Path $current 'Package Control.sublime-settings'
  Merge-PackageControlSettings -FilePath $packageControl

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
