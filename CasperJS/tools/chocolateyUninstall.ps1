$package = 'CasperJS'

try {
  $installPath = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (!(Test-Path $installPath))
  {
    $installPath = Join-Path $Env:SystemDrive 'tools'
  }
  $installPath = Join-Path $installPath 'casperjs'

  if (Test-Path $installPath)
  {
    Remove-Item $installPath -Recurse -Force
  }

  $binLocation = $installPath -replace '\\', '\\'

  $userPaths = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
    ? { ($_ -notmatch $binLocation) -and (![String]::IsNullOrEmpty($_)) } |
    Select-Object -Unique

  [Environment]::SetEnvironmentVariable('Path', ($userPaths -join ';'), 'User')

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
