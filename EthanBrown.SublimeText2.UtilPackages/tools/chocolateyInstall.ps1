$package = 'EthanBrown.SublimeText2.UtilPackages'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

# simulate the unix command for finding things in path
# http://stackoverflow.com/questions/63805/equivalent-of-nix-which-command-in-powershell
function Which([string]$cmd)
{
  Get-Command -ErrorAction "SilentlyContinue" $cmd |
    Select -ExpandProperty Definition
}

try {
  . (Join-Path (Get-CurrentDirectory) 'JsonHelpers.ps1')
  . (Join-Path (Get-CurrentDirectory) 'SublimeHelpers.ps1')

  $sublimeUserDataPath = Get-SublimeUserPath
  $sublimeFilesFileName = 'SublimeFiles.sublime-settings'
  $sublimeFiles = Join-Path (Get-CurrentDirectory) $sublimeFilesFileName

  # TODO: this doesn't actually work in the Sublime plugin right now, but might in the future
  $systemPath = [Environment]::GetFolderPath('System')
  $psDefault = Join-Path $systemPath 'WindowsPowerShell\v1.0\powershell.exe'
  $ps = (Which powershell),
    $psDefault |
    ? { Test-Path $_ } |
    Select -First 1
  if (!$ps)
  {
    Write-Warning "Could not find Powershell - using default $psDefault"
    $ps = $psDefault
  }

  $psRoot = Split-Path $ps

  $escapedPs = $ps -replace '\\', '\\'
  ([IO.File]::ReadAllText($sublimeFiles)) -replace '{{term_command}}', $escapedPs |
    Out-File -FilePath (Join-Path $sublimeUserDataPath $sublimeFilesFileName) -Force -Encoding ASCII

  $packageCache = Join-Path (Get-CurrentDirectory) 'PackageCache'
  Install-SublimePackagesFromCache -Directory $packageCache -Version 2
  Install-SublimePackageControl -PreRelease -Version 2
  $packageControl = (Join-Path (Get-CurrentDirectory) 'Package Control.sublime-settings')
  Merge-PackageControlSettings -FilePath $packageControl

  $preferences = (Join-Path (Get-CurrentDirectory) 'Preferences.sublime-settings')
  Merge-Preferences -FilePath $preferences

  if (Get-Process -Name sublime_text -ErrorAction SilentlyContinue)
  {
    Write-Warning 'Please close and re-open Sublime Text to force packages to update'
  }
  Write-ChocolateySuccess $package
} catch {
  Write-ChocolateyFailure $package "$($_.Exception.Message)"
  throw
}
