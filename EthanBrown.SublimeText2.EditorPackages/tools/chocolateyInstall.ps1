$package = 'EthanBrown.SublimeText2.EditorPackages'

function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
  $current = Get-CurrentDirectory

  . (Join-Path $current 'JsonHelpers.ps1')
  . (Join-Path $current 'SublimeHelpers.ps1')

  $sublimeUserDataPath = Get-SublimeUserPath

  #straight file copies
  'BracketHighlighter.sublime-settings',
  'MarkdownPreview.sublime-settings' |
    % {
      $params = @{
        Path = Join-Path $current $_;
        Destination = Join-Path $sublimeUserDataPath $_;
        Force = $true
      }
      Copy-Item @params
    }

  $packageControl = Join-Path $current 'Package Control.sublime-settings'
  Merge-PackageControlSettings -FilePath $packageControl

  $preferences = Join-Path $current 'Preferences.sublime-settings'
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
