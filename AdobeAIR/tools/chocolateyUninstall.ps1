$package = 'AdobeAIR'

try {

  # http://forums.adobe.com/message/4677900
  $airInstall = 'Adobe AIR\Versions\1.0'
  $airPath = $Env:CommonProgramFiles, ${Env:CommonProgramFiles(x86)} |
    % { Join-Path $_ $airInstall } |
    ? { Test-Path $_ } |
    Select -First 1
  $airSetup = Join-Path $airPath 'setup.msi'

  # http://stackoverflow.com/questions/450027/uninstalling-an-msi-file-from-the-command-line-without-using-msiexec
  msiexec.exe /x "`"$airSetup`"" /qb-! REBOOT=ReallySuppress
  # alternate -> wmic product where name='Adobe AIR' call uninstall

  Remove-Item $airInstall -Recurse -ErrorAction SilentlyContinue
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
