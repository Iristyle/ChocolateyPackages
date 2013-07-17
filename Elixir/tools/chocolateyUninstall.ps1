$package = 'Elixir'

try {
  $location = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (!(Test-Path $location))
  {
    $location = Join-Path $Env:SystemDrive 'tools'
  }
  $location = Join-Path $location $package

  if (Test-Path $location)
  {
    Remove-Item $location -Recurse -Force
  }

  $binLocation = (Join-Path $location 'bin') -replace '\\', '\\'

  $userPaths = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
    ? { ($_ -notmatch $binLocation) -and (![String]::IsNullOrEmpty($_)) } |
    Select-Object -Unique

  [Environment]::SetEnvironmentVariable('Path', ($userPaths -join ';'), 'User')

  Write-Host @'Please restart your current shell session to access Elixir commands:
  elixir
  elixirc
  mix
  iex.bat (use batch file within Powershell due to name collision)
  '@

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
