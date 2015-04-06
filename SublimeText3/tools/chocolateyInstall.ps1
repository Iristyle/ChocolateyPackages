$package = 'SublimeText3'
$build = '3083'
$installFolder = 'Sublime Text 3'

try {

  $installedPath = (Join-Path "${Env:\ProgramFiles(x86)}" $installFolder),
    (Join-Path $Env:ProgramFiles $installFolder) |
    ? { Test-Path $_ } |
    Select -First 1

  # only way to test for installation of this version is by path on disk
  $found = $false
  if ($installedPath -and (Test-Path $installedPath))
  {
    $exe = Join-Path $installedPath 'sublime_text.exe'
    $version = (Get-Command $exe).FileVersionInfo.ProductVersion
    $found = ($version -eq $build)
  }

  if ($found)
  {
    Write-Host "$package is already installed to $installedPath"
  }
  else
  {
    $params = @{
      PackageName = $package;
      FileType = 'exe';
      #uses InnoSetup - http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline
      SilentArgs = '/VERYSILENT /NORESTART /TASKS="contextentry"';
      Url = "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%20$build%20Setup.exe";
      Url64Bit = "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%20$build%20x64%20Setup.exe";
    }

    Install-ChocolateyPackage @params
  }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
