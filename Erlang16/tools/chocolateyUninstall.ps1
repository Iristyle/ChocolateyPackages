$package = 'Erlang'
$installFolder = 'erl5.10.2'

try
{
  $installPath = (Join-Path "${Env:\ProgramFiles(x86)}" $installFolder),
    (Join-Path $Env:ProgramFiles $installFolder) |
    ? { Test-Path $_ } |
    Select -First 1

  $uninstall = Join-Path $installPath 'uninstall.exe'

  #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
  $uninstallParams = @{
    PackageName = $package;
    FileType = 'exe';
    SilentArgs = '/S';
    File = $uninstall;
  }

  Uninstall-ChocolateyPackage @uninstallParams

  $binLocation = (Join-Path $installPath 'bin') -replace '\\', '\\'

  $userPaths = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
    ? { ($_ -notmatch $binLocation) -and (![String]::IsNullOrEmpty($_)) } |
    Select-Object -Unique

  [Environment]::SetEnvironmentVariable('Path', ($userPaths -join ';'), 'User')

  Write-ChocolateySuccess $package
}
catch
{
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
