$package = 'HipChat'

try {

  $hipParams = @{
    PackageName = $package;
    FileFullPath = (Join-Path $Env:TEMP 'hipchat.air');
    Url = 'http://downloads.hipchat.com/hipchat.air'
  }

  Get-ChocolateyWebFile @hipParams

  $airInstall = 'Adobe AIR\Versions\1.0\Adobe AIR Application Installer.exe'
  $airPath = $Env:CommonProgramFiles, ${Env:CommonProgramFiles(x86)} |
    % { Join-Path $_ $airInstall } |
    ? { Test-Path $_ } |
    Select -First 1

  if (!$airPath)
  {
    Write-ChocolateyFailure $package 'Could not find AIR installer!'
    return
  }

  $installPath = Join-Path $Env:ProgramFiles 'Hipchat'
  $airParams = @('-silent', '-eulaAccepted', '-programMenu',
     '-location', "`"$installPath`"", "`"$($hipParams.FileFullPath)`"")

  Start-ChocolateyProcessAsAdmin -exeToRun $airPath -statements $airParams

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
