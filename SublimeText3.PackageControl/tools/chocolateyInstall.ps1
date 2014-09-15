function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $package = 'SublimeText3.PackageControl'

  $current = Get-CurrentDirectory
  . (Join-Path $current 'JsonHelpers.ps1')
  . (Join-Path $current 'SublimeHelpers.ps1')

  Install-SublimePackageControl -Version 3

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
