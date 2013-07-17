$package = 'Erlang'
$version = 'R16B01'
$installFolder = 'erl5.10.2'
$releaseFolder = "$installFolder\releases\$version"

try {

  $installedPath = (Join-Path "${Env:\ProgramFiles(x86)}" $installFolder),
    (Join-Path $Env:ProgramFiles "$installFolder\bin") |
    ? { Test-Path $_ } |
    Select -First 1

  # only way to test for installation of this version is by path on disk
  if (Test-Path $installedPath)
  {
    Write-Host "$package $version is already installed to $installedPath"
  }
  else
  {
    $params = @{
      PackageName = $package;
      FileType = 'exe';
      #uses NSIS installer - http://nsis.sourceforge.net/Docs/Chapter3.html
      SilentArgs = '/S';
      Url = "http://www.erlang.org/download/otp_win32_$($version).exe";
      Url64Bit = "http://www.erlang.org/download/otp_win64_$($version).exe";
    }

    Install-ChocolateyPackage @params
  }

  $binPath = (Join-Path "${Env:\ProgramFiles(x86)}" $installFolder),
    (Join-Path $Env:ProgramFiles "$installFolder\bin") |
    ? { Test-Path $_ } |
    Select -First 1

  Install-ChocolateyPath $binPath

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}

