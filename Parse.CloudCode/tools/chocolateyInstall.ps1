$package = 'Parse.CloudCode'

try {
  # 1 click-once installer, requires some hoops to install silently
  # and if so, will not install pre-reqs - sad panda :(
  # https://parse.com/downloads/windows/console/setup.exe

  # there is also a Windows 8 application
  # https://parse.com/downloads/windows/console/ParseConsole.application

  # https://www.parse.com/docs/cloud_code_guide
  # http://stackoverflow.com/questions/12436475/how-to-install-parse-com-cloud-code-on-windows
  # http://blog.parse.com/2012/10/25/parse-command-line-tools-available-for-windows/

  $params = @{
    PackageName = $package;
    FileType = 'zip';
    Url = 'https://www.parse.com/downloads/windows/console/parse.zip';
    UnzipLocation = Join-Path $Env:SystemDrive 'tools';
  }

  $binRoot = Join-Path $Env:SystemDrive $Env:Chocolatey_Bin_Root
  if (Test-Path $binRoot)
  {
    $params.UnzipLocation = $binRoot
  }

  $params.UnzipLocation = Join-Path $params.UnzipLocation 'parse'
  if (!(Test-Path($params.UnzipLocation)))
  {
    New-Item $params.UnzipLocation -Type Directory
  }

  Install-ChocolateyZipPackage @params

  Get-ChocolateyBins $params.UnzipLocation

  # ParseConsole.exe is just a simple wrapper around some .NET code
  # so we can simulate that (thanks Reflector ;0)
  $location = Join-Path $params.UnzipLocation 'ParseConsole.Exe'
  $root = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\'

  Write-Host 'Registering Parse Console in registry'
  @(
    @{Name = 'parse.exe'; Value = $location}
    @{Name = 'parseconsole.exe'; Value = $location}
  ) |
    % {
      New-Item -Path $root @_ -Force | Out-Null
    }

  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
