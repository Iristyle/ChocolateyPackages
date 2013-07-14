$package = 'DartEditor'

try {
  $location = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (!(Test-Path $location))
  {
    $location = Join-Path $Env:SystemDrive 'tools'
  }
  $location = Join-Path $location 'dart'

  if (Test-Path $location)
  {
    Remove-Item $location -Recurse -Force
  }

  Push-Location $Env:ChocolateyInstall\bin
  $batch = 'DartEditor.bat'
  if (Test-Path $batch)
  {
    Remove-Item $batch
  }
  Pop-Location

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
