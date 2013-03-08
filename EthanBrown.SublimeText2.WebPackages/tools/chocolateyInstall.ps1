$package = 'EthanBrown.SublimeText2.WebPackages'

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
  $linterFileName = 'SublimeLinter.sublime-settings'
  $gruntFileName = 'SublimeGrunt.sublime-settings'
  $linter = Join-Path (Get-CurrentDirectory) $linterFileName
  $grunt = Join-Path (Get-CurrentDirectory) $gruntFileName

  $node = (Which node)
  $nodeRoot = Split-Path $node

  $escapedNode = $node -replace '\\', '\\'
  ([IO.File]::ReadAllText($linter)) -replace '{{node_path}}', $escapedNode |
    Out-File -FilePath (Join-Path $sublimeUserDataPath $linterFileName) -Force -Encoding ASCII

  $escapedNodeRoot = $nodeRoot -replace '\\', '\\'
  ([IO.File]::ReadAllText($grunt)) -replace '{{node_path}}', $escapedNodeRoot |
    Out-File -FilePath (Join-Path $sublimeUserDataPath $gruntFileName) -Force -Encoding ASCII

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
