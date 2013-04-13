$package = 'WindowsUpdate.DisableAutoRestart'

try {
  # http://support.microsoft.com/kb/555444
  # alternate using GPO: http://kevinjameshall.wordpress.com/2012/12/26/windows-8-updates-disable-auto-restart/
  $setRegistryKey = @"
  `$params = @{
    Path = 'HKLM:Software\Policies\Microsoft\Windows\WindowsUpdate\AU';
    Name = 'NoAutoRebootWithLoggedOnUsers';
    Value = 1
  };
  if (!(Test-Path `$params.Path)) { New-Item -Path `$params.Path -Force | Out-Null };
  Set-ItemProperty @params
"@

  Start-ChocolateyProcessAsAdmin $setRegistryKey

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
