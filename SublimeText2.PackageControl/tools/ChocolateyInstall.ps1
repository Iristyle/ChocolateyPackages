function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $package = 'SublimeText2.PackageControl'

  $current = Get-CurrentDirectory
  . (Join-Path $current 'SublimeHelpers.ps1')

  Install-SublimePackageControl

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
