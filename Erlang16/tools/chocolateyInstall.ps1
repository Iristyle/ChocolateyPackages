$package = 'Erlang'
$version = 'R16B03'
$installFolder = 'erl5.10.4'
$releaseFolder = "$installFolder\releases\$version"

function Remove-PreviousVersions
{
  $filter = 'erl5.10*'
  $installs = (Get-ChildItem ${Env:\ProgramFiles(x86)} -Filter $filter) +
    (Get-ChildItem $Env:ProgramFiles -Filter $filter)

  $installs |
    Get-ChildItem -Filter 'Uninstall.exe' |
    Select -ExpandProperty FullName |
    % {
      $uninstallParams = @{
        PackageName = $package;
        FileType = 'exe';
        SilentArgs = '/S';
        File = $_;
      }

      try
      {
        # including additions to PATH
        $binPath = (Join-Path (Split-Path $_) 'bin') -replace '\\', '\\'

        $userPaths = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' |
          ? { ($_ -notmatch $binPath) -and (![String]::IsNullOrEmpty($_)) } |
          Select-Object -Unique

        [Environment]::SetEnvironmentVariable('Path', ($userPaths -join ';'), 'User')

        Uninstall-ChocolateyPackage @uninstallParams
      }
      catch [Exception]
      {
        Write-Warning "Could not properly uninstall existing Erlang from $($uninstallParams.File):`n`n$_"
      }
    }
}

try {

  $installedPath = (Join-Path ${Env:\ProgramFiles(x86)} $installFolder),
    (Join-Path $Env:ProgramFiles "$installFolder\bin") |
    ? { Test-Path $_ } |
    Select -First 1

  # only way to test for installation of this version is by path on disk
  if ($installedPath -and (Test-Path $installedPath))
  {
    Write-Host "$package $version is already installed to $installedPath"
  }
  else
  {
    # first remove previous R16 releases if found
    Remove-PreviousVersions

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

  $binPath = (Join-Path "${Env:\ProgramFiles(x86)}" "$installFolder\bin"),
    (Join-Path $Env:ProgramFiles "$installFolder\bin") |
    ? { Test-Path $_ } |
    Select -First 1

  Install-ChocolateyPath $binPath

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
