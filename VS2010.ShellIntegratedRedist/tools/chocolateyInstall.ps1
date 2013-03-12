$package = 'VS2010.ShellIntegratedRedist'

try {

  # FYI - there is also an Isolated redist in addition to an Integrated one
  # http://www.microsoft.com/en-us/download/details.aspx?id=1366
  # http://download.microsoft.com/download/1/9/3/1939AD78-F8E8-4336-83F3-E2470F422C62/VSIsoShell.exe

  $params = @{
    packageName = $package;
    fileType = 'exe';
    silentArgs = '/q /full /norestart';
    url = 'http://download.microsoft.com/download/D/7/0/D70CD265-3E18-41B0-AFC6-075AFA2DA631/VSIntShell.exe';
  }

  Install-ChocolateyPackage @params

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
